//
//  ESRelativeDateFormatParser.swift
//  SwiftyChrono
//
//  Created by Codex on 2026-02-08.
//

import Foundation

// Matches patterns like:
//   "semana pasada", "mes próximo", "año pasado"
//   "última semana", "próximo mes"
//   "últimas 2 semanas", "últimos 3 meses", "últimos 20 días"
private let PATTERN = "(\\W|^)" +
    "(?:" +
        // Leading modifier form: "[las] últimas [N] semanas", "próximo mes"
        "(?:(?:la|el|las|los|del?|de\\s+la|de\\s+el|de\\s+las|de\\s+los)\\s+)?" +
        "([úu]ltim[oa]s?|pasad[oa]s?|pr[óo]xim[oa]s?)\\s+" +
        "(?:(\(ES_INTEGER_WORDS_PATTERN)|[0-9]+|unos|unas|algunos|algunas)\\s+)?" +
        "(d[ií]as?|semanas?|mes(?:es)?|a[ñn]os?)" +
    "|" +
        // Trailing modifier form: "[la] semana pasada", "[el] mes próximo"
        "(?:(?:la|el|las|los|del?)\\s+)?" +
        "(d[ií]as?|semanas?|mes(?:es)?|a[ñn]os?)\\s+" +
        "(pasad[oa]|pr[óo]xim[oa]|[úu]ltim[oa])" +
    ")" +
    "(?=\\W|$)"

// Leading modifier form groups
private let leadingModifierGroup = 2
private let numberGroup = 3
private let leadingUnitGroup = 4
// Trailing modifier form groups
private let trailingUnitGroup = 5
private let trailingModifierGroup = 6

public class ESRelativeDateFormatParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .spanish }

    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType : Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        result.tags[.esRelativeDateFormatParser] = true

        let modifierText: String
        let unitText: String
        let numberText: String

        if match.isNotEmpty(atRangeIndex: leadingModifierGroup) {
            numberText = match.isNotEmpty(atRangeIndex: numberGroup) ? match.string(from: text, atRangeIndex: numberGroup).lowercased() : ""
            modifierText = match.string(from: text, atRangeIndex: leadingModifierGroup).lowercased()
            unitText = match.string(from: text, atRangeIndex: leadingUnitGroup).lowercased()
        } else {
            numberText = ""
            modifierText = match.string(from: text, atRangeIndex: trailingModifierGroup).lowercased()
            unitText = match.string(from: text, atRangeIndex: trailingUnitGroup).lowercased()
        }

        let isNextModifier = NSRegularExpression.isMatch(forPattern: "^pr[óo]xim", in: modifierText)
        let modifier = isNextModifier ? 1 : -1

        var number: Int
        if let n = ES_INTEGER_WORDS[numberText] {
            number = n
        } else if numberText.isEmpty {
            number = 1
        } else if NSRegularExpression.isMatch(forPattern: "unos|unas|algunos|algunas", in: numberText) {
            number = 3
        } else {
            number = Int(numberText) ?? 1
        }

        let hasExplicitMultiplier = !numberText.isEmpty
        number *= modifier

        let prefixText = text.substring(from: 0, to: index).lowercased()
        let hasSincePrefix = NSRegularExpression.isMatch(forPattern: "\\bdesde\\s*(?:la\\s+|el\\s+)?$", in: prefixText)
        let isLastModifier = !isNextModifier
        let hasInPrefix = NSRegularExpression.isMatch(forPattern: "\\ben\\s*(?:la\\s+|el\\s+|las\\s+|los\\s+)?$", in: prefixText)
        var date = ref

        if NSRegularExpression.isMatch(forPattern: "d[ií]a", in: unitText) {
            date = date.added(number, .day)
            result.start.assign(.year, value: date.year)
            result.start.assign(.month, value: date.month)
            result.start.assign(.day, value: date.day)
        } else if NSRegularExpression.isMatch(forPattern: "semana", in: unitText) {
            let isSingleWeekRange = !hasExplicitMultiplier
            let shouldUseRollingRange = isSingleWeekRange && hasInPrefix && isLastModifier
            if shouldUseRollingRange {
                // "en la semana pasada" = 7-day window ending at ref (inclusive)
                let rangeStart = ref.added(-6, .day)
                result.start.assign(.year, value: rangeStart.year)
                result.start.assign(.month, value: rangeStart.month)
                result.start.assign(.day, value: rangeStart.day)

                result.end = ParsedComponents(components: nil, ref: result.start.date)
                result.end?.assign(.year, value: ref.year)
                result.end?.assign(.month, value: ref.month)
                result.end?.assign(.day, value: ref.day)
            } else if isSingleWeekRange {
                let offsetToMonday = (ref.weekday + 6) % 7
                let currentWeekMonday = ref.added(-offsetToMonday, .day)
                let rangeStart = currentWeekMonday.added(number * 7, .day)

                result.start.assign(.year, value: rangeStart.year)
                result.start.assign(.month, value: rangeStart.month)
                result.start.assign(.day, value: rangeStart.day)

                if !hasSincePrefix {
                    let rangeEnd = rangeStart.added(6, .day)
                    result.end = ParsedComponents(components: nil, ref: result.start.date)
                    result.end?.assign(.year, value: rangeEnd.year)
                    result.end?.assign(.month, value: rangeEnd.month)
                    result.end?.assign(.day, value: rangeEnd.day)
                }
            } else {
                date = date.added(number * 7, .day)
                result.start.assign(.year, value: date.year)
                result.start.assign(.month, value: date.month)
                result.start.assign(.day, value: date.day)
            }
        } else if NSRegularExpression.isMatch(forPattern: "mes", in: unitText) {
            date = date.added(number, .month)
            let isSingleMonthRange = !hasExplicitMultiplier
            let shouldUseRollingMonthRange = isSingleMonthRange && hasInPrefix && isLastModifier
            if shouldUseRollingMonthRange {
                // "en el mes pasado" = rolling window from (ref - 1 month) to ref
                let rangeStart = ref.added(-1, .month)
                result.start.assign(.year, value: rangeStart.year)
                result.start.assign(.month, value: rangeStart.month)
                result.start.assign(.day, value: rangeStart.day)

                result.end = ParsedComponents(components: nil, ref: result.start.date)
                result.end?.assign(.year, value: ref.year)
                result.end?.assign(.month, value: ref.month)
                result.end?.assign(.day, value: ref.day)
            } else if isSingleMonthRange {
                result.start.assign(.day, value: 1)
                result.start.assign(.month, value: date.month)
                result.start.assign(.year, value: date.year)
                if !hasSincePrefix {
                    result.end = ParsedComponents(components: nil, ref: result.start.date)
                    result.end?.assign(.year, value: date.year)
                    result.end?.assign(.month, value: date.month)
                    let daysInMonth = date.numberOf(.day, inA: .month) ?? 0
                    if daysInMonth > 0 {
                        result.end?.assign(.day, value: daysInMonth)
                    }
                }
            } else {
                result.start.assign(.year, value: date.year)
                result.start.assign(.month, value: date.month)
                result.start.assign(.day, value: date.day)
            }
        } else if NSRegularExpression.isMatch(forPattern: "a[ñn]o", in: unitText) {
            date = date.added(number, .year)
            let isSingleYearRange = !hasExplicitMultiplier
            let shouldUseRollingYearRange = isSingleYearRange && hasInPrefix && isLastModifier
            if shouldUseRollingYearRange {
                // "en el año pasado" = rolling window from (ref - 1 year) to ref
                let rangeStart = ref.added(-1, .year)
                result.start.assign(.year, value: rangeStart.year)
                result.start.assign(.month, value: rangeStart.month)
                result.start.assign(.day, value: rangeStart.day)

                result.end = ParsedComponents(components: nil, ref: result.start.date)
                result.end?.assign(.year, value: ref.year)
                result.end?.assign(.month, value: ref.month)
                result.end?.assign(.day, value: ref.day)
            } else if isSingleYearRange {
                result.start.imply(.day, to: 1)
                result.start.imply(.month, to: 1)
                result.start.assign(.year, value: date.year)
                if !hasSincePrefix {
                    result.end = ParsedComponents(components: nil, ref: result.start.date)
                    result.end?.assign(.year, value: date.year)
                    result.end?.assign(.month, value: 12)
                    result.end?.assign(.day, value: 31)
                }
            } else {
                result.start.assign(.year, value: date.year)
                result.start.assign(.month, value: date.month)
                result.start.assign(.day, value: date.day)
            }
        }

        return result
    }
}

//
//  DERelativeDateFormatParser.swift
//  SwiftyChrono
//
//  Created by Codex on 2026-02-08.
//

import Foundation

// Matches patterns like:
//   "letzte Woche", "nächsten Monat", "letztes Jahr"
//   "Woche letzte" (trailing modifier, unit modifier)
//   "letzten 3 Monate", "letzten 2 Jahre", "letzten 20 Tage"
// German order: modifier [number] unit  (e.g. "letzten 3 Wochen")
private let PATTERN = "(\\W|^)" +
    "(?:" +
        "(letzte[nrms]?|n(?:ä|ae)chste[nrms]?|kommende[nrms]?)\\s+" +
        "(?:(\(DE_INTEGER_WORDS_PATTERN)|[0-9]+|wenige[rn]?|einige[rn]?|paar)\\s+)?" +
        "(tag(?:en|e)?|wochen?|monat(?:en|e|s)?|jahr(?:en|(?:es)|e)?)" +
    "|" +
        "(?:(?:der|die|den|dem|des|im|in)\\s+)?" +
        "(tag(?:en|e)?|wochen?|monat(?:en|e|s)?|jahr(?:en|(?:es)|e)?)\\s+" +
        "(letzte[nrms]?|n(?:ä|ae)chste[nrms]?|kommende[nrms]?)" +
    ")" +
    "(?=\\W|$)"

// Leading modifier form groups (modifier [number] unit)
private let leadingModifierGroup = 2
private let numberGroup = 3
private let leadingUnitGroup = 4
// Trailing modifier form groups (unit modifier)
private let trailingUnitGroup = 5
private let trailingModifierGroup = 6

public class DERelativeDateFormatParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .german }

    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType : Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        result.tags[.deRelativeDateFormatParser] = true

        let modifierText: String
        let unitText: String
        let numberText: String

        if match.isNotEmpty(atRangeIndex: leadingModifierGroup) {
            // Leading modifier form: "(N) letzten Wochen"
            numberText = match.isNotEmpty(atRangeIndex: numberGroup) ? match.string(from: text, atRangeIndex: numberGroup).lowercased() : ""
            modifierText = match.string(from: text, atRangeIndex: leadingModifierGroup).lowercased()
            unitText = match.string(from: text, atRangeIndex: leadingUnitGroup).lowercased()
        } else {
            // Trailing modifier form: "Woche letzte"
            numberText = ""
            modifierText = match.string(from: text, atRangeIndex: trailingModifierGroup).lowercased()
            unitText = match.string(from: text, atRangeIndex: trailingUnitGroup).lowercased()
        }

        let isNextModifier = NSRegularExpression.isMatch(forPattern: "^(n(?:ä|ae)chste|kommende)", in: modifierText)
        let modifier = isNextModifier ? 1 : -1

        var number: Int
        if let n = DE_INTEGER_WORDS[numberText] {
            number = n
        } else if numberText.isEmpty {
            number = 1
        } else if NSRegularExpression.isMatch(forPattern: "wenige|einige|paar", in: numberText) {
            number = 3
        } else {
            number = Int(numberText) ?? 1
        }

        let hasExplicitMultiplier = !numberText.isEmpty
        number *= modifier

        let prefixText = text.substring(from: 0, to: index).lowercased()
        let hasSincePrefix = NSRegularExpression.isMatch(forPattern: "\\bseit\\s*(?:der\\s+)?$", in: prefixText)
        let isLastModifier = !isNextModifier
        let hasInPrefix = NSRegularExpression.isMatch(forPattern: "\\b(im|in\\s*(der|den|dem)?)\\s*$", in: prefixText)
        var date = ref

        if NSRegularExpression.isMatch(forPattern: "tag", in: unitText) {
            date = date.added(number, .day)
            result.start.assign(.year, value: date.year)
            result.start.assign(.month, value: date.month)
            result.start.assign(.day, value: date.day)
        } else if NSRegularExpression.isMatch(forPattern: "woche", in: unitText) {
            let isSingleWeekRange = !hasExplicitMultiplier
            let shouldUseRollingRange = isSingleWeekRange && hasInPrefix && isLastModifier
            if shouldUseRollingRange {
                // "in der letzten Woche" = 7-day window ending at ref (inclusive)
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
        } else if NSRegularExpression.isMatch(forPattern: "monat", in: unitText) {
            date = date.added(number, .month)
            let isSingleMonthRange = !hasExplicitMultiplier
            let shouldUseRollingMonthRange = isSingleMonthRange && hasInPrefix && isLastModifier
            if shouldUseRollingMonthRange {
                // "im letzten Monat" = rolling window from (ref - 1 month) to ref
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
        } else if NSRegularExpression.isMatch(forPattern: "jahr", in: unitText) {
            date = date.added(number, .year)
            let isSingleYearRange = !hasExplicitMultiplier
            let shouldUseRollingYearRange = isSingleYearRange && hasInPrefix && isLastModifier
            if shouldUseRollingYearRange {
                // "im letzten Jahr" = rolling window from (ref - 1 year) to ref
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

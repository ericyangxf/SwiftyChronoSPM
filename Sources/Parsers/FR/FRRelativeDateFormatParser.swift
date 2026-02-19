//
//  FRRelativeDateFormatParser.swift
//  SwiftyChrono
//
//  Created by Codex on 2026-02-08.
//

import Foundation

// Matches patterns like:
//   "semaine dernière", "mois prochain", "année dernière"
//   "dernière semaine", "prochain mois"
//   "2 dernières semaines", "3 derniers mois", "20 derniers jours"
private let PATTERN = "(\\W|^)" +
    "(?:" +
        "(?:(\(FR_INTEGER_WORDS_PATTERN)|[0-9]+|quelques)\\s+)?" +
        "(derni[èe]re?s?|prochaine?s?)\\s+" +
        "(jours?|semaines?|mois|ann[ée]es?|ans?)" +
    "|" +
        "(?:l[ae]\\s+|l'|les\\s+|des\\s+|du\\s+)?" +
        "(jours?|semaines?|mois|ann[ée]es?|ans?)\\s+" +
        "(derni[èe]re?|prochaine?)" +
    ")" +
    "(?=\\W|$)"

// Leading modifier form groups
private let numberGroup = 2
private let leadingModifierGroup = 3
private let leadingUnitGroup = 4
// Trailing modifier form groups
private let trailingUnitGroup = 5
private let trailingModifierGroup = 6

public class FRRelativeDateFormatParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .french }

    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType : Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        result.tags[.frRelativeDateFormatParser] = true

        let modifierText: String
        let unitText: String
        let numberText: String

        if match.isNotEmpty(atRangeIndex: leadingModifierGroup) {
            // Leading modifier form: "(N) dernières semaines"
            numberText = match.isNotEmpty(atRangeIndex: numberGroup) ? match.string(from: text, atRangeIndex: numberGroup).lowercased() : ""
            modifierText = match.string(from: text, atRangeIndex: leadingModifierGroup).lowercased()
            unitText = match.string(from: text, atRangeIndex: leadingUnitGroup).lowercased()
        } else {
            // Trailing modifier form: "semaine dernière"
            numberText = ""
            modifierText = match.string(from: text, atRangeIndex: trailingModifierGroup).lowercased()
            unitText = match.string(from: text, atRangeIndex: trailingUnitGroup).lowercased()
        }

        let isNextModifier = NSRegularExpression.isMatch(forPattern: "^prochain", in: modifierText)
        let modifier = isNextModifier ? 1 : -1

        var number: Int
        if let n = FR_INTEGER_WORDS[numberText] {
            number = n
        } else if numberText.isEmpty {
            number = 1
        } else if NSRegularExpression.isMatch(forPattern: "quelques", in: numberText) {
            number = 3
        } else {
            number = Int(numberText) ?? 1
        }

        let hasExplicitMultiplier = !numberText.isEmpty
        number *= modifier

        // Detect prefix for since/in semantics
        let prefixText = text.substring(from: 0, to: index).lowercased()
        let hasSincePrefix = NSRegularExpression.isMatch(forPattern: "\\bdepuis\\s*(?:l[ea']?\\s*)?$", in: prefixText)
        let isLastModifier = !isNextModifier
        let hasInPrefix = NSRegularExpression.isMatch(forPattern: "\\bpendant\\s*(?:l[ea']?\\s*)?$", in: prefixText)
        var date = ref

        if NSRegularExpression.isMatch(forPattern: "jour", in: unitText) {
            date = date.added(number, .day)
            result.start.assign(.year, value: date.year)
            result.start.assign(.month, value: date.month)
            result.start.assign(.day, value: date.day)
        } else if NSRegularExpression.isMatch(forPattern: "semaine", in: unitText) {
            let isSingleWeekRange = !hasExplicitMultiplier
            let shouldUseRollingRange = isSingleWeekRange && hasInPrefix && isLastModifier
            if shouldUseRollingRange {
                // "pendant la semaine dernière" = 7-day window ending at ref (inclusive)
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
        } else if NSRegularExpression.isMatch(forPattern: "mois", in: unitText) {
            date = date.added(number, .month)
            let isSingleMonthRange = !hasExplicitMultiplier
            let shouldUseRollingMonthRange = isSingleMonthRange && hasInPrefix && isLastModifier
            if shouldUseRollingMonthRange {
                // "pendant le mois dernier" = rolling window from (ref - 1 month) to ref
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
        } else if NSRegularExpression.isMatch(forPattern: "ann[ée]e|ans?", in: unitText) {
            date = date.added(number, .year)
            let isSingleYearRange = !hasExplicitMultiplier
            let shouldUseRollingYearRange = isSingleYearRange && hasInPrefix && isLastModifier
            if shouldUseRollingYearRange {
                // "pendant l'année dernière" = rolling window from (ref - 1 year) to ref
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

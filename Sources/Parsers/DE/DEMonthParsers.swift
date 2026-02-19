//
//  DEMonthParsers.swift
//  SwiftyChrono
//
//  Created by Codex on 2026-01-20.
//

import Foundation

private let THIS_MONTH_PATTERN = "(^|\\s)(?:in\\s+)?(?:diesen|diesem|dieser)\\s+monat(?=\\b|\\s|$)"
private let LAST_MONTH_PATTERN = "(^|\\s)(?:(?:im|in)\\s+)?(?:letzten|letztem)\\s+monat(?=\\b|\\s|$)"

public class DEThisMonthParser: Parser {
    override var pattern: String { return THIS_MONTH_PATTERN }
    override var language: Language { return .german }

    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType: Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)

        result.start.assign(.year, value: ref.year)
        result.start.assign(.month, value: ref.month)
        result.start.assign(.day, value: 1)

        result.end = ParsedComponents(components: nil, ref: ref)
        result.end?.assign(.year, value: ref.year)
        result.end?.assign(.month, value: ref.month)
        result.end?.assign(.day, value: ref.day)

        result.tags[.deThisMonthParser] = true
        return result
    }
}

public class DELastMonthParser: Parser {
    override var pattern: String { return LAST_MONTH_PATTERN }
    override var language: Language { return .german }

    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType: Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndex(from: text, andMatchResult: match)

        // Defer to DERelativeDateFormatParser when "im"/"in" prefix is part of match for rolling window
        let matchLower = matchText.lowercased()
        if NSRegularExpression.isMatch(forPattern: "^(im|in)\\s+", in: matchLower) {
            return nil
        }

        let lastMonth = ref.added(-1, .month)
        var result = ParsedResult(ref: ref, index: index, text: matchText)

        result.start.assign(.year, value: lastMonth.year)
        result.start.assign(.month, value: lastMonth.month)
        result.start.assign(.day, value: 1)

        result.end = result.start.clone()
        let daysInMonth = lastMonth.numberOf(.day, inA: .month) ?? 0
        if daysInMonth > 0 {
            result.end?.assign(.day, value: daysInMonth)
        }

        result.tags[.deLastMonthParser] = true
        return result
    }
}

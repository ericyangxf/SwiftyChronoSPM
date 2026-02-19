//
//  ESMonthParsers.swift
//  SwiftyChrono
//
//  Created by Codex on 2026-01-20.
//

import Foundation

private let THIS_MONTH_PATTERN = "(^|\\s)(?:en\\s+)?este\\s+mes(?=\\b|\\s|$)"
private let LAST_MONTH_PATTERN = "(^|\\s)(?:(?:en\\s+)?(?:el\\s+))?mes\\s+pasado(?=\\b|\\s|$)"

public class ESThisMonthParser: Parser {
    override var pattern: String { return THIS_MONTH_PATTERN }
    override var language: Language { return .spanish }

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

        result.tags[.esThisMonthParser] = true
        return result
    }
}

public class ESLastMonthParser: Parser {
    override var pattern: String { return LAST_MONTH_PATTERN }
    override var language: Language { return .spanish }

    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType: Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndex(from: text, andMatchResult: match)

        // Defer to ESRelativeDateFormatParser when "en" prefix is part of match for rolling window
        let matchLower = matchText.lowercased()
        if NSRegularExpression.isMatch(forPattern: "^en\\s+", in: matchLower) {
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

        result.tags[.esLastMonthParser] = true
        return result
    }
}

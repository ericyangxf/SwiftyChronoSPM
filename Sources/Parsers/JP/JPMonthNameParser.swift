//
//  JPMonthNameParser.swift
//  SwiftyChrono
//
//  Parses standalone Japanese month references like:
//  7月, 2025年7月, 9月以降
//  These are month-only references (without a day number followed by 日)
//

import Foundation

// Matches: [optional year年] N月 NOT followed by a day
// Negative lookahead to avoid matching "1月15日" (that's JPStandardParser's job)
private let PATTERN =
    "(?:(\\d{4})\\s*年\\s*)?" +
    "(\\d{1,2})\\s*月" +
    "(?!\\s*\\d{1,2}\\s*日)"

private let yearGroup = 1
private let monthGroup = 2

public class JPMonthNameParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .japanese }

    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType: Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndexForCHHant(from: text, andMatchResult: match)

        let monthString = match.string(from: text, atRangeIndex: monthGroup)
        guard let month = Int(monthString.hankakuOnlyNumber), month >= 1, month <= 12 else {
            return nil
        }

        var result = ParsedResult(ref: ref, index: index, text: matchText)

        let opensRange = JPStartsOpenEndedRange(in: text, matchEndIndex: index + matchText.count)

        if match.isNotEmpty(atRangeIndex: yearGroup) {
            let yearText = match.string(from: text, atRangeIndex: yearGroup)
            var year = Int(yearText.hankakuOnlyNumber) ?? 0
            if year < 100 {
                year += 2000
            }
            result.start.assign(.year, value: year)
            result.start.assign(.month, value: month)
            result.start.imply(.day, to: 1)
            result.yearText = yearText

            if opensRange {
                // "2025年7月以降" -> start = July 1, end = refDate
                applyOpenRangeEnd(to: &result, ref: ref)
            }
        } else if opensRange {
            applySinceRange(to: &result, month: month, day: 1, isDayCertain: false, ref: ref)
        } else {
            // Pick the closest year for this month
            var refMoment = ref
            refMoment = refMoment.setOrAdded(month, .month)
            refMoment = refMoment.setOrAdded(1, .day)

            let nextYear = refMoment.added(1, .year)
            let lastYear = refMoment.added(-1, .year)
            if abs(nextYear.differenceOfTimeInterval(to: ref)) < abs(refMoment.differenceOfTimeInterval(to: ref)) {
                refMoment = nextYear
            } else if abs(lastYear.differenceOfTimeInterval(to: ref)) < abs(refMoment.differenceOfTimeInterval(to: ref)) {
                refMoment = lastYear
            }

            result.start.assign(.month, value: month)
            result.start.imply(.day, to: 1)
            result.start.imply(.year, to: refMoment.year)
        }

        result.tags[.jpMonthNameParser] = true
        return result
    }
}

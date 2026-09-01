//
//  FRMonthNameParser.swift
//  SwiftyChrono
//
//  Created by Codex on 2026-02-09.
//

import Foundation

private let PATTERN = "(^|\\D\\s+|[^\\w\\s])" +
    "(Jan(?:vier|\\.)?|F[ée]v(?:rier|\\.)?|Mars|Avr(?:il|\\.)?|Mai|Juin|Juil(?:let|\\.)?|Ao[uû]t|Sept(?:embre|\\.)?|Oct(?:obre|\\.)?|Nov(?:embre|\\.)?|[Dd][ée]c(?:embre|\\.)?)" +
    "\\s*" +
    "(?:" +
        "[,-]?\\s*([0-9]{4})" +
    ")?" +
    "(?=[^\\s\\w]|\\s+[^0-9]|\\s+$|$)"

private let monthNameGroup = 2
private let yearGroup = 3

public class FRMonthNameParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .french }

    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType: Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)

        let monthStr = match.string(from: text, atRangeIndex: monthNameGroup).lowercased()
        guard let month = FR_MONTH_OFFSET[monthStr] else {
            return nil
        }

        let day = 1

        if match.isNotEmpty(atRangeIndex: yearGroup) {
            let yearText = match.string(from: text, atRangeIndex: yearGroup)
            var year = Int(yearText) ?? 0
            if year < 100 {
                year += 2000
            }

            result.start.imply(.day, to: day)
            result.start.assign(.month, value: month)
            result.start.assign(.year, value: year)
            result.yearText = yearText
        } else if FRStartsOpenEndedRange(in: text, matchIndex: index, matchEndIndex: index + matchText.count) {
            applySinceRange(to: &result, month: month, day: day, isDayCertain: false, ref: ref)
        } else {
            var refMoment = ref
            refMoment = refMoment.setOrAdded(month, .month)
            refMoment = refMoment.setOrAdded(day, .day)

            let nextYear = refMoment.added(1, .year)
            let lastYear = refMoment.added(-1, .year)
            if abs(nextYear.differenceOfTimeInterval(to: ref)) < abs(refMoment.differenceOfTimeInterval(to: ref)) {
                refMoment = nextYear
            } else if abs(lastYear.differenceOfTimeInterval(to: ref)) < abs(refMoment.differenceOfTimeInterval(to: ref)) {
                refMoment = lastYear
            }

            result.start.imply(.day, to: day)
            result.start.assign(.month, value: month)
            result.start.imply(.year, to: refMoment.year)
        }

        result.tags[.frMonthNameParser] = true
        return result
    }

}

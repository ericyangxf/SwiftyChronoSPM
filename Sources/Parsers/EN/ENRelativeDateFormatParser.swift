//
//  ENRelativeDateFormatParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/23/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "(\\W|^)" +
    "(next|last|past)\\s*" +
    "(\(EN_INTEGER_WORDS_PATTERN)|[0-9]+|few|half(?:\\s*an?)?)?\\s*" +
    "(seconds?|min(?:ute)?s?|hours?|days?|weeks?|months?|years?)(?=\\s*)" +
    "(?=\\W|$)"

private let modifierWordGroup = 2
private let multiplierWordGroup = 3
private let relativeWordGroup = 4



public class ENRelativeDateFormatParser: Parser {
    override var pattern: String { return PATTERN }
    
    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType: Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        let modifierText = match.isNotEmpty(atRangeIndex: modifierWordGroup) ? match.string(from: text, atRangeIndex: modifierWordGroup).lowercased() : ""
        let isNextModifier = NSRegularExpression.isMatch(forPattern: "^next", in: modifierText)
        let isLastModifier = NSRegularExpression.isMatch(forPattern: "^last", in: modifierText)
        let modifier = isNextModifier ? 1 : -1
        result.tags[.enRelativeDateFormatParser] = true
        
        var number: Int
        let numberText = match.isNotEmpty(atRangeIndex: multiplierWordGroup) ? match.string(from: text, atRangeIndex: multiplierWordGroup).lowercased() : ""
        if let number0 = EN_INTEGER_WORDS[numberText] {
            number = number0
        } else if numberText == "" {
            number = 1
        } else if NSRegularExpression.isMatch(forPattern: "few", in: numberText) {
            number = 3
        } else if NSRegularExpression.isMatch(forPattern: "half", in: numberText) {
            number = HALF
        } else {
            number = Int(numberText) ?? 0
        }
        
        let isHalf = number == HALF
        number *= modifier
        let hasExplicitMultiplier = !numberText.isEmpty
        let prefixText = text.substring(from: 0, to: index).lowercased()
        let hasSincePrefix = NSRegularExpression.isMatch(forPattern: "\\bsince\\s*$", in: prefixText)
        let hasInPrefix = NSRegularExpression.isMatch(forPattern: "\\bin\\s*(the\\s*)?$", in: prefixText)

        var date = ref
        if match.isNotEmpty(atRangeIndex: relativeWordGroup) {
            let relativeWord = match.string(from: text, atRangeIndex: relativeWordGroup)
            
            if NSRegularExpression.isMatch(forPattern: "day", in: relativeWord) {
                date = isHalf ? date.added(modifier * 12 , .hour) : date.added(number, .day)
                result.start.assign(.year, value: date.year)
                result.start.assign(.month, value: date.month)
                result.start.assign(.day, value: date.day)
            } else if NSRegularExpression.isMatch(forPattern: "week", in: relativeWord) {
                let isSingleWeekRange = !hasExplicitMultiplier && !isHalf
                let shouldUseCalendarWeekRange = isSingleWeekRange && (isLastModifier || isNextModifier || hasSincePrefix)
                let shouldUseRollingRange = isSingleWeekRange && hasInPrefix && isLastModifier
                if shouldUseRollingRange {
                    // "in the last week" = 7-day window ending at ref (inclusive)
                    let rangeStart = ref.added(-6, .day)
                    result.start.assign(.year, value: rangeStart.year)
                    result.start.assign(.month, value: rangeStart.month)
                    result.start.assign(.day, value: rangeStart.day)

                    result.end = ParsedComponents(components: nil, ref: result.start.date)
                    result.end?.assign(.year, value: ref.year)
                    result.end?.assign(.month, value: ref.month)
                    result.end?.assign(.day, value: ref.day)
                } else if shouldUseCalendarWeekRange {
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
                    date = isHalf ? date.added(modifier * 3, .day).added(number * 12 , .hour) : date.added(number * 7, .day)
                    // We don't know the exact date for next/last week so we imply
                    // them
                    result.start.imply(.day, to: date.day)
                    result.start.imply(.month, to: date.month)
                    result.start.imply(.year, to: date.year)
                }
            } else if NSRegularExpression.isMatch(forPattern: "month", in: relativeWord) {
                date = isHalf ? date.added(modifier * (date.numberOf(.day, inA: .month) ?? 30)/2 , .day) : date.added(number * 1, .month)
                let isSingleMonthRange = !hasExplicitMultiplier && !isHalf
                let shouldUseRollingMonthRange = isSingleMonthRange && hasInPrefix && isLastModifier
                if shouldUseRollingMonthRange {
                    // "in the last month" = rolling window from (ref - 1 month) to ref
                    let rangeStart = ref.added(-1, .month)
                    result.start.assign(.year, value: rangeStart.year)
                    result.start.assign(.month, value: rangeStart.month)
                    result.start.assign(.day, value: rangeStart.day)

                    result.end = ParsedComponents(components: nil, ref: result.start.date)
                    result.end?.assign(.year, value: ref.year)
                    result.end?.assign(.month, value: ref.month)
                    result.end?.assign(.day, value: ref.day)
                } else if isSingleMonthRange {
                    if hasSincePrefix {
                        result.start.assign(.day, value: 1)
                        result.start.assign(.month, value: date.month)
                        result.start.assign(.year, value: date.year)
                    } else {
                        result.start.assign(.day, value: 1)
                        result.start.assign(.month, value: date.month)
                        result.start.assign(.year, value: date.year)
                        result.end = ParsedComponents(components: nil, ref: result.start.date)
                        result.end?.assign(.year, value: date.year)
                        result.end?.assign(.month, value: date.month)
                        let daysInMonth = date.numberOf(.day, inA: .month) ?? 0
                        if daysInMonth > 0 {
                            result.end?.assign(.day, value: daysInMonth)
                        }
                    }
                } else {
                    // We don't know the exact day for next/last month
                    result.start.imply(.day, to: date.day)
                    result.start.assign(.year, value: date.year)
                    result.start.assign(.month, value: date.month)
                }
            } else if NSRegularExpression.isMatch(forPattern: "year", in: relativeWord) {
                date = isHalf ? date.added(modifier * 6 , .month) : date.added(number, .year)
                let isSingleYearRange = !hasExplicitMultiplier && !isHalf
                let shouldUseRollingYearRange = isSingleYearRange && hasInPrefix && isLastModifier
                if shouldUseRollingYearRange {
                    // "in the last year" = rolling window from (ref - 1 year) to ref
                    let rangeStart = ref.added(-1, .year)
                    result.start.assign(.year, value: rangeStart.year)
                    result.start.assign(.month, value: rangeStart.month)
                    result.start.assign(.day, value: rangeStart.day)

                    result.end = ParsedComponents(components: nil, ref: result.start.date)
                    result.end?.assign(.year, value: ref.year)
                    result.end?.assign(.month, value: ref.month)
                    result.end?.assign(.day, value: ref.day)
                } else if isSingleYearRange {
                    if hasSincePrefix {
                        result.start.imply(.day, to: 1)
                        result.start.imply(.month, to: 1)
                        result.start.assign(.year, value: date.year)
                    } else {
                        result.start.imply(.day, to: 1)
                        result.start.imply(.month, to: 1)
                        result.start.assign(.year, value: date.year)
                        result.end = ParsedComponents(components: nil, ref: result.start.date)
                        result.end?.assign(.year, value: date.year)
                        result.end?.assign(.month, value: 12)
                        result.end?.assign(.day, value: 31)
                    }
                } else {
                    result.start.imply(.day, to: date.day)
                    result.start.imply(.month, to: date.month)
                    result.start.assign(.year, value: date.year)
                }
            }
            
            return result
        }
        
        let relativeWord = match.isNotEmpty(atRangeIndex: relativeWordGroup) ? match.string(from: text, atRangeIndex: relativeWordGroup) : ""
        
        if NSRegularExpression.isMatch(forPattern: "hour", in: relativeWord) {
            date = isHalf ? date.added(modifier * 30, .minute) : date.added(number, .hour)
            result.start.imply(.minute, to: date.minute)
            result.start.imply(.second, to: date.second)
        } else if NSRegularExpression.isMatch(forPattern: "min", in: relativeWord) {
            date = isHalf ? date.added(modifier * 30, .second) : date.added(number, .minute)
            result.start.assign(.minute, value: date.minute)
            result.start.imply(.second, to: date.second)
        } else if NSRegularExpression.isMatch(forPattern: "second", in: relativeWord) {
            date = isHalf ? date.added(modifier * HALF_SECOND_IN_MS, .nanosecond) : date.added(number, .second)
            result.start.assign(.minute, value: date.minute)
            result.start.assign(.second, value: date.second)
        }
        
        result.start.assign(.hour, value: date.hour)
        result.start.assign(.year, value: date.year)
        result.start.assign(.month, value: date.month)
        result.start.assign(.day, value: date.day)
        return result
    }
}

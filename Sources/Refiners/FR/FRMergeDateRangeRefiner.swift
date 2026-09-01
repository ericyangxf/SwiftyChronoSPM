//
//  FRMergeDateRangeRefiner.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/6/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

class FRMergeDateRangeRefiner: MergeDateRangeRefiner {
    override var PATTERN: String { return "^\\s*(?:à|au|a|jusqu[’']a[u]?|jusqu[’']à)\\s*(?:l[ea’']\\s*)?$|^\\s*\\-\\s*$" }
    override var TAGS: TagUnit { return .frMergeDateRangeRefiner }

    override func isAbleToMerge(text: String, result1: ParsedResult, result2: ParsedResult) -> Bool {
        if super.isAbleToMerge(text: text, result1: result1, result2: result2) {
            return true
        }

        let (startIndex, endIndex) = sortTwoNumbers(result1.index + result1.text.count, result2.index)
        let textBetween = text.substring(from: startIndex, to: endIndex)
        guard NSRegularExpression.isMatch(forPattern: "^\\s*et\\s+(?:l[ea']?\\s*)?$", in: textBetween) else {
            return false
        }

        let prefixText = text.substring(from: 0, to: result1.index)
        return NSRegularExpression.isMatch(forPattern: "\\bentre\\s+(?:l[ea']?\\s*)?$", in: prefixText)
    }
}

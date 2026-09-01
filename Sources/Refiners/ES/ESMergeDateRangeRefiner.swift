//
//  ESMergeDateRangeRefiner.swift
//  SwiftyChrono
//
//  Created by Codex on 2026-01-20.
//

import Foundation

class ESMergeDateRangeRefiner: MergeDateRangeRefiner {
    override var PATTERN: String { return "^\\s*(?:a|al|hasta)\\s*(?:el\\s*)?$|^\\s*\\-\\s*$" }
    override var TAGS: TagUnit { return .esMergeDateRangeRefiner }

    override func isAbleToMerge(text: String, result1: ParsedResult, result2: ParsedResult) -> Bool {
        if super.isAbleToMerge(text: text, result1: result1, result2: result2) {
            return true
        }

        let (startIndex, endIndex) = sortTwoNumbers(result1.index + result1.text.count, result2.index)
        let textBetween = text.substring(from: startIndex, to: endIndex)
        guard NSRegularExpression.isMatch(forPattern: "^\\s*(y|e)\\s*(?:el\\s*)?$", in: textBetween) else {
            return false
        }

        let prefixText = text.substring(from: 0, to: result1.index)
        return NSRegularExpression.isMatch(forPattern: "\\bentre\\s*(?:el\\s*)?$", in: prefixText)
    }
}

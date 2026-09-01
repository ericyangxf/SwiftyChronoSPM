//
//  ESUtil.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/6/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

let ES_WEEKDAY_OFFSET = [
    "domingo": 0,
    "dom": 0,
    "lunes": 1,
    "lun": 1,
    "martes": 2,
    "mar":2,
    "miércoles": 3,
    "miercoles": 3,
    "mie": 3,
    "jueves": 4,
    "jue": 4,
    "viernes": 5,
    "vier": 5,
    "vie": 5,
    "sábado": 6,
    "sabado": 6,
    "sab": 6,
]

let ES_INTEGER_WORDS_PATTERN = "un[oa]?|dos|tres|cuatro|cinco|seis|siete|ocho|nueve|diez|once|doce"

let ES_INTEGER_WORDS: [String: Int] = [
    "un": 1, "una": 1, "uno": 1,
    "dos": 2, "tres": 3, "cuatro": 4,
    "cinco": 5, "seis": 6, "siete": 7,
    "ocho": 8, "nueve": 9, "diez": 10,
    "once": 11, "doce": 12,
]

let ES_MONTH_OFFSET = [
    "enero": 1,
    "ene": 1,
    "ene.": 1,
    "febrero": 2,
    "feb": 2,
    "feb.": 2,
    "marzo": 3,
    "mar": 3,
    "mar.": 3,
    "abril": 4,
    "abr": 4,
    "abr.": 4,
    "mayo": 5,
    "may": 5,
    "may.": 5,
    "junio": 6,
    "jun": 6,
    "jun.": 6,
    "julio": 7,
    "jul": 7,
    "jul.": 7,
    "agosto": 8,
    "ago": 8,
    "ago.": 8,
    "septiembre": 9,
    "sep": 9,
    "sept": 9,
    "sep.": 9,
    "sept.": 9,
    "octubre": 10,
    "oct": 10,
    "oct.": 10,
    "noviembre": 11,
    "nov": 11,
    "nov.": 11,
    "diciembre": 12,
    "dic": 12,
    "dic.": 12,
]

/// True when "desde" or "a partir de" immediately precedes the match, opening a range that
/// looks backward from the reference date: "desde marzo", "a partir del 20 de marzo".
/// An explicit range ("de marzo a junio") is excluded and left to the range refiner.
func ESStartsOpenEndedRange(in text: String, matchIndex: Int, matchEndIndex: Int) -> Bool {
    let prefixText = text.substring(from: 0, to: matchIndex).lowercased()
    guard NSRegularExpression.isMatch(forPattern: "(?:^|\\s)(?:desde|a\\s+partir\\s+de)l?\\s*(?:el\\s+)?$", in: prefixText) else {
        return false
    }

    let suffixText = text.substring(from: matchEndIndex).lowercased()
    return !NSRegularExpression.isMatch(forPattern: "^\\s*(?:(?:a|al|hasta|y|e)\\b|[-–—])", in: suffixText)
}

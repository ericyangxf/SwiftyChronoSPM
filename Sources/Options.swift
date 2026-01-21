//
//  Options.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/18/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

public struct ModeOptio {
    var parsers: [Parser]
    var refiners: [Refiner]
    
    init(parsers: [Parser], refiners: [Refiner]) {
        self.parsers = parsers
        self.refiners = refiners
    }
}

private func baseOption(strictMode: Bool) -> ModeOptio {
    return ModeOptio(parsers: [
        // EN
        ENISOFormatParser(strictMode: strictMode),
        ENDeadlineFormatParser(strictMode: strictMode),
        ENMonthNameLittleEndianParser(strictMode: strictMode),
        ENMonthNameMiddleEndianParser(strictMode: strictMode),
        ENMonthNameParser(strictMode: strictMode),
        ENYearParser(strictMode: strictMode),
        ENThisYearParser(strictMode: strictMode),
        ENThisMonthParser(strictMode: strictMode),
        ENSinceYearParser(strictMode: strictMode),
        ENFromYearParser(strictMode: strictMode),
        ENSlashDateFormatParser(strictMode: strictMode),
        ENSlashDateFormatStartWithYearParser(strictMode: strictMode),
        ENSlashMonthFormatParser(strictMode: strictMode),
        ENTimeAgoFormatParser(strictMode: strictMode),
        // ENTimeExpressionParser disabled - date parsing only

        // JP
        JPYearParser(strictMode: strictMode),
        JPThisYearParser(strictMode: strictMode),
        JPLastYearParser(strictMode: strictMode),
        JPSinceYearParser(strictMode: strictMode),
        JPFromYearParser(strictMode: strictMode),
        JPThisMonthParser(strictMode: strictMode),
        JPLastMonthParser(strictMode: strictMode),
        JPStandardParser(strictMode: strictMode),

        // ES
        ESYearParser(strictMode: strictMode),
        ESThisYearParser(strictMode: strictMode),
        ESLastYearParser(strictMode: strictMode),
        ESSinceYearParser(strictMode: strictMode),
        ESFromYearParser(strictMode: strictMode),
        ESThisMonthParser(strictMode: strictMode),
        ESLastMonthParser(strictMode: strictMode),
        ESTimeAgoFormatParser(strictMode: strictMode),
        ESDeadlineFormatParser(strictMode: strictMode),
        // ESTimeExpressionParser disabled - date parsing only
        ESMonthNameLittleEndianParser(strictMode: strictMode),
        ESSlashDateFormatParser(strictMode: strictMode),

        // FR
        FRYearParser(strictMode: strictMode),
        FRThisYearParser(strictMode: strictMode),
        FRLastYearParser(strictMode: strictMode),
        FRSinceYearParser(strictMode: strictMode),
        FRFromYearParser(strictMode: strictMode),
        FRThisMonthParser(strictMode: strictMode),
        FRLastMonthParser(strictMode: strictMode),
        FRDeadlineFormatParser(strictMode: strictMode),
        FRMonthNameLittleEndianParser(strictMode: strictMode),
        FRSlashDateFormatParser(strictMode: strictMode),
        FRTimeAgoFormatParser(strictMode: strictMode),
        // FRTimeExpressionParser disabled - date parsing only

        // DE
        DEYearParser(strictMode: strictMode),
        DEThisYearParser(strictMode: strictMode),
        DELastYearParser(strictMode: strictMode),
        DESinceYearParser(strictMode: strictMode),
        DEFromYearParser(strictMode: strictMode),
        DEThisMonthParser(strictMode: strictMode),
        DELastMonthParser(strictMode: strictMode),
        DEDeadlineFormatParser(strictMode: strictMode),
        DEMonthNameLittleEndianParser(strictMode: strictMode),
        DESlashDateFormatParser(strictMode: strictMode),
        DETimeAgoFormatParser(strictMode: strictMode),
        // DETimeExpressionParser disabled - date parsing only

        // ZH-Hant
        ZHYearParser(strictMode: strictMode),
        ZHThisYearParser(strictMode: strictMode),
        ZHLastYearParser(strictMode: strictMode),
        ZHSinceYearParser(strictMode: strictMode),
        ZHFromYearParser(strictMode: strictMode),
        ZHThisMonthParser(strictMode: strictMode),
        ZHLastMonthParser(strictMode: strictMode),
        ZHCasualDateParser(strictMode: strictMode),
        ZHDateParser(strictMode: strictMode),
        ZHDeadlineFormatParser(strictMode: strictMode),
        // ZHTimeExpressionParser disabled - date parsing only
        ZHWeekdayParser(strictMode: strictMode),

    ], refiners: [
        // Removing overlaping first
        YearRemovalRefiner(),
        OverlapRemovalRefiner(),

        // ETC
        ENMergeDateRangeRefiner(),
        ENPrioritizeSpecificDateRefiner(),
        ESMergeDateRangeRefiner(),
        FRMergeDateRangeRefiner(),
        JPMergeDateRangeRefiner(),
        DEMergeDateRangeRefiner(),

        ForwardDateRefiner(),
        BackwardDateRefiner(),

        UnlikelyFormatFilter(),
    ])
}

func strictModeOption() -> ModeOptio {
    return baseOption(strictMode: true)
}

public func casualModeOption() -> ModeOptio {
    var options = baseOption(strictMode: false)

    options.parsers.insert(contentsOf: [
        // EN
        // ENCasualTimeParser disabled - date parsing only
        ENCasualDateParser(strictMode: false),
        ENWeekdayParser(strictMode: false),
        ENRelativeDateFormatParser(strictMode: false),

        // JP
        JPCasualDateParser(strictMode: false),

        // ES
        ESCasualDateParser(strictMode: false),
        ESWeekdayParser(strictMode: false),

        // FR
        FRCasualDateParser(strictMode: false),
        FRWeekdayParser(strictMode: false),

        // DE
        // DECasualTimeParser disabled - date parsing only
        DECasualDateParser(strictMode: false),
        DEWeekdayParser(strictMode: false),
        // DEMorgenTimeParser disabled - date parsing only

    ], at: 0)

    return options
}

public enum Language {
    case english, spanish, french, japanese, german, chinese
}

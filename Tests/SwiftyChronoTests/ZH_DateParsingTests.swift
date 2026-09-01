//
//  DateParsingTests.swift
//  SwiftyChrono
//
//  Comprehensive test cases for chinese date parsing
//

import Foundation
import Testing
@testable import SwiftyChronoX

struct ZH_DateParsingTests {

    // MARK: - Helper Functions

    func dateComponents(date: Date, calendar: Calendar = Calendar(identifier: .gregorian)) -> DateComponents {
        return calendar.dateComponents([.year, .month, .day], from: date)
    }

    func createRefDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        return Calendar(identifier: .gregorian).date(from: components)!
    }

    // MARK: - Test 1-10: Casual Date Expressions

    @Test func test001_Today() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "我今天有个会议", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test002_Tomorrow() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "我们明天见", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test003_Yesterday() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "昨天发生了什么", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test004_Now() async throws {
        // Note: "Do it now" would cause German parser to match "Do" as Thursday (Donnerstag)
        // Using "Right now" to test the "now" keyword specifically
        Chrono.preferredLanguage = .chinese
        defer { Chrono.preferredLanguage = nil }
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "立即去做", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test005_Tonight() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "今晚我们出去吧", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test006_LastNight() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "我昨晚睡得很好", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test007_TomorrowAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "明天见", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test008_TodayWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "给我看今天的所有交易", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test009_YesterdayWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "我昨天在商店买了什么", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test010_TomorrowWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "提醒我明天去付账单", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    // MARK: - Test 11-20: Relative Date Expressions (Last/Next/Past)

    @Test func test011_LastWeek() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "显示上周的支出", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 12)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 18)
    }

    @Test func test012_NextWeek() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "下周的安排", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 26)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 2)
        #expect(endComponents.day == 1)
    }

    @Test func test013_LastMonth() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "显示上个月的支出", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2025)
        #expect(endComponents.month == 12)
        #expect(endComponents.day == 31)
    }

    @Test func test014_NextMonth() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "下个月的预算", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 2)
        #expect(endComponents.day == 28)
    }

    @Test func test015_LastYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "去年的报告", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2025)
        #expect(endComponents.month == 12)
        #expect(endComponents.day == 31)
    }

    @Test func test016_NextYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "明年的计划", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2027)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2027)
        #expect(endComponents.month == 12)
        #expect(endComponents.day == 31)
    }

    @Test func test017_PastWeek() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "过去一周的交易", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 13)
    }

    @Test func test018_Past2Weeks() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "给我看过去2周的订单", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 6)
    }

    @Test func test019_Past3Months() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "过去3个月的销售", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test020_Past2Years() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "显示过去2年的交易", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2024)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    // MARK: - Test 21-30: Time Ago Expressions

    @Test func test021_DaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "会议是在5天前", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
    }

    @Test func test022_WeeksAgo() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "我在2周前买了它", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 6)
    }

    @Test func test023_MonthsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "我在3个月前订阅了", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test024_YearsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "这家公司成立于5年前", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2021)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test025_AWeekAgo() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "我在一周前见过他", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 13)
    }

    @Test func test026_AMonthAgo() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "付款在一个月前收到", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 20)
    }

    @Test func test027_AYearAgo() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "我在一年前开始在这里工作", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test028_FewDaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "我在几天前收到了它", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 17)
    }

    @Test func test029_TenDaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "订单在10天前下达", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 10)
    }

    @Test func test030_SixMonthsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "上次评审是在6个月前", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 20)
    }

    // MARK: - Test 31-40: Month Names

    @Test func test031_MonthNameOnly() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "7月的支出", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2025)
        #expect(endComponents.month == 7)
        #expect(endComponents.day == 31)
    }

    @Test func test032_MonthNameWithYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "2025年3月的收入", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 3)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2025)
        #expect(endComponents.month == 3)
        #expect(endComponents.day == 31)
    }

    @Test func test033_MonthNameWithDay() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "1月15日开会", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test034_MonthNameWithDayAndYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "2025年12月25日的活动", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test035_MonthAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "1月的报告", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 31)
    }

    @Test func test036_MonthAbbreviatedWithPeriod() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "2月14日见", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 14)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test037_OrdinalDate() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "3月1日见面", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test038_OrdinalDate2nd() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "付款截止到4月2日", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 4)
        #expect(components.day == 2)
    }

    @Test func test039_OrdinalDate3rd() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "截止到5月3日", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 5)
        #expect(components.day == 3)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test040_OrdinalDate4th() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "独立日是7月4日", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 7)
        #expect(components.day == 4)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    // MARK: - Test 41-50: Date Formats (Slash, ISO)

    @Test func test041_SlashFormatMMDD() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "1月15日开会", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test042_SlashFormatMMDDYYYY() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "发票日期是12/25/2025", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test043_SlashFormatMMDDYY() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "日期: 03/15/25", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 3)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test044_ISOFormat() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "创建于2025-07-04", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 4)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test045_DashFormatDDMMYYYY() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "15-06-2025的记录", refDate: refDate, opt: [.littleEndian: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 6)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test046_DotFormat() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "来自10.05.2025的记录", refDate: refDate, opt: [.littleEndian: 1])
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 5)
        #expect(components.day == 10)
    }

    @Test func test047_LittleEndianFormat() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "活动在25/12/2025", refDate: refDate, opt: [.littleEndian: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test048_ISOFormatInSentence() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "截止日期是2025-12-31", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 31)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test049_SlashFormatWithWeekday() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "星期一 1/20/2026", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test050_ISOFormatNoSeparator() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "活动在2025-01-01", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    // MARK: - Test 51-60: Year Expressions

    @Test func test051_InYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "2025年的收入", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2025)
        #expect(endComponents.month == 12)
        #expect(endComponents.day == 31)
    }

    @Test func test052_DuringYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "2024年的支出", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2024)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2024)
        #expect(endComponents.month == 12)
        #expect(endComponents.day == 31)
    }

    @Test func test053_ForYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "2023年的预算", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2023)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2023)
        #expect(endComponents.month == 12)
        #expect(endComponents.day == 31)
    }

    @Test func test054_SinceYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "自2024年以来的交易", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2024)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 20)
    }

    @Test func test055_FromYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "来自2023年的数据", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2023)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 20)
    }

    @Test func test056_ThisYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "今年的销售", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 20)
    }

    @Test func test057_InTheYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "2022年发生了什么", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2022)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2022)
        #expect(endComponents.month == 12)
        #expect(endComponents.day == 31)
    }

    @Test func test058_YearOnly() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "2021年的总结", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2021)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2021)
        #expect(endComponents.month == 12)
        #expect(endComponents.day == 31)
    }

    @Test func test059_InYearWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "我在2025年餐厅花了多少钱", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2025)
        #expect(endComponents.month == 12)
        #expect(endComponents.day == 31)
    }

    @Test func test060_SinceYearWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "跟踪我自2020年以来的支出", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2020)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 20)
    }

    // MARK: - Test 61-70: Weekday Expressions

    @Test func test061_OnMonday() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "星期一开会", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19) // Previous Monday
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test062_NextMonday() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "下周一见", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 26)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test063_LastFriday() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "上周五的报告", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 16)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test064_ThisWednesday() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "这周三可以", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test065_OnSaturday() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "周六的聚会", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 24 || components.day == 17) // Either upcoming or recent
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test066_NextSunday() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "下周日去徒步吧", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test067_LastThursday() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "上周四开会", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test068_WeekdayAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "显示我周二的支出", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test069_PastTuesday() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "那发生在上周二", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 13)
    }

    @Test func test070_FridayThisWeek() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "这周五", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 23)
    }

    // MARK: - Test 71-80: This Month / In Days

    @Test func test071_ThisMonth() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "这个月的支出", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 20)
    }

    @Test func test072_InXDays() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "5天内到期", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 25)
    }

    @Test func test073_InAWeek() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "一周后再检查", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 27)
    }

    @Test func test074_InTwoWeeks() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "两周后截止", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 3)
    }

    @Test func test075_InAMonth() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "一个月后复查", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 20)
    }

    @Test func test076_In3Months() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "3个月后季度复查", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 4)
        #expect(components.day == 20)
    }

    @Test func test077_InAYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "一年后续订", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2027)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test078_Within2Days() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "请在2天内回复", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 22)
    }

    @Test func test079_Past20Days() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "过去20天的支出", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 31)
    }

    @Test func test080_Past30Days() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "过去30天的报告", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 21)
    }

    // MARK: - Test 81-90: Date Ranges

    @Test func test081_BetweenMonths() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "2024年7月到2025年1月之间的收入", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2024)
        #expect(components.month == 7)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2025)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 31)
    }

    @Test func test082_FromToMonths() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "2025年3月到6月的销售", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 3)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2025)
        #expect(endComponents.month == 6)
        #expect(endComponents.day == 30)
    }

    @Test func test083_FromMonthYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "来自2024年7月的报告", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2024)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test084_DateRangeWithDays() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "1月15日到1月20日的会议", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 20)
    }

    @Test func test085_BetweenDates() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "2025年12月20日到12月31日之间的假期", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 20)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2025)
        #expect(endComponents.month == 12)
        #expect(endComponents.day == 31)
    }

    @Test func test086_January15To20() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "1月15日到20日可用", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 20)
    }

    @Test func test087_FromToYears() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "2020年到2025年的数据", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2020)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2025)
        #expect(endComponents.month == 12)
        #expect(endComponents.day == 31)
    }

    @Test func test088_SinceMonth() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "自9月以来的交易", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 9)
        #expect(components.day == 1)
    }

    @Test func test089_UntilDate() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "有效期到2026年12月31日", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 12)
        #expect(components.day == 31)
    }

    @Test func test090_ThroughDate() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "营业到3月15日", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 15)
    }

    // MARK: - Test 91-100: Complex Sentences / Edge Cases

    @Test func test091_SpendingAtStarbucksSinceJuly() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "自2025年7月以来我在星巴克花了多少钱", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test092_TopSpendingInMonth() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "列出我7月支出最高的10笔", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test093_TransactionsLastQuarter() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "显示过去3个月的所有交易", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test094_PurchasesOnSpecificDate() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "我在2025年12月25日买了什么", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
    }

    @Test func test095_BillsDueNextMonth() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "下个月有哪些账单到期", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 2)
        #expect(endComponents.day == 28)
    }

    @Test func test096_ExpensesThisWeek() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        // "this week" may not parse directly - this tests the parser
        let result = chrono.parse(text: "显示本周的支出", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
    }

    @Test func test097_IncomeYearToDate() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "今年总收入", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 20)
    }

    @Test func test098_AppointmentNextWeekday() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "下周四的医生预约", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 29)
    }

    @Test func test099_EndOfMonth() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "截止到1月31日", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 31)
    }

    @Test func test100_LeapYearDate() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "2024年2月29日的活动", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2024)
        #expect(components.month == 2)
        #expect(components.day == 29)
    }
    
    // MARK: - More Edge Cases

    @Test
    func test101_SinceLastYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "显示我自去年以来的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 1)
    }

    @Test
    func test102_LastYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "显示我去年的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2025)
        #expect(endComponents.month == 12)
        #expect(endComponents.day == 31)
    }

    @Test
    func test103_InTheLastYear() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "显示我过去1年的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 20)
    }

    @Test
    func test104_SinceLastMonth() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "显示我自上个月以来的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 12)
        #expect(startComponents.day == 1)
    }

    @Test
    func test105_LastMonth() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "显示我上个月的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 12)
        #expect(startComponents.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2025)
        #expect(endComponents.month == 12)
        #expect(endComponents.day == 31)
    }

    @Test
    func test106_InTheLastMonth() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "显示我过去1个月的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 12)
        #expect(startComponents.day == 20)
    }

    @Test
    func test107_SinceLastWeek() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "显示我自上周以来的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 12)
    }

    @Test
    func test108_LastWeek() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "显示我上周的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 12)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 18)
    }

    @Test
    func test109_InTheLastWeek() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "显示我过去1周的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 13)
    }

    @Test
    func test110_SinceMarch() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "显示我自3月以来的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 3)
        #expect(startComponents.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 9)
        #expect(endComponents.day == 1)
    }


    @Test
    func test111_SinceMarch20() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "显示我自3月20日以来的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 3)
        #expect(startComponents.day == 20)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 9)
        #expect(endComponents.day == 1)
    }

    @Test
    func test112_SinceMarch20ToYesterday() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "显示我自3月20日到昨天的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 3)
        #expect(startComponents.day == 20)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 8)
        #expect(endComponents.day == 31)
    }

    @Test
    func test113_FromMarch() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "显示我从3月开始的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 3)
        #expect(startComponents.day == 1)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 9)
        #expect(endComponents.day == 1)
    }

    @Test
    func test114_FromMarch20() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "显示我从3月20日开始的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 3)
        #expect(startComponents.day == 20)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 9)
        #expect(endComponents.day == 1)
    }

    @Test
    func test115_FromMarch20ToYesterday() async throws {
        let chrono = Chrono(preferredLanguage: .chinese)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "显示我从3月20日到昨天的支出记录", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 3)
        #expect(startComponents.day == 20)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 8)
        #expect(endComponents.day == 31)
    }
}

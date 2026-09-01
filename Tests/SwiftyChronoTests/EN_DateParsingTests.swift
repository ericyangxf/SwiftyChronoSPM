//
//  DateParsingTests.swift
//  SwiftyChrono
//
//  Comprehensive test cases for English date parsing
//

import Foundation
import Testing
@testable import SwiftyChronoX

struct EN_DateParsingTests {

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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "I have a meeting today", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test002_Tomorrow() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Let's meet tomorrow", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test003_Yesterday() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "What happened yesterday?", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Do it now", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test005_Tonight() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Let's go out tonight", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test006_LastNight() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "I slept well last night", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test007_TomorrowAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "See you tmr", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test008_TodayWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show me all transactions from today", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test009_YesterdayWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "What did I buy yesterday at the store?", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test010_TomorrowWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Remind me tomorrow to pay the bills", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show spending last week", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Schedule for next week", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show expenses last month", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Budget for next month", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Report for last year", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Planning for next year", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Transactions in the past week", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 13)
    }

    @Test func test018_Past2Weeks() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show me orders from past 2 weeks", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 6)
    }

    @Test func test019_Past3Months() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Sales in the past 3 months", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test020_Past2Years() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show transactions past 2 years", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2024)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    // MARK: - Test 21-30: Time Ago Expressions

    @Test func test021_DaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "The meeting was 5 days ago", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
    }

    @Test func test022_WeeksAgo() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "I bought it 2 weeks ago", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 6)
    }

    @Test func test023_MonthsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "I subscribed 3 months ago", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test024_YearsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "The company was founded 5 years ago", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2021)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test025_AWeekAgo() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "I saw him a week ago", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 13)
    }

    @Test func test026_AMonthAgo() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Payment received a month ago", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 20)
    }

    @Test func test027_AYearAgo() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Started working here a year ago", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test028_FewDaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Received it a few days ago", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 17)
    }

    @Test func test029_TenDaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Order placed 10 days ago", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 10)
    }

    @Test func test030_SixMonthsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Last review was 6 months ago", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 20)
    }

    // MARK: - Test 31-40: Month Names

    @Test func test031_MonthNameOnly() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Spending in July", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Income in March 2025", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Meeting on January 15", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test034_MonthNameWithDayAndYear() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Event on December 25, 2025", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test035_MonthAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Report for Jan", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "See you on Feb. 14", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 14)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test037_OrdinalDate() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Meet on March 1st", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test038_OrdinalDate2nd() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Payment due April 2nd", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 4)
        #expect(components.day == 2)
    }

    @Test func test039_OrdinalDate3rd() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Due on May 3rd", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 5)
        #expect(components.day == 3)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test040_OrdinalDate4th() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Independence Day is July 4th", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Meeting on 1/15", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test042_SlashFormatMMDDYYYY() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Invoice dated 12/25/2025", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test043_SlashFormatMMDDYY() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Date: 03/15/25", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 3)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test044_ISOFormat() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Created on 2025-07-04", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 4)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test045_DashFormatDDMMYYYY() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Record for 15-06-2025", refDate: refDate, opt: [.littleEndian: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 6)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test046_DotFormat() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Entry from 10.05.2025", refDate: refDate, opt: [.littleEndian: 1])
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 5)
        #expect(components.day == 10)
    }

    @Test func test047_LittleEndianFormat() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "The event is on 25/12/2025", refDate: refDate, opt: [.littleEndian: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test048_ISOFormatInSentence() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "The deadline is 2025-12-31", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 31)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test049_SlashFormatWithWeekday() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Monday 1/20/2026", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test050_ISOFormatNoSeparator() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Event on 2025-01-01", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Revenue in 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Expenses during 2024", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Budget for 2023", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Transactions since 2024", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Data from 2023", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Sales this year", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "What happened in the year 2022", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Summary for year 2021", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "How much did I spend at restaurants in 2025?", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Track my expenses since 2020", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Meeting on Monday", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19) // Previous Monday
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test062_NextMonday() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "See you next Monday", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 26)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test063_LastFriday() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Report from last Friday", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 16)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test064_ThisWednesday() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "This Wednesday works", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test065_OnSaturday() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Party on Saturday", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 24 || components.day == 17) // Either upcoming or recent
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test066_NextSunday() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Let's go hiking next Sunday", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test067_LastThursday() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Meeting last Thursday", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test068_WeekdayAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show my spending on Tue", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test069_PastTuesday() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "That happened past Tuesday", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 13)
    }

    @Test func test070_FridayThisWeek() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Friday this week", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 23)
    }

    // MARK: - Test 71-80: This Month / In Days

    @Test func test071_ThisMonth() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Spending this month", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Due in 5 days", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 25)
    }

    @Test func test073_InAWeek() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Check back in a week", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 27)
    }

    @Test func test074_InTwoWeeks() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Deadline in two weeks", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 3)
    }

    @Test func test075_InAMonth() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Review in a month", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 20)
    }

    @Test func test076_In3Months() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Quarter review in 3 months", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 4)
        #expect(components.day == 20)
    }

    @Test func test077_InAYear() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Renew in a year", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2027)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test078_Within2Days() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Respond within 2 days", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 22)
    }

    @Test func test079_Past20Days() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Spending in past 20 days", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 31)
    }

    @Test func test080_Past30Days() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Reports from past 30 days", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 21)
    }

    // MARK: - Test 81-90: Date Ranges

    @Test func test081_BetweenMonths() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Revenue between July 2024 and January 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Sales from March to June 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Reports from July 2024", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2024)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test084_DateRangeWithDays() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Meeting from January 15 to January 20", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Vacation between December 20 and December 31, 2025", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Available January 15 - 20", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Data from 2020 to 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Transactions since September", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 9)
        #expect(components.day == 1)
    }

    @Test func test089_UntilDate() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Valid until December 31, 2026", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 12)
        #expect(components.day == 31)
    }

    @Test func test090_ThroughDate() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Open through March 15", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 15)
    }

    // MARK: - Test 91-100: Complex Sentences / Edge Cases

    @Test func test091_SpendingAtStarbucksSinceJuly() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "How much did I spend at Starbucks since July 2025?", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test092_TopSpendingInMonth() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "List my top 10 spending in July", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test093_TransactionsLastQuarter() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show all transactions from last 3 months", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test094_PurchasesOnSpecificDate() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "What did I purchase on December 25, 2025?", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
    }

    @Test func test095_BillsDueNextMonth() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "What bills are due next month?", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        // "this week" may not parse directly - this tests the parser
        let result = chrono.parse(text: "Show expenses for this week", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
    }

    @Test func test097_IncomeYearToDate() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Total income this year", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Doctor appointment next Thursday", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 29)
    }

    @Test func test099_EndOfMonth() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Due on January 31st", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 31)
    }

    @Test func test100_LeapYearDate() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Event on February 29, 2024", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2024)
        #expect(components.month == 2)
        #expect(components.day == 29)
    }
    
    // MARK: - More Edge Cases
    
    @Test
    func test101_SinceLastYear() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show my spending record since last year", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 1)
    }
    
    @Test
    func test102_LastYear() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show my spending record last year", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show my spending record in the last year", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 20)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 20)
    }
    
    @Test
    func test104_SinceLastMonth() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show my spending record since last month", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 12)
        #expect(startComponents.day == 1)
    }
    
    @Test
    func test105_LastMonth() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show my spending record last month", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show my spending record in the last month", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 12)
        #expect(startComponents.day == 20)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 20)
    }
    
    @Test
    func test107_SinceLastWeek() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show my spending record since last week", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 12)
    }
    
    @Test
    func test108_LastWeek() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show my spending record last week", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Show my spending record in the last week", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 14)
        let endDate = try #require(result.first?.end?.date)
        let endComponents = dateComponents(date: endDate)
        #expect(endComponents.year == 2026)
        #expect(endComponents.month == 1)
        #expect(endComponents.day == 20)
    }
    
    @Test
    func test110_SinceMarch() async throws {
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Show my spending record since March", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Show my spending record since March 20", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Show my spending record since March 20 to yesterday", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Show my spending record from March", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Show my spending record from March 20", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .english)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Show my spending record from March 20 to yesterday", refDate: refDate)
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

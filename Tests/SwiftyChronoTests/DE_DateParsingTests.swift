//
//  DateParsingTests.swift
//  SwiftyChrono
//
//  Comprehensive test cases for german date parsing
//

import Foundation
import Testing
@testable import SwiftyChronoX

struct DE_DateParsingTests {

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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ich habe heute ein Meeting", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test002_Tomorrow() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Lass uns morgen treffen", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test003_Yesterday() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Was ist gestern passiert?", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Mach es jetzt", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test005_Tonight() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Lass uns heute Abend ausgehen", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test006_LastNight() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ich habe letzte Nacht gut geschlafen", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test007_TomorrowAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Wir sehen uns morgen", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test008_TodayWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig mir alle Transaktionen von heute", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test009_YesterdayWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Was habe ich gestern im Laden gekauft?", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test010_TomorrowWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Erinnere mich morgen daran die Rechnungen zu bezahlen", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig Ausgaben der letzten Woche", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Plan für nächste Woche", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig Ausgaben vom letzten Monat", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Budget für nächsten Monat", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Bericht für letztes Jahr", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Planung für nächstes Jahr", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Transaktionen in der letzten Woche", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 14)
    }

    @Test func test018_Past2Weeks() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig mir Bestellungen aus den letzten 2 Wochen", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 6)
    }

    @Test func test019_Past3Months() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Verkäufe in den letzten 3 Monaten", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test020_Past2Years() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig Transaktionen der letzten 2 Jahre", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2024)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    // MARK: - Test 21-30: Time Ago Expressions

    @Test func test021_DaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Das Meeting war vor 5 Tagen", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
    }

    @Test func test022_WeeksAgo() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ich habe es vor 2 Wochen gekauft", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 6)
    }

    @Test func test023_MonthsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ich habe es vor 3 Monaten abonniert", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test024_YearsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Die Firma wurde vor 5 Jahren gegründet", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2021)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test025_AWeekAgo() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ich habe ihn vor einer Woche gesehen", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 13)
    }

    @Test func test026_AMonthAgo() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Die Zahlung wurde vor einem Monat erhalten", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 20)
    }

    @Test func test027_AYearAgo() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ich habe hier vor einem Jahr angefangen", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test028_FewDaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ich habe es vor ein paar Tagen erhalten", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 17)
    }

    @Test func test029_TenDaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Bestellung vor 10 Tagen aufgegeben", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 10)
    }

    @Test func test030_SixMonthsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Das letzte Review war vor 6 Monaten", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 20)
    }

    // MARK: - Test 31-40: Month Names

    @Test func test031_MonthNameOnly() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ausgaben im Juli", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Einnahmen im März 2025", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Meeting am 15. Januar", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test034_MonthNameWithDayAndYear() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ereignis am 25. Dezember 2025", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test035_MonthAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Bericht für Jan.", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Wir sehen uns am 14. Feb.", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 14)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test037_OrdinalDate() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Treffen am 1. März", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test038_OrdinalDate2nd() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zahlung fällig am 2. April", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 4)
        #expect(components.day == 2)
    }

    @Test func test039_OrdinalDate3rd() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Fällig am 3. Mai", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 5)
        #expect(components.day == 3)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test040_OrdinalDate4th() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Der Unabhängigkeitstag ist am 4. Juli", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Meeting am 15.1", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test042_SlashFormatMMDDYYYY() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Rechnung datiert auf 25.12.2025", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test043_SlashFormatMMDDYY() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Datum: 15.03.25", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 3)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test044_ISOFormat() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Erstellt am 2025-07-04", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 4)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test045_DashFormatDDMMYYYY() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Eintrag für 15-06-2025", refDate: refDate, opt: [.littleEndian: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 6)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test046_DotFormat() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Eintrag vom 10.05.2025", refDate: refDate, opt: [.littleEndian: 1])
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 5)
        #expect(components.day == 10)
    }

    @Test func test047_LittleEndianFormat() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Das Ereignis ist am 25/12/2025", refDate: refDate, opt: [.littleEndian: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test048_ISOFormatInSentence() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Die Frist ist 2025-12-31", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 31)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test049_SlashFormatWithWeekday() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montag 20.1.2026", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test050_ISOFormatNoSeparator() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ereignis am 2025-01-01", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Einnahmen im Jahr 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ausgaben während 2024", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Budget für 2023", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Transaktionen seit 2024", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Daten aus 2023", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Verkäufe dieses Jahr", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Was ist im Jahr 2022 passiert", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zusammenfassung für das Jahr 2021", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Wie viel habe ich 2025 in Restaurants ausgegeben?", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Verfolge meine Ausgaben seit 2020", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Meeting am Montag", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19) // Previous Monday
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test062_NextMonday() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Wir sehen uns nächsten Montag", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 26)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test063_LastFriday() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Bericht vom letzten Freitag", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 16)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test064_ThisWednesday() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Dieser Mittwoch passt", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test065_OnSaturday() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Party am Samstag", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 24 || components.day == 17) // Either upcoming or recent
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test066_NextSunday() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Lass uns nächsten Sonntag wandern gehen", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test067_LastThursday() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Meeting letzten Donnerstag", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test068_WeekdayAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig meine Ausgaben am Di", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test069_PastTuesday() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Das passierte letzten Dienstag", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 13)
    }

    @Test func test070_FridayThisWeek() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Freitag dieser Woche", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 23)
    }

    // MARK: - Test 71-80: This Month / In Days

    @Test func test071_ThisMonth() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ausgaben diesen Monat", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Fällig in 5 Tagen", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 25)
    }

    @Test func test073_InAWeek() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Schau in einer Woche wieder nach", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 27)
    }

    @Test func test074_InTwoWeeks() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Frist in zwei Wochen", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 3)
    }

    @Test func test075_InAMonth() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Überprüfung in einem Monat", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 20)
    }

    @Test func test076_In3Months() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Quartalsreview in 3 Monaten", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 4)
        #expect(components.day == 20)
    }

    @Test func test077_InAYear() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "In einem Jahr erneuern", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2027)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test078_Within2Days() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Antworte innerhalb von 2 Tagen", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 22)
    }

    @Test func test079_Past20Days() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ausgaben in den letzten 20 Tagen", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 31)
    }

    @Test func test080_Past30Days() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Berichte aus den letzten 30 Tagen", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 21)
    }

    // MARK: - Test 81-90: Date Ranges

    @Test func test081_BetweenMonths() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Einnahmen zwischen Juli 2024 und Januar 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Verkäufe von März bis Juni 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Berichte seit Juli 2024", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2024)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test084_DateRangeWithDays() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Meeting vom 15. Januar bis 20. Januar", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Urlaub zwischen dem 20. Dezember und dem 31. Dezember 2025", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Verfügbar 15. bis 20. Januar", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Daten von 2020 bis 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Transaktionen seit September", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 9)
        #expect(components.day == 1)
    }

    @Test func test089_UntilDate() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Gültig bis 31. Dezember 2026", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 12)
        #expect(components.day == 31)
    }

    @Test func test090_ThroughDate() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Geöffnet bis 15. März", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 15)
    }

    // MARK: - Test 91-100: Complex Sentences / Edge Cases

    @Test func test091_SpendingAtStarbucksSinceJuly() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Wie viel habe ich seit Juli 2025 bei Starbucks ausgegeben?", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test092_TopSpendingInMonth() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Liste meine 10 höchsten Ausgaben im Juli", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test093_TransactionsLastQuarter() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig alle Transaktionen der letzten 3 Monate", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test094_PurchasesOnSpecificDate() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Was habe ich am 25. Dezember 2025 gekauft?", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
    }

    @Test func test095_BillsDueNextMonth() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Welche Rechnungen sind nächsten Monat fällig?", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        // "this week" may not parse directly - this tests the parser
        let result = chrono.parse(text: "Zeig Ausgaben für diese Woche", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
    }

    @Test func test097_IncomeYearToDate() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Gesamteinnahmen dieses Jahr", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Arzttermin nächsten Donnerstag", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 29)
    }

    @Test func test099_EndOfMonth() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Fällig am 31. Januar", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 31)
    }

    @Test func test100_LeapYearDate() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ereignis am 29. Februar 2024", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2024)
        #expect(components.month == 2)
        #expect(components.day == 29)
    }
    
    // MARK: - More Edge Cases

    @Test
    func test101_SinceLastYear() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen seit letztem Jahr", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 1)
    }

    @Test
    func test102_LastYear() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen letztes Jahr", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen im letzten Jahr", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen seit letztem Monat", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 12)
        #expect(startComponents.day == 1)
    }

    @Test
    func test105_LastMonth() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen letzten Monat", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen im letzten Monat", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen seit letzter Woche", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 12)
    }

    @Test
    func test108_LastWeek() async throws {
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen letzte Woche", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen in der letzten Woche", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen seit März", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen seit 20. März", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen seit 20. März bis gestern", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen ab März", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen ab 20. März", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .german)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Zeig meine Ausgabenaufzeichnungen ab 20. März bis gestern", refDate: refDate)
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

//
//  DateParsingTests.swift
//  SwiftyChrono
//
//  Comprehensive test cases for french date parsing
//

import Foundation
import Testing
@testable import SwiftyChronoX

struct FR_DateParsingTests {

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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "J'ai une réunion aujourd'hui", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test002_Tomorrow() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "On se voit demain", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test003_Yesterday() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Qu'est-ce qui s'est passé hier ?", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Fais-le maintenant", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test005_Tonight() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Sortons cette nuit", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test006_LastNight() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "J'ai bien dormi la veille", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test007_TomorrowAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "On se voit demain", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test008_TodayWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre-moi toutes les transactions d'aujourd'hui", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test009_YesterdayWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Qu'est-ce que j'ai acheté hier au magasin ?", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test010_TomorrowWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Rappelle-moi demain de payer les factures", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre les dépenses de la semaine dernière", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Planning pour la semaine prochaine", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre les dépenses du mois dernier", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Budget pour le mois prochain", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Rapport pour l'année dernière", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Planification pour l'année prochaine", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Transactions de la semaine dernière", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 12)
    }

    @Test func test018_Past2Weeks() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre-moi les commandes des 2 dernières semaines", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 6)
    }

    @Test func test019_Past3Months() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ventes des 3 derniers mois", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test020_Past2Years() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre les transactions des 2 dernières années", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2024)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    // MARK: - Test 21-30: Time Ago Expressions

    @Test func test021_DaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "La réunion était il y a 5 jours", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
    }

    @Test func test022_WeeksAgo() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Je l'ai acheté il y a 2 semaines", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 6)
    }

    @Test func test023_MonthsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Je me suis abonné il y a 3 mois", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test024_YearsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "L'entreprise a été fondée il y a 5 ans", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2021)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test025_AWeekAgo() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Je l'ai vu il y a une semaine", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 13)
    }

    @Test func test026_AMonthAgo() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Paiement reçu il y a un mois", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 20)
    }

    @Test func test027_AYearAgo() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "J'ai commencé à travailler ici il y a un an", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test028_FewDaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Je l'ai reçu il y a quelques jours", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 17)
    }

    @Test func test029_TenDaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Commande passée il y a 10 jours", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 10)
    }

    @Test func test030_SixMonthsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "La dernière révision était il y a 6 mois", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 20)
    }

    // MARK: - Test 31-40: Month Names

    @Test func test031_MonthNameOnly() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Dépenses en juillet", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Revenus en mars 2025", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Réunion le 15 janvier", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test034_MonthNameWithDayAndYear() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Événement le 25 décembre 2025", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test035_MonthAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Rapport pour jan.", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "On se voit le 14 fév.", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 14)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test037_OrdinalDate() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Rendez-vous le 1er mars", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test038_OrdinalDate2nd() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Paiement dû le 2 avril", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 4)
        #expect(components.day == 2)
    }

    @Test func test039_OrdinalDate3rd() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Dû le 3 mai", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 5)
        #expect(components.day == 3)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test040_OrdinalDate4th() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "La fête nationale est le 4 juillet", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Réunion le 15/1", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test042_SlashFormatMMDDYYYY() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Facture datée du 25/12/2025", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test043_SlashFormatMMDDYY() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Date : 15/03/25", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 3)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test044_ISOFormat() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Créé le 2025-07-04", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 4)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test045_DashFormatDDMMYYYY() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Enregistrement du 15-06-2025", refDate: refDate, opt: [.littleEndian: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 6)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test046_DotFormat() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Entrée du 10.05.2025", refDate: refDate, opt: [.littleEndian: 1])
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 5)
        #expect(components.day == 10)
    }

    @Test func test047_LittleEndianFormat() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "L'événement est le 25/12/2025", refDate: refDate, opt: [.littleEndian: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test048_ISOFormatInSentence() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "La date limite est le 2025-12-31", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 31)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test049_SlashFormatWithWeekday() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "lundi 20/1/2026", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test050_ISOFormatNoSeparator() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Événement le 2025-01-01", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Revenus en 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Dépenses durant 2024", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Budget pour 2023", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Transactions depuis 2024", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Données depuis 2023", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ventes cette année", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Que s'est-il passé en 2022", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Résumé pour l'année 2021", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Combien ai-je dépensé au restaurant en 2025 ?", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Suis mes dépenses depuis 2020", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Réunion lundi", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19) // Previous Monday
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test062_NextMonday() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "On se voit lundi prochain", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 26)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test063_LastFriday() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Rapport de vendredi dernier", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 16)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test064_ThisWednesday() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Ce mercredi convient", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test065_OnSaturday() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Fête samedi", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 24 || components.day == 17) // Either upcoming or recent
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test066_NextSunday() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Allons randonner dimanche prochain", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test067_LastThursday() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Réunion jeudi dernier", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test068_WeekdayAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre mes dépenses du mar", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test069_PastTuesday() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Cela s'est passé mardi dernier", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 13)
    }

    @Test func test070_FridayThisWeek() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Vendredi cette semaine", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 23)
    }

    // MARK: - Test 71-80: This Month / In Days

    @Test func test071_ThisMonth() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Dépenses ce mois-ci", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Échéance dans 5 jours", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 25)
    }

    @Test func test073_InAWeek() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Vérifie de nouveau dans une semaine", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 27)
    }

    @Test func test074_InTwoWeeks() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Date limite dans deux semaines", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 3)
    }

    @Test func test075_InAMonth() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Révision dans un mois", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 20)
    }

    @Test func test076_In3Months() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Revue trimestrielle dans 3 mois", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 4)
        #expect(components.day == 20)
    }

    @Test func test077_InAYear() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Renouveler dans un an", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2027)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test078_Within2Days() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Réponds sous 2 jours", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 22)
    }

    @Test func test079_Past20Days() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Dépenses des 20 derniers jours", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 31)
    }

    @Test func test080_Past30Days() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Rapports des 30 derniers jours", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 21)
    }

    // MARK: - Test 81-90: Date Ranges

    @Test func test081_BetweenMonths() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Revenus entre juillet 2024 et janvier 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ventes de mars à juin 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Rapports depuis juillet 2024", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2024)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test084_DateRangeWithDays() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Réunion du 15 janvier au 20 janvier", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Vacances entre le 20 décembre et le 31 décembre 2025", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Disponible du 15 au 20 janvier", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Données de 2020 à 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Transactions depuis septembre", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 9)
        #expect(components.day == 1)
    }

    @Test func test089_UntilDate() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Valide jusqu'au 31 décembre 2026", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 12)
        #expect(components.day == 31)
    }

    @Test func test090_ThroughDate() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ouvert jusqu'au 15 mars", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 15)
    }

    // MARK: - Test 91-100: Complex Sentences / Edge Cases

    @Test func test091_SpendingAtStarbucksSinceJuly() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Combien ai-je dépensé chez Starbucks depuis juillet 2025 ?", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test092_TopSpendingInMonth() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Liste mes 10 plus grosses dépenses de juillet", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test093_TransactionsLastQuarter() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre toutes les transactions des 3 derniers mois", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test094_PurchasesOnSpecificDate() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Qu'ai-je acheté le 25 décembre 2025 ?", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
    }

    @Test func test095_BillsDueNextMonth() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Quelles factures sont dues le mois prochain ?", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        // "this week" may not parse directly - this tests the parser
        let result = chrono.parse(text: "Montre les dépenses de cette semaine", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
    }

    @Test func test097_IncomeYearToDate() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Revenu total cette année", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Rendez-vous chez le médecin jeudi prochain", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 29)
    }

    @Test func test099_EndOfMonth() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Dû le 31 janvier", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 31)
    }

    @Test func test100_LeapYearDate() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Événement le 29 février 2024", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2024)
        #expect(components.month == 2)
        #expect(components.day == 29)
    }
    
    // MARK: - More Edge Cases

    @Test
    func test101_SinceLastYear() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre mon historique de dépenses depuis l'année dernière", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 1)
    }

    @Test
    func test102_LastYear() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre mon historique de dépenses l'année dernière", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre mon historique de dépenses pendant l'année dernière", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre mon historique de dépenses depuis le mois dernier", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 12)
        #expect(startComponents.day == 1)
    }

    @Test
    func test105_LastMonth() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre mon historique de dépenses le mois dernier", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre mon historique de dépenses pendant le mois dernier", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre mon historique de dépenses depuis la semaine dernière", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 12)
    }

    @Test
    func test108_LastWeek() async throws {
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre mon historique de dépenses la semaine dernière", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .french)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Montre mon historique de dépenses pendant la semaine dernière", refDate: refDate)
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
}

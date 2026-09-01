//
//  DateParsingTests.swift
//  SwiftyChrono
//
//  Comprehensive test cases for spanish date parsing
//

import Foundation
import Testing
@testable import SwiftyChronoX

struct ES_DateParsingTests {

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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Tengo una reunión hoy", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test002_Tomorrow() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Nos vemos mañana", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test003_Yesterday() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "¿Qué pasó ayer?", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Hazlo ahora", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test005_Tonight() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Salgamos esta noche", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test006_LastNight() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Dormí bien anoche", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test007_TomorrowAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Nos vemos mañana", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test008_TodayWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muéstrame todas las transacciones de hoy", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test009_YesterdayWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "¿Qué compré ayer en la tienda?", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test010_TomorrowWithContext() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Recuérdame mañana pagar las facturas", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muestra los gastos de la semana pasada", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Agenda para la próxima semana", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muestra los gastos del mes pasado", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Presupuesto para el próximo mes", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Informe del año pasado", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Planificación para el próximo año", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Transacciones de la semana pasada", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 12)
    }

    @Test func test018_Past2Weeks() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muéstrame pedidos de las últimas 2 semanas", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 6)
    }

    @Test func test019_Past3Months() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ventas de los últimos 3 meses", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test020_Past2Years() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muestra transacciones de los últimos 2 años", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2024)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    // MARK: - Test 21-30: Time Ago Expressions

    @Test func test021_DaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "La reunión fue hace 5 días", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
    }

    @Test func test022_WeeksAgo() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Lo compré hace 2 semanas", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 6)
    }

    @Test func test023_MonthsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Me suscribí hace 3 meses", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test024_YearsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "La empresa fue fundada hace 5 años", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2021)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test025_AWeekAgo() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Lo vi hace una semana", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 13)
    }

    @Test func test026_AMonthAgo() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "El pago se recibió hace un mes", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 20)
    }

    @Test func test027_AYearAgo() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Empecé a trabajar aquí hace un año", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test028_FewDaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Lo recibí hace unos días", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 17)
    }

    @Test func test029_TenDaysAgo() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Pedido realizado hace 10 días", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 10)
    }

    @Test func test030_SixMonthsAgo() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "La última revisión fue hace 6 meses", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 20)
    }

    // MARK: - Test 31-40: Month Names

    @Test func test031_MonthNameOnly() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Gastos en julio", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ingresos en marzo de 2025", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Reunión el 15 de enero", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test034_MonthNameWithDayAndYear() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Evento el 25 de diciembre de 2025", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test035_MonthAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Informe de ene.", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Nos vemos el 14 de feb.", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 14)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test037_OrdinalDate() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Reunión el 1 de marzo", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 1)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test038_OrdinalDate2nd() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Pago vence el 2 de abril", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 4)
        #expect(components.day == 2)
    }

    @Test func test039_OrdinalDate3rd() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Vence el 3 de mayo", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 5)
        #expect(components.day == 3)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test040_OrdinalDate4th() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "El Día de la Independencia es el 4 de julio", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Reunión el 15/1", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test042_SlashFormatMMDDYYYY() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Factura con fecha 25/12/2025", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test043_SlashFormatMMDDYY() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Fecha: 15/03/25", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 3)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test044_ISOFormat() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Creado el 2025-07-04", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 4)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test045_DashFormatDDMMYYYY() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Registro del 15-06-2025", refDate: refDate, opt: [.littleEndian: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 6)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test046_DotFormat() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Entrada del 10.05.2025", refDate: refDate, opt: [.littleEndian: 1])
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 5)
        #expect(components.day == 10)
    }

    @Test func test047_LittleEndianFormat() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "El evento es el 25/12/2025", refDate: refDate, opt: [.littleEndian: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test048_ISOFormatInSentence() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "La fecha límite es 2025-12-31", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 31)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test049_SlashFormatWithWeekday() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "lunes 20/1/2026", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test050_ISOFormatNoSeparator() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Evento el 2025-01-01", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ingresos en 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Gastos durante 2024", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Presupuesto para 2023", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Transacciones desde 2024", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Datos desde 2023", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ventas este año", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Qué pasó en el año 2022", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Resumen del año 2021", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "¿Cuánto gasté en restaurantes en 2025?", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Haz seguimiento de mis gastos desde 2020", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Reunión el lunes", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19) // Previous Monday
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test062_NextMonday() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Nos vemos el próximo lunes", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 26)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test063_LastFriday() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Informe del viernes pasado", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 16)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test064_ThisWednesday() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Este miércoles funciona", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 21)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test065_OnSaturday() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Fiesta el sábado", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 24 || components.day == 17) // Either upcoming or recent
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test066_NextSunday() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Vamos de senderismo el próximo domingo", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 25)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test067_LastThursday() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Reunión el jueves pasado", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 15)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test068_WeekdayAbbreviated() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muéstrame mis gastos del martes", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 20)
        let endDate = try #require(result.first?.end?.date)
        #expect(endDate == startDate)
    }

    @Test func test069_PastTuesday() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Eso pasó el martes pasado", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 13)
    }

    @Test func test070_FridayThisWeek() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Viernes de esta semana", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 23)
    }

    // MARK: - Test 71-80: This Month / In Days

    @Test func test071_ThisMonth() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Gastos de este mes", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Vence en 5 días", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 25)
    }

    @Test func test073_InAWeek() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Revisa de nuevo en una semana", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 27)
    }

    @Test func test074_InTwoWeeks() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Fecha límite en dos semanas", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 3)
    }

    @Test func test075_InAMonth() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Revisión en un mes", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 20)
    }

    @Test func test076_In3Months() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Revisión trimestral en 3 meses", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 4)
        #expect(components.day == 20)
    }

    @Test func test077_InAYear() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Renovar en un año", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2027)
        #expect(components.month == 1)
        #expect(components.day == 20)
    }

    @Test func test078_Within2Days() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Responde dentro de 2 días", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 22)
    }

    @Test func test079_Past20Days() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Gastos de los últimos 20 días", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 31)
    }

    @Test func test080_Past30Days() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Informes de los últimos 30 días", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 21)
    }

    // MARK: - Test 81-90: Date Ranges

    @Test func test081_BetweenMonths() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ingresos entre julio de 2024 y enero de 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ventas de marzo a junio de 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Informes desde julio de 2024", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2024)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test084_DateRangeWithDays() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Reunión del 15 de enero al 20 de enero", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Vacaciones entre el 20 de diciembre y el 31 de diciembre de 2025", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Disponible del 15 al 20 de enero", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Datos de 2020 a 2025", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Transacciones desde septiembre", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 9)
        #expect(components.day == 1)
    }

    @Test func test089_UntilDate() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Válido hasta el 31 de diciembre de 2026", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 12)
        #expect(components.day == 31)
    }

    @Test func test090_ThroughDate() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Abierto hasta el 15 de marzo", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 15)
    }

    // MARK: - Test 91-100: Complex Sentences / Edge Cases

    @Test func test091_SpendingAtStarbucksSinceJuly() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "¿Cuánto gasté en Starbucks desde julio de 2025?", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test092_TopSpendingInMonth() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Lista mis 10 mayores gastos en julio", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 7)
        #expect(components.day == 1)
    }

    @Test func test093_TransactionsLastQuarter() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muestra todas las transacciones de los últimos 3 meses", refDate: refDate, opt: [.backwardDate: 1])
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2025)
        #expect(components.month == 10)
        #expect(components.day == 20)
    }

    @Test func test094_PurchasesOnSpecificDate() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "¿Qué compré el 25 de diciembre de 2025?", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2025)
        #expect(components.month == 12)
        #expect(components.day == 25)
    }

    @Test func test095_BillsDueNextMonth() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "¿Qué facturas vencen el próximo mes?", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        // "this week" may not parse directly - this tests the parser
        let result = chrono.parse(text: "Muestra gastos de esta semana", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let components = dateComponents(date: startDate)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 19)
    }

    @Test func test097_IncomeYearToDate() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Ingreso total de este año", refDate: refDate, opt: [.backwardDate: 1])
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20) // Tuesday
        let result = chrono.parse(text: "Cita con el médico el próximo jueves", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 29)
    }

    @Test func test099_EndOfMonth() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Vence el 31 de enero", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2026)
        #expect(components.month == 1)
        #expect(components.day == 31)
    }

    @Test func test100_LeapYearDate() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Evento el 29 de febrero de 2024", refDate: refDate)
        let date = try #require(result.first?.start.date)
        let components = dateComponents(date: date)
        #expect(components.year == 2024)
        #expect(components.month == 2)
        #expect(components.day == 29)
    }
    
    // MARK: - More Edge Cases

    @Test
    func test101_SinceLastYear() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muestra mi registro de gastos desde el año pasado", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 1)
    }

    @Test
    func test102_LastYear() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muestra mi registro de gastos el año pasado", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muestra mi registro de gastos en el año pasado", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muestra mi registro de gastos desde el mes pasado", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2025)
        #expect(startComponents.month == 12)
        #expect(startComponents.day == 1)
    }

    @Test
    func test105_LastMonth() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muestra mi registro de gastos el mes pasado", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muestra mi registro de gastos en el mes pasado", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muestra mi registro de gastos desde la semana pasada", refDate: refDate)
        let startDate = try #require(result.first?.start.date)
        let startComponents = dateComponents(date: startDate)
        #expect(startComponents.year == 2026)
        #expect(startComponents.month == 1)
        #expect(startComponents.day == 12)
    }

    @Test
    func test108_LastWeek() async throws {
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muestra mi registro de gastos la semana pasada", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 1, day: 20)
        let result = chrono.parse(text: "Muestra mi registro de gastos en la semana pasada", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Muestra mi registro de gastos desde marzo", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Muestra mi registro de gastos desde el 20 de marzo", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Muestra mi registro de gastos desde el 20 de marzo hasta ayer", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Muestra mi registro de gastos a partir de marzo", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Muestra mi registro de gastos a partir del 20 de marzo", refDate: refDate)
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
        let chrono = Chrono(preferredLanguage: .spanish)
        let refDate = createRefDate(year: 2026, month: 9, day: 1)
        let result = chrono.parse(text: "Muestra mi registro de gastos a partir del 20 de marzo hasta ayer", refDate: refDate)
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

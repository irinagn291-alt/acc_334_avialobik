import Foundation

/// Simulator-only house. One vacant lot so the first frame can allocate. Never runs on device.
enum SimulatorSeed {
    static func applyIfNeeded(to chart: inout FloorChart, defaults: UserDefaults) {
        #if targetEnvironment(simulator)
        guard !defaults.bool(forKey: FloorStore.demoKey) else { return }
        if chart.onboardingDone || !chart.stations.isEmpty { return }
        let house = demoHouse()
        chart = house
        defaults.set(true, forKey: FloorStore.demoKey)
        #else
        _ = chart
        _ = defaults
        #endif
    }

    static func freshHouse() -> FloorChart {
        var chart = FloorChart.empty
        chart.stations = doors(fillLots: false)
        chart.staff = roster()
        chart.bout = tonightBout()
        chart.openingPoolCents = chart.stations.reduce(0) { $0 + $1.capCents }
        chart.walkInCents = 800
        return chart
    }

    static func demoHouse() -> FloorChart {
        var chart = freshHouse()
        let now = Date()
        let shift = Shift(
            id: UUID(),
            staffID: chart.staff.first?.id,
            started: now,
            dayKey: DayKey.from(now),
            open: true
        )
        chart.shifts = [shift]
        chart.marks.append(
            FloorMark(
                id: UUID(),
                kind: .shift,
                dayKey: DayKey.from(now),
                at: now,
                cents: 0,
                stationID: nil,
                entrantID: nil,
                detail: "Clock open"
            )
        )
        for index in chart.stations.indices where index < chart.stations.count - 1 {
            let cents = chart.stations[index].capCents
            chart.stations[index].lotCents = cents
            chart.marks.append(
                FloorMark(
                    id: UUID(),
                    kind: .lot,
                    dayKey: DayKey.from(now),
                    at: now,
                    cents: cents,
                    stationID: chart.stations[index].id,
                    entrantID: nil,
                    detail: "Cash seated"
                )
            )
        }
        chart.onboardingDone = true
        chart.bracketSeeded = false
        return chart
    }

    private static func doors(fillLots: Bool) -> [Station] {
        let rows: [(String, Int, Int, Int, Int, Int)] = [
            ("North door", 5000, 1, 0, 14, 2),
            ("East door", 4000, 0, 1, 21, 1),
            ("West door", 3000, 2, 0, 7, 3),
            ("Box office", 2000, 0, 0, 3, 1)
        ]
        return rows.map { row in
            Station(
                id: UUID(),
                name: row.0,
                capCents: row.1,
                lotCents: fillLots ? row.1 : 0,
                incidents: row.2,
                repairs: row.3,
                ageDays: row.4,
                recentMaint: row.5
            )
        }
    }

    private static func roster() -> [Staff] {
        [
            Staff(id: UUID(), name: "Ada Quill", role: "Treasurer"),
            Staff(id: UUID(), name: "Moss Keene", role: "Door"),
            Staff(id: UUID(), name: "Ivo Brant", role: "House")
        ]
    }

    private static func tonightBout() -> Bout {
        let names = ["Nim", "Pell", "Sora", "Vetch", "Quill", "Hart", "Bram", "Lark"]
        let entrants = names.enumerated().map { offset, name in
            Entrant(id: UUID(), name: name, seed: offset + 1)
        }
        return Bout(title: "House card", entrants: entrants, matches: [])
    }
}

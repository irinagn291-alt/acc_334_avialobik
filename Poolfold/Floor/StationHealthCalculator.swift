import Foundation

/// Station health. 100 minus incidents, repairs, and age penalties, plus recent maint.
enum StationHealthCalculator {
    static func agePenalty(ageDays: Int) -> Int {
        max(0, ageDays / 7)
    }

    static func health(incidents: Int, repairs: Int, ageDays: Int, recentMaint: Int) -> Int {
        100 - incidents - repairs - agePenalty(ageDays: ageDays) + recentMaint
    }

    static func health(of station: Station) -> Int {
        health(
            incidents: station.incidents,
            repairs: station.repairs,
            ageDays: station.ageDays,
            recentMaint: station.recentMaint
        )
    }
}

import XCTest
@testable import Poolfold

final class PoolfoldTests: XCTestCase {
    func testHealthFormula() {
        let score = StationHealthCalculator.health(incidents: 2, repairs: 1, ageDays: 14, recentMaint: 3)
        XCTAssertEqual(StationHealthCalculator.agePenalty(ageDays: 14), 2)
        XCTAssertEqual(score, 100 - 2 - 1 - 2 + 3)
    }

    func testAllocateEmptyPopulatedAndInvalid() {
        var chart = house(clocked: true)
        let bare = FloorFoldEngine.allocate(chart: FloorChart.empty, stationID: UUID(), cents: 100)
        XCTAssertEqual(bare.chart.marks.last?.kind, .bare)
        XCTAssertFalse(bare.committed)

        let station = chart.stations[0]
        chart.openingPoolCents = station.capCents
        let placed = FloorFoldEngine.allocate(chart: chart, stationID: station.id, cents: station.capCents)
        XCTAssertTrue(placed.committed)
        XCTAssertEqual(placed.chart.stations[0].lotCents, station.capCents)
        XCTAssertEqual(placed.chart.marks.last?.kind, .lot)
        XCTAssertEqual(placed.chart.phase, .allocated)

        let dry = FloorFoldEngine.allocate(chart: placed.chart, stationID: chart.stations[1].id, cents: 100)
        XCTAssertEqual(dry.chart.marks.last?.kind, .dry)
        XCTAssertEqual(dry.chart.floatCents, 0)

        chart.stations[3].capCents = 100
        let over = FloorFoldEngine.allocate(chart: chart, stationID: chart.stations[3].id, cents: 500)
        XCTAssertEqual(over.chart.marks.last?.kind, .over)
        XCTAssertEqual(over.chart.stations[3].lotCents, 0)
    }

    func testRingBeforeAllocatedWritesDriftOnly() {
        let chart = house(clocked: true)
        let before = chart.floatCents
        let rung = FloorFoldEngine.ring(chart: chart, stationID: chart.stations[0].id, comp: false)
        XCTAssertFalse(rung.committed)
        XCTAssertEqual(rung.chart.marks.last?.kind, .drift)
        XCTAssertFalse(rung.chart.marks.contains { $0.kind == .till })
        XCTAssertEqual(rung.chart.floatCents, before)
        XCTAssertEqual(rung.chart.phase, .onShift)
    }

    func testFoldDarkClockAllocateLiveAdvance() {
        var chart = house(clocked: false)
        XCTAssertEqual(chart.phase, .dark)
        let refused = FloorFoldEngine.allocate(chart: chart, stationID: chart.stations[0].id, cents: 100)
        XCTAssertFalse(refused.committed)
        XCTAssertEqual(refused.chart.phase, .dark)
        XCTAssertFalse(refused.chart.marks.contains { $0.kind == .lot })

        let clocked = FloorFoldEngine.clock(chart: chart, staffID: chart.staff.first?.id)
        XCTAssertEqual(clocked.chart.phase, .onShift)
        XCTAssertEqual(clocked.chart.marks.last?.kind, .shift)
        chart = clocked.chart

        for station in chart.stations {
            let step = FloorFoldEngine.allocate(chart: chart, stationID: station.id, cents: station.capCents)
            XCTAssertTrue(step.committed)
            chart = step.chart
        }
        XCTAssertEqual(chart.phase, .allocated)
        let early = FloorFoldEngine.advance(chart: chart, entrantID: chart.bout.entrants[0].id)
        XCTAssertEqual(early.chart.marks.last?.kind, .fault)

        let seeded = FloorFoldEngine.seedBracket(chart: chart)
        XCTAssertTrue(seeded.committed)
        XCTAssertEqual(seeded.chart.phase, .live)
        chart = seeded.chart
        let deck = FloorFoldEngine.onDeckIDs(bout: chart.bout)
        XCTAssertEqual(deck.count, 2)
        let winner = FloorFoldEngine.advance(chart: chart, entrantID: deck[0])
        XCTAssertEqual(winner.chart.marks.last?.kind, .advance)
        let other = chart.bout.entrants.first { !deck.contains($0.id) }!
        let fault = FloorFoldEngine.advance(chart: chart, entrantID: other.id)
        XCTAssertEqual(fault.chart.marks.last?.kind, .fault)

        let till = FloorFoldEngine.ring(chart: chart, stationID: chart.stations[0].id, comp: false)
        XCTAssertTrue(till.committed)
        XCTAssertEqual(till.chart.marks.last?.kind, .till)
        XCTAssertEqual(till.chart.floatCents, chart.walkInCents)
    }

    @MainActor
    func testPersistenceRoundTrip() async throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        let store = FloorStore(defaults: defaults, directory: folder, seedDemo: false)
        var chart = house(clocked: true)
        chart.onboardingDone = true
        store.replace(chart)
        await store.flush()
        let reloaded = FloorStore(defaults: defaults, directory: folder, seedDemo: false)
        XCTAssertEqual(reloaded.chart.stations.count, 4)
        XCTAssertEqual(reloaded.chart.openingPoolCents, chart.openingPoolCents)
        XCTAssertEqual(reloaded.chart.phase, .onShift)
        XCTAssertTrue(reloaded.chart.onboardingDone)
    }

    func testReviewLaunchParser() {
        XCTAssertEqual(ReviewLaunch.screen(in: ["Poolfold"]), nil)
        XCTAssertEqual(ReviewLaunch.screen(in: ["Poolfold", "-ReviewScreen", "goals"]), "goals")
        XCTAssertEqual(ReviewLaunch.screen(in: ["-ReviewScreen"]), nil)
        XCTAssertNil(ReviewLaunch.screen(in: []))
    }

    private func house(clocked: Bool) -> FloorChart {
        var chart = SimulatorSeed.freshHouse()
        if clocked {
            chart = FloorFoldEngine.clock(chart: chart, staffID: chart.staff.first?.id).chart
        }
        return chart
    }
}

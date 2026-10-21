import Foundation

/// Pool ADT fold. Clock, allocate, ring, seed, and advance are the only writers.
enum FloorFoldEngine {
    struct Outcome: Equatable, Sendable {
        var chart: FloorChart
        var committed: Bool
    }

    static func clock(chart: FloorChart, staffID: UUID?, now: Date = Date()) -> Outcome {
        var next = chart
        if next.stations.isEmpty {
            next.marks.append(mark(.bare, cents: 0, detail: "No doors", now: now))
            return Outcome(chart: next, committed: false)
        }
        if next.shifts.contains(where: { $0.open }) {
            return Outcome(chart: next, committed: false)
        }
        let row = Shift(id: UUID(), staffID: staffID, started: now, dayKey: DayKey.from(now), open: true)
        next.shifts.append(row)
        next.marks.append(mark(.shift, cents: 0, detail: "Clock open", now: now))
        return Outcome(chart: next, committed: true)
    }

    static func allocate(chart: FloorChart, stationID: UUID, cents: Int, now: Date = Date()) -> Outcome {
        var next = chart
        if next.stations.isEmpty {
            next.marks.append(mark(.bare, cents: cents, detail: "No doors", now: now))
            return Outcome(chart: next, committed: false)
        }
        if next.phase == .dark {
            return Outcome(chart: next, committed: false)
        }
        guard cents > 0, let index = next.stations.firstIndex(where: { $0.id == stationID }) else {
            return Outcome(chart: next, committed: false)
        }
        if next.remainingCents == 0 || cents > next.remainingCents {
            next.marks.append(mark(.dry, cents: cents, stationID: stationID, detail: "No cash left", now: now))
            return Outcome(chart: next, committed: false)
        }
        let station = next.stations[index]
        if station.lotCents + cents > station.capCents {
            next.marks.append(mark(.over, cents: cents, stationID: stationID, detail: "Over cap", now: now))
            return Outcome(chart: next, committed: false)
        }
        next.stations[index].lotCents += cents
        next.marks.append(mark(.lot, cents: cents, stationID: stationID, detail: "Cash seated", now: now))
        return Outcome(chart: next, committed: true)
    }

    static func ring(chart: FloorChart, stationID: UUID, comp: Bool, plate: String = "", now: Date = Date()) -> Outcome {
        var next = chart
        if next.stations.isEmpty {
            next.marks.append(mark(.bare, cents: 0, detail: "No doors", now: now))
            return Outcome(chart: next, committed: false)
        }
        guard next.phase == .allocated || next.phase == .live else {
            next.marks.append(mark(.drift, cents: 0, stationID: stationID, detail: "Ring before allocated", now: now))
            return Outcome(chart: next, committed: false)
        }
        guard let station = next.stations.first(where: { $0.id == stationID }), station.holdsLot else {
            next.marks.append(mark(.drift, cents: 0, stationID: stationID, detail: "Door has no cash", now: now))
            return Outcome(chart: next, committed: false)
        }
        let cents = comp ? 0 : next.walkInCents
        if !comp {
            next.floatCents += cents
        }
        let detail = comp ? "Comp \(plate)" : "Walk-in"
        next.marks.append(mark(.till, cents: cents, stationID: stationID, detail: detail, now: now))
        return Outcome(chart: next, committed: true)
    }

    static func seedBracket(chart: FloorChart, now: Date = Date()) -> Outcome {
        var next = chart
        guard next.phase == .allocated else {
            return Outcome(chart: next, committed: false)
        }
        let entrants = next.bout.entrants.sorted { $0.seed < $1.seed }
        let count = entrants.count
        guard count >= 2, count & (count - 1) == 0 else {
            return Outcome(chart: next, committed: false)
        }
        next.bout.matches = interleavedMatches(entrants)
        next.bracketSeeded = true
        _ = now
        return Outcome(chart: next, committed: true)
    }

    static func advance(chart: FloorChart, entrantID: UUID, now: Date = Date()) -> Outcome {
        var next = chart
        guard next.phase == .live else {
            next.marks.append(mark(.fault, cents: 0, entrantID: entrantID, detail: "Advance before live", now: now))
            return Outcome(chart: next, committed: false)
        }
        let deck = onDeckIDs(bout: next.bout)
        guard deck.contains(entrantID) else {
            next.marks.append(mark(.fault, cents: 0, entrantID: entrantID, detail: "Not on deck", now: now))
            return Outcome(chart: next, committed: false)
        }
        guard let index = next.bout.matches.firstIndex(where: { match in
            match.winnerID == nil && (match.leftID == entrantID || match.rightID == entrantID)
        }) else {
            next.marks.append(mark(.fault, cents: 0, entrantID: entrantID, detail: "Pair missing", now: now))
            return Outcome(chart: next, committed: false)
        }
        next.bout.matches[index].winnerID = entrantID
        feedWinner(entrantID, from: next.bout.matches[index], into: &next.bout)
        next.marks.append(mark(.advance, cents: 0, entrantID: entrantID, detail: "On deck advanced", now: now))
        return Outcome(chart: next, committed: true)
    }

    static func onDeckIDs(bout: Bout) -> [UUID] {
        let ordered = bout.matches.sorted { lhs, rhs in
            if lhs.round != rhs.round { return lhs.round < rhs.round }
            return lhs.slot < rhs.slot
        }
        guard let open = ordered.first(where: { $0.winnerID == nil && $0.leftID != nil && $0.rightID != nil }) else {
            return []
        }
        return [open.leftID, open.rightID].compactMap { $0 }
    }

    static func logMaint(chart: FloorChart, stationID: UUID) -> Outcome {
        var next = chart
        guard let index = next.stations.firstIndex(where: { $0.id == stationID }) else {
            return Outcome(chart: next, committed: false)
        }
        next.stations[index].recentMaint += 1
        return Outcome(chart: next, committed: true)
    }

    static func placeStation(chart: FloorChart, name: String, capCents: Int) -> Outcome {
        var next = chart
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, capCents > 0 else {
            return Outcome(chart: next, committed: false)
        }
        next.stations.append(
            Station(
                id: UUID(),
                name: trimmed,
                capCents: capCents,
                lotCents: 0,
                incidents: 0,
                repairs: 0,
                ageDays: 0,
                recentMaint: 0
            )
        )
        if next.allocatedCents == 0 {
            next.openingPoolCents = next.stations.reduce(0) { $0 + $1.capCents }
        }
        return Outcome(chart: next, committed: true)
    }

    static func addStaff(chart: FloorChart, name: String) -> Outcome {
        var next = chart
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return Outcome(chart: next, committed: false) }
        next.staff.append(Staff(id: UUID(), name: trimmed, role: "Door"))
        return Outcome(chart: next, committed: true)
    }

    private static func interleavedMatches(_ entrants: [Entrant]) -> [BoutMatch] {
        let count = entrants.count
        let rounds = Int(log2(Double(count)))
        var matches: [BoutMatch] = []
        let half = count / 2
        for slot in 0..<half {
            let left = entrants[slot]
            let right = entrants[count - 1 - slot]
            matches.append(
                BoutMatch(id: UUID(), round: 0, slot: slot, leftID: left.id, rightID: right.id, winnerID: nil)
            )
        }
        if rounds > 1 {
            for round in 1..<rounds {
                let slots = count / Int(pow(2.0, Double(round + 1)))
                for slot in 0..<slots {
                    matches.append(
                        BoutMatch(id: UUID(), round: round, slot: slot, leftID: nil, rightID: nil, winnerID: nil)
                    )
                }
            }
        }
        return matches
    }

    private static func feedWinner(_ winner: UUID, from match: BoutMatch, into bout: inout Bout) {
        let nextRound = match.round + 1
        let nextSlot = match.slot / 2
        guard let index = bout.matches.firstIndex(where: { $0.round == nextRound && $0.slot == nextSlot }) else {
            return
        }
        if match.slot % 2 == 0 {
            bout.matches[index].leftID = winner
        } else {
            bout.matches[index].rightID = winner
        }
    }

    private static func mark(
        _ kind: MarkKind,
        cents: Int,
        stationID: UUID? = nil,
        entrantID: UUID? = nil,
        detail: String,
        now: Date
    ) -> FloorMark {
        FloorMark(
            id: UUID(),
            kind: kind,
            dayKey: DayKey.from(now),
            at: now,
            cents: cents,
            stationID: stationID,
            entrantID: entrantID,
            detail: detail
        )
    }
}

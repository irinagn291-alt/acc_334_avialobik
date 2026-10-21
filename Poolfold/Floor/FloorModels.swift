import Foundation

/// Floor chart. The fold is Stations, Lots, Shifts, and Bouts plus an append-only mark tape.
struct FloorChart: Codable, Equatable, Sendable {
    var schemaVersion: Int
    var stations: [Station]
    var staff: [Staff]
    var shifts: [Shift]
    var bout: Bout
    var marks: [FloorMark]
    var openingPoolCents: Int
    var floatCents: Int
    var walkInCents: Int
    var onboardingDone: Bool
    var bracketSeeded: Bool
    var loadNote: String?

    static let empty = FloorChart(
        schemaVersion: 1,
        stations: [],
        staff: [],
        shifts: [],
        bout: Bout.empty,
        marks: [],
        openingPoolCents: 0,
        floatCents: 0,
        walkInCents: 800,
        onboardingDone: false,
        bracketSeeded: false,
        loadNote: nil
    )

    var allocatedCents: Int {
        stations.reduce(0) { $0 + $1.lotCents }
    }

    var remainingCents: Int {
        max(0, openingPoolCents - allocatedCents)
    }

    /// Bare, Dark, OnShift, Allocated, Live. Derived. Never stored.
    var phase: FloorPhase {
        if stations.isEmpty { return .bare }
        let clocked = shifts.contains { $0.open }
        if !clocked { return .dark }
        if bracketSeeded { return .live }
        if openingPoolCents > 0 && allocatedCents == openingPoolCents { return .allocated }
        return .onShift
    }
}

enum FloorPhase: String, Codable, Equatable, Sendable {
    case bare
    case dark
    case onShift
    case allocated
    case live

    var word: String {
        switch self {
        case .bare: "Empty"
        case .dark: "Closed"
        case .onShift: "Open"
        case .allocated: "Closed"
        case .live: "Live"
        }
    }
}

/// Door station. Lot cents are the opening allocation sitting on this door.
struct Station: Codable, Identifiable, Equatable, Sendable {
    var id: UUID
    var name: String
    var capCents: Int
    var lotCents: Int
    var incidents: Int
    var repairs: Int
    var ageDays: Int
    var recentMaint: Int

    var holdsLot: Bool { lotCents > 0 }
}

/// Named volunteer on the roster.
struct Staff: Codable, Identifiable, Equatable, Sendable {
    var id: UUID
    var name: String
    var role: String
}

/// One clocked shift. Open means the floor has left Dark.
struct Shift: Codable, Identifiable, Equatable, Sendable {
    var id: UUID
    var staffID: UUID?
    var started: Date
    var dayKey: Int
    var open: Bool
}

/// Power-of-two bout. Matches stay empty until seed.
struct Bout: Codable, Equatable, Sendable {
    var title: String
    var entrants: [Entrant]
    var matches: [BoutMatch]

    static let empty = Bout(title: "Tonight", entrants: [], matches: [])
}

/// Bracket entrant. Seed orders the interleave.
struct Entrant: Codable, Identifiable, Equatable, Sendable {
    var id: UUID
    var name: String
    var seed: Int
}

/// One pair in a round. Winner is nil until an OnDeck advance.
struct BoutMatch: Codable, Identifiable, Equatable, Sendable {
    var id: UUID
    var round: Int
    var slot: Int
    var leftID: UUID?
    var rightID: UUID?
    var winnerID: UUID?
}

enum MarkKind: String, Codable, Equatable, Sendable {
    case bare
    case shift
    case lot
    case till
    case drift
    case over
    case dry
    case advance
    case fault
}

/// Append-only tape row. Cents stay in integer cents.
struct FloorMark: Codable, Identifiable, Equatable, Sendable {
    var id: UUID
    var kind: MarkKind
    var dayKey: Int
    var at: Date
    var cents: Int
    var stationID: UUID?
    var entrantID: UUID?
    var detail: String
}

enum DayKey {
    static func from(_ date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        return (parts.year ?? 0) * 10000 + (parts.month ?? 0) * 100 + (parts.day ?? 0)
    }
}

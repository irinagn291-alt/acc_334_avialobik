import SwiftUI

/// Interleaved power-of-two card. Advance only the on-deck pair.
struct BracketInterleaveSheet: View {
    @ObservedObject var store: FloorStore
    var goalFocus: Bool = false

    var body: some View {
        BracketView(store: store, goalFocus: goalFocus)
    }
}

/// Live cover for the bracket key. The sheet stays the call site.
struct BracketView: View {
    @ObservedObject var store: FloorStore
    var goalFocus: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var notice = ""
    @State private var preview: [BoutMatch] = []

    var body: some View {
        if goalFocus {
            GoalsView(store: store)
        } else {
            bracketStack
        }
    }

    private var bracketStack: some View {
        NavigationStack {
            Group {
                if store.chart.bout.entrants.isEmpty {
                    empty
                } else {
                    filled
                }
            }
            .background(DesignTokens.bg.ignoresSafeArea())
            .navigationTitle(screenName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: PoolChrome.unit * 2) {
            Text(emptyWord)
                .font(GeorgiaType.title)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(emptyLine)
                .font(GeorgiaType.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(0..<4, id: \.self) { slot in
                Text(pairLine(slot))
                    .font(GeorgiaType.headline)
                    .foregroundStyle(DesignTokens.ink)
                    .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
                    .padding(PoolChrome.unit * 2)
                    .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
            }
            Spacer(minLength: 0)
            Button(emptyAction) { dismiss() }
                .buttonStyle(PoolPressStyle(filled: true))
        }
        .padding(PoolChrome.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var filled: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PoolChrome.unit * 2) {
                Text(store.chart.bout.title)
                    .font(GeorgiaType.title)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(statusLine)
                    .font(GeorgiaType.body)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if !notice.isEmpty {
                    Text(notice)
                        .font(GeorgiaType.callout)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if store.loadFailed {
                    Text(failureLine)
                        .font(GeorgiaType.callout)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Button(retryTitle) { store.reload() }
                        .buttonStyle(PoolPressStyle(filled: true))
                }
                BoutStripView(
                    bout: displayBout,
                    onDeck: onDeck,
                    onTap: tapEntrant
                )
            }
            .padding(PoolChrome.unit * 2)
            .padding(.bottom, PoolChrome.unit * 8)
        }
        .safeAreaInset(edge: .bottom) {
            Button(primaryTitle) { primaryTap() }
                .buttonStyle(PoolPressStyle(filled: true))
                .padding(.horizontal, PoolChrome.unit * 2)
                .padding(.vertical, PoolChrome.unit)
                .background(DesignTokens.bg)
        }
        .onAppear(perform: loadPreview)
    }

    private var screenName: String { goalFocus ? "Goals" : "Bracket" }
    private var emptyWord: String { "House card" }
    private var emptyLine: String { "Eight names make the card. Add them, then seed the pairs." }
    private var emptyAction: String { "Close" }
    private var failureLine: String { "The night file failed to read. Retry, then reopen." }
    private var retryTitle: String { "Retry load" }
    private var primaryTitle: String {
        store.chart.phase == .live ? "Advance on deck" : "Seed pairings"
    }
    private var statusLine: String {
        if store.chart.phase == .live {
            return "Round \(PoolFormat.count(openRound + 1)). Tap the on-deck name, or advance the pair."
        }
        return "Round 1 is set. Seed pairings, then tap the name that wins."
    }

    private var displayBout: Bout {
        var bout = store.chart.bout
        if bout.matches.isEmpty {
            bout.matches = preview
        }
        return bout
    }

    private var onDeck: [UUID] {
        if store.chart.bout.matches.isEmpty {
            return []
        }
        return FloorFoldEngine.onDeckIDs(bout: store.chart.bout)
    }

    private var openRound: Int {
        store.chart.bout.matches
            .filter { $0.winnerID == nil && $0.leftID != nil && $0.rightID != nil }
            .map(\.round)
            .min() ?? 0
    }

    private func loadPreview() {
        if preview.isEmpty {
            preview = previewMatches(store.chart.bout.entrants)
        }
    }

    private func primaryTap() {
        if store.chart.phase == .live {
            if let id = FloorFoldEngine.onDeckIDs(bout: store.chart.bout).first {
                advance(id)
            } else {
                notice = "The card is finished."
            }
            return
        }
        seed()
    }

    private func tapEntrant(_ id: UUID) {
        if store.chart.phase != .live {
            seed()
            return
        }
        advance(id)
    }

    private func pairLine(_ slot: Int) -> String {
        "Pair \(PoolFormat.count(slot + 1))"
    }

    private func seatOpenDoor() {
        guard store.chart.phase != .allocated, store.chart.phase != .live else { return }
        guard store.chart.remainingCents > 0,
              let open = store.chart.stations.first(where: { $0.lotCents < $0.capCents })
        else { return }
        let room = open.capCents - open.lotCents
        let cents = min(store.chart.remainingCents, room)
        guard cents > 0 else { return }
        let placed = FloorFoldEngine.allocate(chart: store.chart, stationID: open.id, cents: cents)
        store.apply(placed)
    }

    private func seed() {
        seatOpenDoor()
        let outcome = FloorFoldEngine.seedBracket(chart: store.chart)
        store.apply(outcome)
        if outcome.committed {
            notice = "Pairings live. Tap the on-deck name."
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else if store.chart.phase == .dark {
            notice = "Clock in first, then seed the card."
        } else {
            notice = "Seat every door, then seed the card."
        }
    }

    private func previewMatches(_ entrants: [Entrant]) -> [BoutMatch] {
        let ordered = entrants.sorted { $0.seed < $1.seed }
        let count = ordered.count
        guard count >= 2, count & (count - 1) == 0 else { return [] }
        let rounds = Int(log2(Double(count)))
        var matches: [BoutMatch] = []
        for slot in 0..<(count / 2) {
            matches.append(
                BoutMatch(
                    id: ordered[slot].id,
                    round: 0,
                    slot: slot,
                    leftID: ordered[slot].id,
                    rightID: ordered[count - 1 - slot].id,
                    winnerID: nil
                )
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

    private func advance(_ id: UUID) {
        let outcome = FloorFoldEngine.advance(chart: store.chart, entrantID: id)
        store.apply(outcome)
        if outcome.committed {
            notice = "Advance posted."
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            notice = "Fault. That name is not on deck."
        }
    }
}

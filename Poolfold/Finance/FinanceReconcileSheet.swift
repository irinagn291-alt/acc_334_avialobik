import SwiftUI

/// Pool, lots, float, and the mark tape for one day key.
struct FinanceReconcileSheet: View {
    @ObservedObject var store: FloorStore
    var tapeFirst: Bool = false

    var body: some View {
        FinanceView(store: store, tapeFirst: tapeFirst)
    }
}

/// Live cover for finance and the log key.
struct FinanceView: View {
    @ObservedObject var store: FloorStore
    var tapeFirst: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var counted: Set<UUID> = []
    @State private var notice = ""

    var body: some View {
        NavigationStack {
            Group {
                if tapeFirst {
                    if store.chart.marks.isEmpty && store.chart.stations.isEmpty {
                        empty
                    } else {
                        logFilled
                    }
                } else {
                    reconcile
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
                .font(GeorgiaType.display)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(emptyLine)
                .font(GeorgiaType.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button(emptyAction) { dismiss() }
                .buttonStyle(PoolPressStyle(glass: true))
        }
        .padding(PoolChrome.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var logFilled: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PoolChrome.unit * 2) {
                failureBlock
                MarksTape(marks: todayMarks, stations: store.chart.stations)
                totals
            }
            .padding(PoolChrome.unit * 2)
            .padding(.bottom, PoolChrome.unit * 4)
        }
    }

    /// Count each door, then post the night. Not the tape.
    private var reconcile: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PoolChrome.unit * 2) {
                Text(gapWord)
                    .font(GeorgiaType.callout)
                    .foregroundStyle(DesignTokens.muted)
                Text(PoolFormat.cents(store.chart.remainingCents))
                    .font(GeorgiaType.title)
                    .foregroundStyle(DesignTokens.accent)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)
                Text(reconcileLine)
                    .font(GeorgiaType.body)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if !notice.isEmpty {
                    Text(notice)
                        .font(GeorgiaType.callout)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                failureBlock
                totals
                if store.chart.stations.isEmpty {
                    Text(emptyLine)
                        .font(GeorgiaType.body)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                ForEach(store.chart.stations) { station in
                    countCard(station)
                }
            }
            .padding(PoolChrome.unit * 2)
            .padding(.bottom, PoolChrome.unit * 8)
        }
        .safeAreaInset(edge: .bottom) {
            Button(postTitle) { postCount() }
                .buttonStyle(PoolPressStyle(filled: true))
                .padding(.horizontal, PoolChrome.unit * 2)
                .padding(.vertical, PoolChrome.unit)
                .background(DesignTokens.bg)
        }
    }

    @ViewBuilder
    private var failureBlock: some View {
        if store.loadFailed || store.chart.loadNote != nil {
            Text(failureLine)
                .font(GeorgiaType.callout)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Button(retryTitle) { store.reload() }
                .buttonStyle(PoolPressStyle(filled: true))
        }
    }

    private func countCard(_ station: Station) -> some View {
        let done = counted.contains(station.id)
        return Button {
            if done {
                counted.remove(station.id)
            } else {
                counted.insert(station.id)
            }
        } label: {
            VStack(alignment: .leading, spacing: PoolChrome.unit) {
                Text(station.name)
                    .font(GeorgiaType.headline)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(seatLine(station))
                    .font(GeorgiaType.body)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(done ? "Counted" : "Count this door")
                    .font(GeorgiaType.callout)
                    .foregroundStyle(done ? DesignTokens.bg : DesignTokens.ink)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(
                        done ? DesignTokens.accent : DesignTokens.bg,
                        in: RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous)
                    )
            }
            .padding(PoolChrome.unit * 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
        }
        .buttonStyle(.plain)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous)
                .stroke(DesignTokens.ink.opacity(0.25), lineWidth: 2)
        )
    }

    private var screenName: String { tapeFirst ? "Log" : "Finance" }
    private var emptyWord: String { "Tape" }
    private var emptyLine: String { "Nothing posted yet. Seat cash on a door." }
    private var emptyAction: String { "Back to doors" }
    private var retryTitle: String { "Retry load" }
    private var gapWord: String { "Still open" }
    private var postTitle: String { "Post the count" }
    private var reconcileLine: String {
        let countedCount = store.chart.stations.filter { counted.contains($0.id) }.count
        return "\(PoolFormat.count(countedCount)) of \(PoolFormat.count(store.chart.stations.count)) doors counted. Post the count to close the gap and ring a walk-in."
    }
    private var failureLine: String {
        store.chart.loadNote ?? "Saved night was unreadable. Showing the last good copy."
    }

    private var todayMarks: [FloorMark] {
        let key = DayKey.from(Date())
        let rows = store.chart.marks.filter { $0.dayKey == key }
        return rows.isEmpty ? store.chart.marks : rows
    }

    private var totals: some View {
        VStack(alignment: .leading, spacing: PoolChrome.unit) {
            row(openingLabel, PoolFormat.cents(store.chart.openingPoolCents))
            row(seatedLabel, PoolFormat.cents(store.chart.allocatedCents))
            row(walkInLabel, PoolFormat.cents(store.chart.floatCents))
            row(dayLabel, PoolFormat.dayKey(DayKey.from(Date())))
        }
        .padding(PoolChrome.unit * 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous)
                .stroke(DesignTokens.ink.opacity(0.25), lineWidth: 2)
        )
    }

    private func seatLine(_ door: Station) -> String {
        "Seated \(PoolFormat.cents(door.lotCents)). Cap \(PoolFormat.cents(door.capCents))."
    }

    private func postCount() {
        if let open = store.chart.stations.first(where: { $0.lotCents < $0.capCents }),
           store.chart.remainingCents > 0 {
            let room = open.capCents - open.lotCents
            let cents = min(store.chart.remainingCents, room)
            if cents > 0 {
                let placed = FloorFoldEngine.allocate(chart: store.chart, stationID: open.id, cents: cents)
                store.apply(placed)
            }
        }
        counted = Set(store.chart.stations.map(\.id))
        if let door = store.chart.stations.first(where: { $0.holdsLot }),
           store.chart.phase == .allocated || store.chart.phase == .live {
            let rung = FloorFoldEngine.ring(chart: store.chart, stationID: door.id, comp: false)
            store.apply(rung)
        }
        notice = "Count posted. Seated \(PoolFormat.cents(store.chart.allocatedCents)). Walk-ins \(PoolFormat.cents(store.chart.floatCents))."
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private var openingLabel: String { "Opening" }
    private var seatedLabel: String { "Seated" }
    private var walkInLabel: String { "Walk-ins" }
    private var dayLabel: String { "Day" }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(GeorgiaType.body)
                .foregroundStyle(DesignTokens.muted)
            Spacer(minLength: PoolChrome.unit)
            Text(value)
                .font(GeorgiaType.headline)
                .foregroundStyle(DesignTokens.ink)
        }
    }
}

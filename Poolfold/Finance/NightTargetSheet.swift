import SwiftUI

/// Night target. Distinct from the tape and from the bracket.
struct NightTargetSheet: View {
    @ObservedObject var store: FloorStore

    var body: some View {
        GoalsView(store: store)
    }
}

/// Each open door takes a lot. The primary verb places the remainder.
struct GoalsView: View {
    @ObservedObject var store: FloorStore
    @Environment(\.dismiss) private var dismiss
    @State private var notice = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PoolChrome.unit * 2) {
                    Text(remainingWord)
                        .font(GeorgiaType.callout)
                        .foregroundStyle(DesignTokens.muted)
                    Text(PoolFormat.cents(store.chart.remainingCents))
                        .font(GeorgiaType.title)
                        .foregroundStyle(DesignTokens.accent)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
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
                    if store.chart.stations.isEmpty {
                        Text(emptyLine)
                            .font(GeorgiaType.body)
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Button(placeDoorTitle) { placeFirstDoor() }
                            .buttonStyle(PoolPressStyle(filled: true))
                    }
                    ForEach(store.chart.stations) { station in
                        doorCard(station)
                    }
                }
                .padding(PoolChrome.unit * 2)
                .padding(.bottom, PoolChrome.unit * 8)
            }
            .background(DesignTokens.bg.ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                Button(primaryTitle) { placeRemaining() }
                    .buttonStyle(PoolPressStyle(filled: true))
                    .padding(.horizontal, PoolChrome.unit * 2)
                    .padding(.vertical, PoolChrome.unit)
                    .background(DesignTokens.bg)
            }
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

    private var screenName: String { "Goals" }
    private var remainingWord: String { "Still to place" }
    private var emptyLine: String { "No doors yet. Place the first door, then seat its cash." }
    private var placeDoorTitle: String { "Place first door" }
    private var primaryTitle: String {
        if store.chart.stations.isEmpty { return "Place first door" }
        if store.chart.remainingCents == 0 { return "Night target met" }
        if let open = openDoor { return "Seat cash on \(open.name)" }
        return "Seat remaining cash"
    }
    private var statusLine: String {
        if store.chart.remainingCents == 0 {
            return "Every door holds its opening share."
        }
        let openCount = store.chart.stations.filter { !$0.holdsLot }.count
        return "\(PoolFormat.count(openCount)) door still open. Seat the cash on that door."
    }

    private var openDoor: Station? {
        store.chart.stations.first { $0.lotCents < $0.capCents && store.chart.remainingCents > 0 }
    }

    private func doorCard(_ station: Station) -> some View {
        let open = station.lotCents < station.capCents && store.chart.remainingCents > 0
        let share = min(station.lotCents, station.capCents)
        let ratio = station.capCents == 0 ? 0 : CGFloat(share) / CGFloat(station.capCents)
        return Button {
            if open {
                place(on: station)
            } else {
                notice = "\(station.name) already holds its share."
            }
        } label: {
            VStack(alignment: .leading, spacing: PoolChrome.unit) {
                Text(station.name)
                    .font(GeorgiaType.headline)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(shareLine(station))
                    .font(GeorgiaType.body)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: PoolChrome.chip, style: .continuous)
                            .fill(DesignTokens.bg)
                        RoundedRectangle(cornerRadius: PoolChrome.chip, style: .continuous)
                            .fill(DesignTokens.accent)
                            .frame(width: max(8, proxy.size.width * ratio))
                    }
                }
                .frame(height: 12)
                .accessibilityLabel(shareLine(station))
                Text(open ? "Seat cash" : "Seated")
                    .font(GeorgiaType.callout)
                    .foregroundStyle(open ? DesignTokens.bg : DesignTokens.ink)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(
                        open ? DesignTokens.accent : DesignTokens.bg,
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

    private func shareLine(_ station: Station) -> String {
        "\(PoolFormat.cents(station.lotCents)) seated of \(PoolFormat.cents(station.capCents))"
    }

    private func placeRemaining() {
        if store.chart.stations.isEmpty {
            placeFirstDoor()
            return
        }
        guard let open = openDoor else {
            notice = "Every door holds its opening share."
            return
        }
        place(on: open)
    }

    private func place(on station: Station) {
        let room = station.capCents - station.lotCents
        let cents = min(store.chart.remainingCents, room)
        guard cents > 0 else {
            notice = "Nothing left to place."
            return
        }
        let outcome = FloorFoldEngine.allocate(chart: store.chart, stationID: station.id, cents: cents)
        store.apply(outcome)
        if outcome.committed {
            notice = "Cash seated on \(station.name). Still to place \(PoolFormat.cents(outcome.chart.remainingCents))."
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else if store.chart.phase == .dark {
            notice = "Clock in first, then seat the cash."
        } else {
            notice = "Cash refused. Pick the open door."
        }
    }

    private func placeFirstDoor() {
        let outcome = FloorFoldEngine.placeStation(chart: store.chart, name: "North door", capCents: 5000)
        store.apply(outcome)
        if outcome.committed {
            notice = "North door is on the board. Seat its cash next."
        }
    }
}

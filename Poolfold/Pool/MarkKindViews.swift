import SwiftUI

/// Lot rows from the tape. Distinct from the walk-in, refusal, cap, and short covers.
struct LotMarkView: View {
    @ObservedObject var store: FloorStore

    var body: some View {
        MarkKindFrame(word: word, note: note, imageName: "pfd_PoolTokenCrest", screenName: screenName) {
            Text(sumLine)
                .font(GeorgiaType.title)
                .foregroundStyle(DesignTokens.accent)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            markList(kind: .lot, empty: emptyRows)
        }
    }

    private var word: String { "Placed" }
    private var screenName: String { "Seated" }
    private var note: String { "Cash already seated on the doors." }
    private var emptyRows: String { "No cash seated yet." }
    private var sumLine: String { PoolFormat.cents(store.chart.allocatedCents) }

    @ViewBuilder
    private func markList(kind: MarkKind, empty: String) -> some View {
        MarkKindList(marks: store.chart.marks, stations: store.chart.stations, kind: kind, empty: empty)
    }
}

/// Walk-in till rows. Shows float, which stays at zero until the cash is seated.
struct TillMarkView: View {
    @ObservedObject var store: FloorStore

    var body: some View {
        MarkKindFrame(word: word, note: note, imageName: "pfd_TwistHero", screenName: screenName) {
            Text(sumLine)
                .font(GeorgiaType.title)
                .foregroundStyle(DesignTokens.accent)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(rateLine)
                .font(GeorgiaType.callout)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            MarkKindList(marks: store.chart.marks, stations: store.chart.stations, kind: .till, empty: emptyRows)
        }
    }

    private var word: String { "Walk-in" }
    private var screenName: String { "Walk-ins" }
    private var note: String { "A walk-in posts only after every door is seated." }
    private var emptyRows: String { "No walk-in posted yet." }
    private var sumLine: String { PoolFormat.cents(store.chart.floatCents) }
    private var rateLine: String { "Each walk-in is \(PoolFormat.cents(store.chart.walkInCents))." }
}

/// Refused rings. A drift row never changes the walk-in total.
struct DriftMarkView: View {
    @ObservedObject var store: FloorStore

    var body: some View {
        MarkKindFrame(word: word, note: note, imageName: "pfd_EmptyHome", screenName: screenName) {
            Text(phaseLine)
                .font(GeorgiaType.title)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            MarkKindList(marks: store.chart.marks, stations: store.chart.stations, kind: .drift, empty: emptyRows)
        }
    }

    private var word: String { "Refused" }
    private var screenName: String { "Refusals" }
    private var note: String { "Ring before the cash is seated. The till does not move." }
    private var emptyRows: String { "No refusal on the tape." }
    private var phaseLine: String { store.chart.phase.word }
}

/// Caps that would overflow. Lists each door limit.
struct OverMarkView: View {
    @ObservedObject var store: FloorStore

    var body: some View {
        MarkKindFrame(word: word, note: note, imageName: "pfd_EmptyFloorCutout", screenName: screenName) {
            ForEach(store.chart.stations) { station in
                HStack {
                    Text(station.name)
                        .font(GeorgiaType.body)
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(1)
                    Spacer(minLength: PoolChrome.unit)
                    Text(capLine(station))
                        .font(GeorgiaType.callout)
                        .foregroundStyle(DesignTokens.accent)
                        .monospacedDigit()
                }
                .frame(minHeight: 44)
            }
            MarkKindList(marks: store.chart.marks, stations: store.chart.stations, kind: .over, empty: emptyRows)
        }
    }

    private var word: String { "Caps" }
    private var screenName: String { "Caps" }
    private var note: String { "A door refuses cash above its cap." }
    private var emptyRows: String { "No cap refusal on the tape." }

    private func capLine(_ station: Station) -> String {
        PoolFormat.cents(station.capCents)
    }
}

/// Opening cash with nothing left to place.
struct DryMarkView: View {
    @ObservedObject var store: FloorStore

    var body: some View {
        MarkKindFrame(word: word, note: note, imageName: "pfd_Onboarding2", screenName: screenName) {
            Text(leftLine)
                .font(GeorgiaType.title)
                .foregroundStyle(DesignTokens.accent)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            MarkKindList(marks: store.chart.marks, stations: store.chart.stations, kind: .dry, empty: emptyRows)
        }
    }

    private var word: String { "Short" }
    private var screenName: String { "Short" }
    private var note: String { "When the opening cash is gone, another place is refused." }
    private var emptyRows: String { "Cash still remains. Place it on the open door." }
    private var leftLine: String { PoolFormat.cents(store.chart.remainingCents) }
}

private struct MarkKindFrame<Inner: View>: View {
    @Environment(\.dismiss) private var dismiss
    var word: String
    var note: String
    var imageName: String
    var screenName: String
    @ViewBuilder var inner: () -> Inner

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PoolChrome.unit * 2) {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 180)
                        .clipped()
                        .accessibilityHidden(true)
                    Text(word)
                        .font(GeorgiaType.display)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(note)
                        .font(GeorgiaType.body)
                        .foregroundStyle(DesignTokens.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    inner()
                }
                .padding(PoolChrome.unit * 2)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(DesignTokens.bg.ignoresSafeArea())
            .navigationTitle(screenName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(closeTitle) { dismiss() }
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
    }

    private var closeTitle: String { "Close" }
}

private struct MarkKindList: View {
    var marks: [FloorMark]
    var stations: [Station]
    var kind: MarkKind
    var empty: String

    var body: some View {
        let rows = marks.filter { $0.kind == kind }
        VStack(alignment: .leading, spacing: PoolChrome.unit) {
            if rows.isEmpty {
                Text(empty)
                    .font(GeorgiaType.body)
                    .foregroundStyle(DesignTokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ForEach(rows) { mark in
                Text(line(mark))
                    .font(GeorgiaType.body)
                    .foregroundStyle(DesignTokens.ink)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .padding(.horizontal, PoolChrome.unit * 2)
                    .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
            }
        }
    }

    private func line(_ mark: FloorMark) -> String {
        let door = stations.first { $0.id == mark.stationID }?.name ?? "Door"
        return "\(door). \(PoolFormat.cents(mark.cents))"
    }
}

import SwiftUI

/// Root split. The board never leaves. Shifts, bracket, finance, and settings are sheets.
struct FloorHomeView: View {
    @ObservedObject var store: FloorStore
    @Binding var sheet: CoverSheet?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedID: UUID?
    @State private var banner = ""
    @State private var compOpen = false
    @State private var plate = ""

    var body: some View {
        let chart = store.chart
        Group {
            if chart.phase == .bare {
                barePage
            } else {
                split
            }
        }
        .background(DesignTokens.bg.ignoresSafeArea())
        .sheet(isPresented: $compOpen) {
            compSheet
        }
        .onAppear {
            if selectedID == nil {
                selectedID = chart.stations.first(where: { !$0.holdsLot })?.id ?? chart.stations.first?.id
            }
        }
    }

    private var split: some View {
        GeometryReader { proxy in
            let wide = proxy.size.width > 700
            let rail = inspector
            Group {
                if wide {
                    HStack(alignment: .top, spacing: PoolChrome.unit * 2) {
                        boardColumn(includeStatus: true)
                        rail.frame(width: min(360, proxy.size.width * 0.38))
                    }
                } else {
                    VStack(alignment: .leading, spacing: PoolChrome.unit * 2) {
                        boardColumn(includeStatus: true)
                            .frame(minHeight: proxy.size.height * 0.46)
                        rail
                    }
                }
            }
            .padding(PoolChrome.unit * 2)
        }
    }

    private var status: some View {
        VStack(alignment: .leading, spacing: PoolChrome.unit) {
            Text(store.chart.phase.word)
                .font(GeorgiaType.display)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(statusLine)
                .font(GeorgiaType.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            if !banner.isEmpty {
                Text(banner)
                    .font(GeorgiaType.callout)
                    .foregroundStyle(DesignTokens.ink)
            }
            if let note = store.chart.loadNote {
                Text(note)
                    .font(GeorgiaType.callout)
                    .foregroundStyle(DesignTokens.ink)
            }
        }
    }

    private var statusLine: String {
        switch store.chart.phase {
        case .bare:
            "No doors yet. Place the first door."
        case .dark:
            "Doors are closed. Clock in, then seat the cash."
        case .onShift:
            "Cash is still open. Seat the remaining amount on the last door."
        case .allocated:
            "Every door is seated. Ring a walk-in, or seed the card."
        case .live:
            "Card live. Ring doors. Advance the on-deck pair."
        }
    }

    private func boardColumn(includeStatus: Bool) -> some View {
        VStack(alignment: .leading, spacing: PoolChrome.unit) {
            if includeStatus {
                status
            }
            IsometricFloorCanvas(
                stations: store.chart.stations,
                selectedID: selectedID,
                remainingLabel: PoolFormat.cents(store.chart.remainingCents),
                reduceMotion: reduceMotion,
                onSelect: { selectedID = $0 },
                onSnap: { id in
                    selectedID = id
                    placeLot(on: id)
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous)
                    .stroke(DesignTokens.ink.opacity(0.25), lineWidth: 2)
            )
            .modifier(PoolShadow())
        }
    }

    private var inspector: some View {
        VStack(alignment: .leading, spacing: PoolChrome.unit * 2) {
            twistCard
            if let station = selected {
                stationCard(station)
            }
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: PoolChrome.unit),
                    GridItem(.flexible(), spacing: PoolChrome.unit)
                ],
                spacing: PoolChrome.unit
            ) {
                coverButton(shiftsTitle, sheet: .shifts)
                coverButton(bracketTitle, sheet: .bracket)
                coverButton(financeTitle, sheet: .finance)
                coverButton(settingsTitle, sheet: .settings)
            }
        }
    }

    private var twistCard: some View {
        VStack(alignment: .leading, spacing: PoolChrome.unit) {
            HStack(alignment: .center, spacing: PoolChrome.unit * 2) {
                Image("pfd_PoolTokenCrest")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .accessibilityHidden(true)
                Text(cashHeading)
                    .font(GeorgiaType.caption)
                    .foregroundStyle(DesignTokens.muted)
            }
            Text(PoolFormat.cents(store.chart.remainingCents))
                .font(GeorgiaType.title)
                .foregroundStyle(DesignTokens.accent)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .fixedSize(horizontal: false, vertical: true)
            Text(cashDetail)
                .font(GeorgiaType.callout)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Button(placeLotTitle) { placeSelected() }
                .buttonStyle(PoolPressStyle(glass: true))
                .disabled(store.chart.phase != .onShift || store.chart.remainingCents == 0)
        }
        .padding(PoolChrome.unit * 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous)
                .stroke(DesignTokens.ink.opacity(0.25), lineWidth: 2)
        )
        .modifier(PoolShadow())
    }

    private func stationCard(_ station: Station) -> some View {
        VStack(alignment: .leading, spacing: PoolChrome.unit) {
            Text(station.name)
                .font(GeorgiaType.headline)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(doorLine(station))
                .font(GeorgiaType.callout)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: PoolChrome.unit) {
                Button(ringTitle) { ring(comp: false) }
                    .buttonStyle(PoolPressStyle(glass: true))
                Button(compTitle) { compOpen = true }
                    .buttonStyle(PoolPressStyle())
            }
        }
        .padding(PoolChrome.unit * 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous)
                .stroke(DesignTokens.ink.opacity(0.25), lineWidth: 2)
        )
    }

    private var barePage: some View {
        VStack(alignment: .leading, spacing: PoolChrome.unit * 2) {
            Spacer(minLength: PoolChrome.unit * 2)
            Image("pfd_EmptyFloorCutout")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 160)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            Image("pfd_EmptyHome")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 280)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            Text(emptyWord)
                .font(GeorgiaType.display)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(emptyLine)
                .font(GeorgiaType.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button(placeDoorTitle) {
                let outcome = FloorFoldEngine.placeStation(chart: store.chart, name: "North door", capCents: 5000)
                store.apply(outcome)
                if outcome.committed {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
            .buttonStyle(PoolPressStyle(glass: true))
            .frame(maxWidth: .infinity)
        }
        .padding(PoolChrome.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var compSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: PoolChrome.unit * 2) {
                Text(compHeading)
                    .font(GeorgiaType.title)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(compHint)
                    .font(GeorgiaType.body)
                    .foregroundStyle(DesignTokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
                TextField(memberField, text: $plate)
                    .keyboardType(.numberPad)
                    .font(GeorgiaType.body)
                    .padding(PoolChrome.unit * 2)
                    .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
                    .foregroundStyle(DesignTokens.ink)
                Button(compAdmitTitle) {
                    let digits = plate.filter(\.isNumber)
                    guard (8...14).contains(digits.count) else {
                        banner = "Plate refused. Use 8 to 14 digits."
                        return
                    }
                    ring(comp: true, plate: digits)
                    compOpen = false
                    plate = ""
                }
                .buttonStyle(PoolPressStyle(glass: true))
                Spacer()
            }
            .padding(PoolChrome.unit * 2)
            .background(DesignTokens.bg.ignoresSafeArea())
            .navigationTitle(compHeading)
            .navigationBarTitleDisplayMode(.inline)
            .poolKeyboardDone()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { compOpen = false }
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var shiftsTitle: String { "Clock" }
    private var bracketTitle: String { "Bracket" }
    private var financeTitle: String { "Finance" }
    private var settingsTitle: String { "Settings" }
    private var cashHeading: String { "Cash" }
    private var placeLotTitle: String { "Seat cash" }
    private var ringTitle: String { "Ring walk-in" }
    private var compTitle: String { "Comp member" }
    private var emptyWord: String { "Empty" }
    private var emptyLine: String { "No doors yet. Place the first door." }
    private var placeDoorTitle: String { "Place door" }
    private var compHeading: String { "Comp" }
    private var compHint: String { "Type the member number. A comp posts a walk-in with no cash added." }
    private var memberField: String { "Member number" }
    private var compAdmitTitle: String { "Comp admission" }

    private var cashDetail: String {
        "Opening \(PoolFormat.cents(store.chart.openingPoolCents)). Walk-ins \(PoolFormat.cents(store.chart.floatCents))."
    }

    private func doorLine(_ station: Station) -> String {
        let score = StationHealthCalculator.health(of: station)
        return "Health \(PoolFormat.count(score)). Cap \(PoolFormat.cents(station.capCents))."
    }

    private var selected: Station? {
        store.chart.stations.first { $0.id == selectedID } ?? store.chart.stations.first
    }

    private func coverButton(_ title: String, sheet: CoverSheet) -> some View {
        Button(title) { self.sheet = sheet }
            .buttonStyle(PoolPressStyle())
            .frame(maxWidth: .infinity)
    }

    private func placeSelected() {
        guard let id = selected?.id else { return }
        placeLot(on: id)
    }

    private func placeLot(on id: UUID) {
        guard let station = store.chart.stations.first(where: { $0.id == id }) else { return }
        let room = station.capCents - station.lotCents
        let cents = min(store.chart.remainingCents, room > 0 ? room : store.chart.remainingCents)
        let outcome = FloorFoldEngine.allocate(chart: store.chart, stationID: id, cents: max(cents, 1))
        store.apply(outcome)
        banner = message(for: outcome, verb: "Cash")
        if outcome.committed {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func ring(comp: Bool, plate: String = "") {
        guard let id = selected?.id else { return }
        let outcome = FloorFoldEngine.ring(chart: store.chart, stationID: id, comp: comp, plate: plate)
        store.apply(outcome)
        banner = message(for: outcome, verb: comp ? "Comp" : "Ring")
        if outcome.committed {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func message(for outcome: FloorFoldEngine.Outcome, verb: String) -> String {
        guard let last = outcome.chart.marks.last else {
            if outcome.chart.phase == .dark { return "Doors are closed. Clock in first." }
            return outcome.committed ? "\(verb) posted." : "\(verb) refused."
        }
        switch last.kind {
        case .lot: return "Cash seated. Left \(PoolFormat.cents(outcome.chart.remainingCents))."
        case .till: return "Walk-in posted. Taken \(PoolFormat.cents(outcome.chart.floatCents))."
        case .drift: return "Ring refused. Seat every door first."
        case .dry: return "No cash left to seat."
        case .over: return "Over cap. Pick the open door."
        case .bare: return "No doors yet. Place a door."
        default:
            return outcome.committed ? "\(verb) posted." : "\(verb) refused."
        }
    }
}

private struct PoolShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: Color.black.opacity(0.35), radius: PoolChrome.unit, x: 0, y: PoolChrome.unit / 2)
    }
}

enum CoverSheet: String, Identifiable {
    case shifts
    case bracket
    case finance
    case settings
    case goals
    case log
    case lotmark
    case tillmark
    case driftmark
    case overmark
    case drymark

    var id: String { rawValue }
}

import SwiftUI

/// Opening pool, maintenance, onboarding, reset, and the support link.
struct SettingsSheet: View {
    @ObservedObject var store: FloorStore
    var onReplay: () -> Void

    var body: some View {
        SettingsView(store: store, onReplay: onReplay)
    }
}

/// Live cover for the settings key.
struct SettingsView: View {
    @ObservedObject var store: FloorStore
    var onReplay: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var poolText = ""
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PoolChrome.unit * 2) {
                    Text(deskWord)
                        .font(GeorgiaType.display)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    if store.chart.stations.isEmpty {
                        Text(emptyLine)
                            .font(GeorgiaType.body)
                            .foregroundStyle(DesignTokens.muted)
                            .fixedSize(horizontal: false, vertical: true)
                        Button(placeDoorTitle) { placeDoor() }
                            .buttonStyle(PoolPressStyle(glass: true))
                    } else {
                        Text(openingLabel)
                            .font(GeorgiaType.headline)
                            .foregroundStyle(DesignTokens.ink)
                        TextField(centsField, text: $poolText)
                            .keyboardType(.numberPad)
                            .font(GeorgiaType.body)
                            .padding(PoolChrome.unit * 2)
                            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
                            .foregroundStyle(DesignTokens.ink)
                        Button(saveTitle) { savePool() }
                            .buttonStyle(PoolPressStyle(glass: true))
                            .disabled(store.chart.allocatedCents != 0)
                        ForEach(store.chart.stations) { station in
                            HStack {
                                VStack(alignment: .leading, spacing: PoolChrome.unit) {
                                    Text(station.name)
                                        .font(GeorgiaType.body)
                                        .foregroundStyle(DesignTokens.ink)
                                        .lineLimit(1)
                                    Text(healthLine(station))
                                        .font(GeorgiaType.caption)
                                        .foregroundStyle(DesignTokens.muted)
                                }
                                Spacer(minLength: PoolChrome.unit)
                                Button(maintTitle) {
                                    store.apply(FloorFoldEngine.logMaint(chart: store.chart, stationID: station.id))
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                }
                                .buttonStyle(PoolPressStyle())
                            }
                        }
                    }
                    Button(replayTitle) {
                        onReplay()
                        dismiss()
                    }
                    .buttonStyle(PoolPressStyle())
                    Button(resetTitle) { confirmReset = true }
                        .buttonStyle(PoolPressStyle(destructive: true))
                    if let contact {
                        Link(destination: contact) {
                            Text(contactTitle)
                                .font(GeorgiaType.callout)
                                .foregroundStyle(DesignTokens.ink)
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous)
                                .stroke(DesignTokens.ink.opacity(0.25), lineWidth: 2)
                        )
                    }
                }
                .padding(PoolChrome.unit * 2)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(DesignTokens.bg.ignoresSafeArea())
            .navigationTitle(screenName)
            .poolKeyboardDone()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
            .onAppear {
                if poolText.isEmpty {
                    poolText = PoolFormat.count(store.chart.openingPoolCents)
                }
            }
            .confirmationDialog(
                "Reset all data? Stations, lots, and the tape are removed from this device.",
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button("Reset all data", role: .destructive) {
                    store.resetAllData()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private var screenName: String { "Settings" }
    private var deskWord: String { "Desk" }
    private var emptyLine: String { "No doors yet. Place the first one." }
    private var placeDoorTitle: String { "Place door" }
    private var openingLabel: String { "Opening cash" }
    private var centsField: String { "Cents" }
    private var saveTitle: String { "Save cash" }
    private var maintTitle: String { "Log maint" }
    private var replayTitle: String { "Show intro again" }
    private var resetTitle: String { "Reset all data" }
    private var contactTitle: String { "Contact Avialobik" }
    private var contact: URL? { URL(string: "https://poolfold-floor.pro/contact-us") }

    private func healthLine(_ station: Station) -> String {
        "Health \(PoolFormat.count(StationHealthCalculator.health(of: station)))"
    }

    private func placeDoor() {
        let outcome = FloorFoldEngine.placeStation(chart: store.chart, name: "North door", capCents: 5000)
        store.apply(outcome)
        if outcome.committed {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func savePool() {
        let digits = poolText.filter(\.isNumber)
        guard let cents = Int(digits), cents > 0 else { return }
        store.setOpeningPool(cents)
    }
}

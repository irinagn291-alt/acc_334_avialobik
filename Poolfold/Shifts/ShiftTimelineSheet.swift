import SwiftUI

/// Vertical shift timeline and clock. Clock writes a ShiftMark and folds Dark to OnShift.
struct ShiftTimelineSheet: View {
    @ObservedObject var store: FloorStore

    var body: some View {
        ShiftsView(store: store)
    }
}

/// Live cover for the shifts key. Clock stays on this sheet.
struct ShiftsView: View {
    @ObservedObject var store: FloorStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    var body: some View {
        NavigationStack {
            Group {
                if store.chart.staff.isEmpty && store.chart.shifts.isEmpty {
                    empty
                } else {
                    filled
                }
            }
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
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: PoolChrome.unit * 2) {
            Image("pfd_EmptyFloorCutout")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 200)
                .accessibilityHidden(true)
            Text(emptyWord)
                .font(GeorgiaType.display)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(emptyLine)
                .font(GeorgiaType.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            field
            Button(addTitle) { addStaff() }
                .buttonStyle(PoolPressStyle(glass: true))
            Spacer()
        }
        .padding(PoolChrome.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var filled: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PoolChrome.unit * 2) {
                Text(phaseWord)
                    .font(GeorgiaType.display)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if let note = store.chart.loadNote {
                    Text(note)
                        .font(GeorgiaType.callout)
                        .foregroundStyle(DesignTokens.ink)
                    Button(retryTitle) {
                        store.reload()
                    }
                    .buttonStyle(PoolPressStyle())
                }
                StaffRosterView(staff: store.chart.staff)
                timeline
                field
                Button(addTitle) { addStaff() }
                    .buttonStyle(PoolPressStyle())
                Button(clockTitle) { clock() }
                    .buttonStyle(PoolPressStyle(glass: true))
                    .disabled(store.chart.shifts.contains(where: { $0.open }) || store.chart.phase == .bare)
            }
            .padding(PoolChrome.unit * 2)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: PoolChrome.unit) {
            if store.chart.shifts.isEmpty {
                Text(noShiftLine)
                    .font(GeorgiaType.body)
                    .foregroundStyle(DesignTokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ForEach(store.chart.shifts) { shift in
                VStack(alignment: .leading, spacing: PoolChrome.unit / 2) {
                    Text(shiftState(shift))
                        .font(GeorgiaType.headline)
                        .foregroundStyle(DesignTokens.ink)
                    Text(dayLine(shift))
                        .font(GeorgiaType.callout)
                        .foregroundStyle(DesignTokens.muted)
                        .monospacedDigit()
                    if let staff = store.chart.staff.first(where: { $0.id == shift.staffID }) {
                        Text(staff.name)
                            .font(GeorgiaType.body)
                            .foregroundStyle(DesignTokens.ink)
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
        }
    }

    private var field: some View {
        TextField(nameField, text: $name)
            .font(GeorgiaType.body)
            .padding(PoolChrome.unit * 2)
            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
            .foregroundStyle(DesignTokens.ink)
    }

    private var screenName: String { "Clock" }
    private var emptyWord: String { "Roster" }
    private var emptyLine: String { "Roster empty. Add a name, then clock in." }
    private var addTitle: String { "Add name" }
    private var clockTitle: String { "Clock in" }
    private var retryTitle: String { "Retry load" }
    private var noShiftLine: String { "No clock yet. Clock in to open the cash." }
    private var nameField: String { "Name" }
    private var phaseWord: String { store.chart.phase == .dark ? "Closed" : "Open" }

    private func shiftState(_ shift: Shift) -> String {
        shift.open ? "Open" : "Closed"
    }

    private func dayLine(_ shift: Shift) -> String {
        "Day \(PoolFormat.dayKey(shift.dayKey))"
    }

    private func addStaff() {
        let outcome = FloorFoldEngine.addStaff(chart: store.chart, name: name)
        store.apply(outcome)
        if outcome.committed { name = "" }
    }

    private func clock() {
        let outcome = FloorFoldEngine.clock(chart: store.chart, staffID: store.chart.staff.first?.id)
        store.apply(outcome)
        if outcome.committed {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

}

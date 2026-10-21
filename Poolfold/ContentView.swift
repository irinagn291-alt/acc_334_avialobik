import SwiftUI

/// Live cover router. Read ReviewLaunch.screen once after onboarding.
struct ContentView: View {
    @StateObject private var store = FloorStore()
    @Environment(\.scenePhase) private var scenePhase
    @State private var sheet: CoverSheet?
    @State private var replay = false
    @State private var didRoute = false

    var body: some View {
        Group {
            if store.chart.onboardingDone && !replay {
                FloorHomeView(store: store, sheet: $sheet)
            } else {
                OnboardingView { _ in
                    store.finishOnboarding(skip: true)
                    replay = false
                    routeIfNeeded()
                }
            }
        }
        .sheet(item: $sheet) { cover in
            sheetBody(cover)
                .modifier(SheetEntry())
        }
        .onAppear { routeIfNeeded() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .inactive || phase == .background {
                Task { await store.flush() }
            }
        }
    }

    @ViewBuilder
    private func sheetBody(_ cover: CoverSheet) -> some View {
        switch cover {
        case .shifts:
            ShiftTimelineSheet(store: store)
        case .bracket:
            BracketInterleaveSheet(store: store)
        case .finance:
            FinanceReconcileSheet(store: store)
        case .settings:
            SettingsSheet(store: store) { replay = true }
        case .goals:
            NightTargetSheet(store: store)
        case .log:
            FinanceReconcileSheet(store: store, tapeFirst: true)
        case .lotmark:
            LotMarkView(store: store)
        case .tillmark:
            TillMarkView(store: store)
        case .driftmark:
            DriftMarkView(store: store)
        case .overmark:
            OverMarkView(store: store)
        case .drymark:
            DryMarkView(store: store)
        }
    }

    private func routeIfNeeded() {
        guard store.chart.onboardingDone, !didRoute else { return }
        didRoute = true
        guard let key = ReviewLaunch.screen, key != "today" else { return }
        sheet = CoverSheet(rawValue: key)
    }
}

private struct SheetEntry: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .scaleEffect(reduceMotion ? 1 : (shown ? 1 : 0.96))
            .onAppear {
                if reduceMotion {
                    shown = true
                } else {
                    withAnimation(.easeOut(duration: PoolChrome.motion)) { shown = true }
                }
            }
    }
}

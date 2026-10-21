import SwiftUI

/// Three pages. Skip and continue both write a clocked house so the first lot can land.
struct OnboardingView: View {
    var finish: (Bool) -> Void
    @State private var page = 0

    private let pages: [(String, String, String)] = [
        ("Cash", "Split tonight's opening cash across the doors before anyone rings in.", "pfd_Onboarding1"),
        ("Place", "Drag the remaining cash onto the open door. Every door has to match first.", "pfd_Onboarding2"),
        ("Ring", "After the cash matches, ring walk-ins and advance the card.", "pfd_Onboarding3")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: PoolChrome.unit * 2) {
            Spacer(minLength: PoolChrome.unit)
            Image(pages[page].2)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 360, maxHeight: 420)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            Text(pages[page].0)
                .font(GeorgiaType.display)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(pages[page].1)
                .font(GeorgiaType.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button(page < pages.count - 1 ? "Next" : "Continue") {
                if page < pages.count - 1 {
                    page += 1
                } else {
                    finish(false)
                }
            }
            .buttonStyle(PoolPressStyle(glass: true))
            .frame(maxWidth: .infinity)
            Button("Skip") { finish(true) }
                .buttonStyle(PoolPressStyle())
                .frame(maxWidth: .infinity)
        }
        .padding(PoolChrome.unit * 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(DesignTokens.bg.ignoresSafeArea())
    }
}

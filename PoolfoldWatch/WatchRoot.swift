import SwiftUI

@main
struct PoolfoldWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchRoot()
        }
    }
}

/// Apple Watch cover. Same today, log, and goals keys as the phone.
struct WatchRoot: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(headline)
                .font(.headline)
            Text(detail)
                .font(.caption2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(8)
    }

    private var headline: String {
        switch ReviewLaunch.screen {
        case "log": "Tape"
        case "goals": "Target"
        default: "Doors"
        }
    }

    private var detail: String {
        switch ReviewLaunch.screen {
        case "log": "Walk-in rows stay on the phone."
        case "goals": "Seat the opening cash before a walk-in."
        default: "Seat the open cash on the door."
        }
    }
}

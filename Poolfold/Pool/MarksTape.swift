import SwiftUI

/// Append-only mark rows for the day key.
struct MarksTape: View {
    var marks: [FloorMark]
    var stations: [Station]

    var body: some View {
        VStack(alignment: .leading, spacing: PoolChrome.unit) {
            Text(tapeHeading)
                .font(GeorgiaType.title)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            if marks.isEmpty {
                Text(emptyLine)
                    .font(GeorgiaType.body)
                    .foregroundStyle(DesignTokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ForEach(marks.reversed()) { mark in
                VStack(alignment: .leading, spacing: PoolChrome.unit) {
                    Text(label(mark))
                        .font(GeorgiaType.body)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(meta(mark))
                        .font(GeorgiaType.caption)
                        .foregroundStyle(DesignTokens.muted)
                        .monospacedDigit()
                }
                .padding(PoolChrome.unit * 2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: PoolChrome.chip, style: .continuous)
                        .stroke(DesignTokens.ink.opacity(0.2), lineWidth: 2)
                )
            }
        }
    }

    private var tapeHeading: String { "Tape" }
    private var emptyLine: String { "Tape empty for this day." }

    private func meta(_ mark: FloorMark) -> String {
        "Day \(PoolFormat.dayKey(mark.dayKey)). \(PoolFormat.cents(mark.cents))"
    }

    private func label(_ mark: FloorMark) -> String {
        let station = stations.first { $0.id == mark.stationID }?.name ?? ""
        switch mark.kind {
        case .bare: return "Empty. No doors yet."
        case .shift: return "Clocked in."
        case .lot: return "Seated. \(station)"
        case .till: return "Walk-in. \(station). \(mark.detail)"
        case .drift: return "Refused. Ring held."
        case .over: return "Over cap. \(station)"
        case .dry: return "Short. No cash left."
        case .advance: return "Advanced. \(mark.detail)"
        case .fault: return "Out of turn. \(mark.detail)"
        }
    }
}

import SwiftUI

/// Pair rows for the bout strip. On-deck names are buttons.
struct BoutStripView: View {
    var bout: Bout
    var onDeck: [UUID]
    var onTap: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PoolChrome.unit) {
            if bout.matches.isEmpty {
                Text(waitingLine)
                    .font(GeorgiaType.body)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ForEach(bout.matches.sorted(by: { ($0.round, $0.slot) < ($1.round, $1.slot) })) { match in
                VStack(alignment: .leading, spacing: PoolChrome.unit) {
                    Text(roundLine(match))
                        .font(GeorgiaType.caption)
                        .foregroundStyle(DesignTokens.muted)
                    nameButton(match.leftID)
                    nameButton(match.rightID)
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

    private var waitingLine: String { "Names land here after you seed the pairs." }
    private var openSeat: String { "Winner arrives from the pair above" }

    private func roundLine(_ match: BoutMatch) -> String {
        "Round \(PoolFormat.count(match.round + 1))"
    }

    private func nameLine(_ name: String, onDeck: Bool) -> String {
        onDeck ? "\(name), on deck" : name
    }

    @ViewBuilder
    private func nameButton(_ id: UUID?) -> some View {
        if let id, let entrant = bout.entrants.first(where: { $0.id == id }) {
            let deck = onDeck.contains(id)
            Button(nameLine(entrant.name, onDeck: deck)) { onTap(id) }
                .buttonStyle(PoolPressStyle(filled: deck))
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text(openSeat)
                .font(GeorgiaType.body)
                .foregroundStyle(DesignTokens.muted)
                .frame(minHeight: 44, alignment: .leading)
        }
    }
}

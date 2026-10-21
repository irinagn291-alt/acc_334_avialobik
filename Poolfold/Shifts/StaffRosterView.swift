import SwiftUI

/// Staff names beside the shift timeline.
struct StaffRosterView: View {
    var staff: [Staff]

    var body: some View {
        VStack(alignment: .leading, spacing: PoolChrome.unit) {
            Text("Roster")
                .font(GeorgiaType.caption)
                .foregroundStyle(DesignTokens.muted)
            if staff.isEmpty {
                Text("No names yet.")
                    .font(GeorgiaType.body)
                    .foregroundStyle(DesignTokens.muted)
            }
            ForEach(staff) { person in
                HStack {
                    Text(person.name)
                        .font(GeorgiaType.body)
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(1)
                    Spacer(minLength: PoolChrome.unit)
                    Text(person.role)
                        .font(GeorgiaType.caption)
                        .foregroundStyle(DesignTokens.ink)
                        .padding(.horizontal, PoolChrome.unit)
                        .frame(minHeight: 28)
                        .background(DesignTokens.bg, in: RoundedRectangle(cornerRadius: PoolChrome.chip, style: .continuous))
                }
                .padding(PoolChrome.unit * 2)
                .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
            }
        }
    }
}

import SwiftUI
import UIKit

/// Six Georgia steps. The only font name is DesignTokens.fontFamily.
enum GeorgiaType {
    static let display = Font.custom(DesignTokens.fontFamily, size: 40, relativeTo: .largeTitle)
    static let title = Font.custom(DesignTokens.fontFamily, size: 28, relativeTo: .title)
    static let headline = Font.custom(DesignTokens.fontFamily, size: 22, relativeTo: .title2)
    static let body = Font.custom(DesignTokens.fontFamily, size: 17, relativeTo: .body)
    static let callout = Font.custom(DesignTokens.fontFamily, size: 15, relativeTo: .callout)
    static let caption = Font.custom(DesignTokens.fontFamily, size: 13, relativeTo: .caption)
}

/// 8pt grid, 4pt cards, 2pt chips, one shadow, tinted glass primary.
enum PoolChrome {
    static let unit: CGFloat = 8
    static let card: CGFloat = 4
    static let chip: CGFloat = 2
    static let press: CGFloat = 0.97
    static let motion: Double = 0.16

    static func shadow<V: View>(_ view: V) -> some View {
        view.shadow(color: Color.black.opacity(0.35), radius: PoolChrome.unit, x: 0, y: PoolChrome.unit / 2)
    }
}

struct PoolPressStyle: ButtonStyle {
    var glass: Bool = false
    var filled: Bool = false
    var destructive: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GeorgiaType.callout)
            .foregroundStyle(filled ? DesignTokens.bg : DesignTokens.ink)
            .padding(.horizontal, PoolChrome.unit * 2)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background {
                if filled {
                    RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous)
                        .fill(DesignTokens.accent)
                } else if glass {
                    RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous)
                                .fill(DesignTokens.accent.opacity(0.34))
                        )
                } else if destructive {
                    RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous)
                        .fill(DesignTokens.surface)
                } else {
                    RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous)
                        .fill(DesignTokens.surface)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous)
                    .stroke(DesignTokens.ink.opacity(glass ? 0.0 : 0.35), lineWidth: 2)
            )
            .scaleEffect(!reduceMotion && configuration.isPressed ? PoolChrome.press : 1)
            .opacity(configuration.isPressed ? 0.82 : (isEnabled ? 1 : 0.4))
            .animation(reduceMotion ? .easeOut(duration: PoolChrome.motion) : .easeOut(duration: PoolChrome.motion), value: configuration.isPressed)
            .contentShape(RoundedRectangle(cornerRadius: PoolChrome.card, style: .continuous))
    }
}

@MainActor
enum PoolKeyboard {
    static var done: String { "Done" }

    static func hide() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

extension View {
    func poolKeyboardDone() -> some View {
        scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(PoolKeyboard.done) { PoolKeyboard.hide() }
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
    }
}

enum PoolFormat {
    static func cents(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: Double(value) / 100.0)) ?? "0"
    }

    static func count(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func dayKey(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

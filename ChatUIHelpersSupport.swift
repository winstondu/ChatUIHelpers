import SwiftUI

/// A button style that briefly scales a button while it is pressed.
public struct BounceButtonStyle: ButtonStyle {
    public var scale: CGFloat

    public init(scale: CGFloat = 0.9) {
        self.scale = scale
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.easeOut(duration: configuration.isPressed ? 0.1 : 0.3), value: configuration.isPressed)
    }
}

public extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

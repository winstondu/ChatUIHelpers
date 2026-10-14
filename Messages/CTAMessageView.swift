import SwiftUI

public struct CTAMessageStyle: Sendable {
    public var bodyFont: Font
    public var buttonFont: Font
    public var bodyTextColor: Color
    public var buttonBackgroundColor: Color

    public init(
        bodyFont: Font = .system(size: 16),
        buttonFont: Font = .system(size: 15, weight: .medium),
        bodyTextColor: Color = .black,
        buttonBackgroundColor: Color = .black
    ) {
        self.bodyFont = bodyFont
        self.buttonFont = buttonFont
        self.bodyTextColor = bodyTextColor
        self.buttonBackgroundColor = buttonBackgroundColor
    }
}

public struct CTAMessageView: View {
    let text: String
    let ctaLabel: String
    let icon: Image
    let style: CTAMessageStyle
    let onCTATap: () -> Void

    public init(
        text: String,
        ctaLabel: String,
        icon: Image = Image(systemName: "arrow.right"),
        style: CTAMessageStyle = CTAMessageStyle(),
        onCTATap: @escaping () -> Void
    ) {
        self.text = text
        self.ctaLabel = ctaLabel
        self.icon = icon
        self.style = style
        self.onCTATap = onCTATap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(text)
                .font(style.bodyFont)
                .foregroundColor(style.bodyTextColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 18,
                        bottomLeadingRadius: 2,
                        bottomTrailingRadius: 18,
                        topTrailingRadius: 18
                    )
                )

            Button(action: onCTATap) {
                HStack(spacing: 8) {
                    Text(ctaLabel)
                        .font(style.buttonFont)
                        .foregroundColor(.white)
                        .lineLimit(1)

                    icon
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(style.buttonBackgroundColor)
                .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CTAMessageView(
            text: "I need you to do something first.\nClick this:",
            ctaLabel: "Complete Profile",
            onCTATap: {}
        )
        .padding(.horizontal, 16)
    }
}

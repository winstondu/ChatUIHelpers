import SwiftUI

public enum RequestStatus: String, Sendable {
    case pending
    case approved
    case declined
}

public struct RequestActionButtonStyle: Sendable {
    public let declineTextColor: Color
    public let declineBackgroundColor: Color
    public let approveTextColor: Color
    public let approveBackgroundColor: Color
    public let buttonHeight: CGFloat
    public let cornerRadius: CGFloat
    public let spacing: CGFloat
    public let font: Font

    public init(
        declineTextColor: Color = .white,
        declineBackgroundColor: Color = Color.white.opacity(0.15),
        approveTextColor: Color = .black,
        approveBackgroundColor: Color = .white,
        buttonHeight: CGFloat = 40,
        cornerRadius: CGFloat = 20,
        spacing: CGFloat = 12,
        font: Font = .system(size: 14, weight: .medium)
    ) {
        self.declineTextColor = declineTextColor
        self.declineBackgroundColor = declineBackgroundColor
        self.approveTextColor = approveTextColor
        self.approveBackgroundColor = approveBackgroundColor
        self.buttonHeight = buttonHeight
        self.cornerRadius = cornerRadius
        self.spacing = spacing
        self.font = font
    }

    public static let `default` = RequestActionButtonStyle()
}

public struct RequestActionButtons: View {
    let declineTitle: String
    let approveTitle: String
    let onDecline: () -> Void
    let onApprove: () -> Void
    let style: RequestActionButtonStyle

    public init(
        declineTitle: String,
        approveTitle: String,
        style: RequestActionButtonStyle = .default,
        onDecline: @escaping () -> Void,
        onApprove: @escaping () -> Void
    ) {
        self.declineTitle = declineTitle
        self.approveTitle = approveTitle
        self.style = style
        self.onDecline = onDecline
        self.onApprove = onApprove
    }

    public var body: some View {
        HStack(spacing: style.spacing) {
            Button(action: onDecline) {
                Text(declineTitle)
                    .font(style.font)
                    .foregroundColor(style.declineTextColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: style.buttonHeight)
                    .background(style.declineBackgroundColor)
                    .clipShape(buttonShape)
            }

            Button(action: onApprove) {
                Text(approveTitle)
                    .font(style.font)
                    .foregroundColor(style.approveTextColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: style.buttonHeight)
                    .background(style.approveBackgroundColor)
                    .clipShape(buttonShape)
            }
        }
    }

    private var buttonShape: AnyShape {
        if style.cornerRadius == .infinity {
            AnyShape(Capsule())
        } else {
            AnyShape(RoundedRectangle(cornerRadius: style.cornerRadius))
        }
    }
}

public struct RequestStatusLabel: View {
    let status: RequestStatus
    let style: RequestStatusLabelStyle

    public init(status: RequestStatus, style: RequestStatusLabelStyle = .default) {
        self.status = status
        self.style = style
    }

    public var body: some View {
        Text(style.formatStatus(status))
            .font(style.font)
            .foregroundColor(style.textColor)
            .tracking(style.tracking)
    }
}

public struct RequestStatusLabelStyle: Sendable {
    public let font: Font
    public let textColor: Color
    public let tracking: CGFloat
    public let formatStatus: @Sendable (RequestStatus) -> String

    public init(
        font: Font = .system(size: 14, weight: .medium),
        textColor: Color = Color.white.opacity(0.5),
        tracking: CGFloat = 0,
        formatStatus: @escaping @Sendable (RequestStatus) -> String = { $0.rawValue.capitalized }
    ) {
        self.font = font
        self.textColor = textColor
        self.tracking = tracking
        self.formatStatus = formatStatus
    }

    public static let `default` = RequestStatusLabelStyle()
}

#Preview("Buttons") {
    ZStack {
        Color.black
        RequestActionButtons(
            declineTitle: "Decline",
            approveTitle: "Approve",
            onDecline: {},
            onApprove: {}
        )
        .padding()
    }
}

#Preview("Status Labels") {
    VStack(spacing: 20) {
        RequestStatusLabel(status: .pending)
        RequestStatusLabel(status: .approved)
    }
    .padding()
    .background(Color.black)
}

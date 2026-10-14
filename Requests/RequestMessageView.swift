import SwiftUI

public struct RequestMessageStyle: Sendable {
    public let cardBackground: Color
    public let borderColor: Color
    public let buttonStyle: RequestActionButtonStyle
    public let statusStyle: RequestStatusLabelStyle

    public init(
        cardBackground: Color = Color.white.opacity(0.9),
        borderColor: Color = Color.white.opacity(0.3),
        buttonStyle: RequestActionButtonStyle = .default,
        statusStyle: RequestStatusLabelStyle = .default
    ) {
        self.cardBackground = cardBackground
        self.borderColor = borderColor
        self.buttonStyle = buttonStyle
        self.statusStyle = statusStyle
    }

    public static let `default` = RequestMessageStyle()
}

public struct RequestMessageView<Content: View>: View {
    let isFromCurrentUser: Bool
    let status: RequestStatus
    let declineButtonTitle: String
    let approveButtonTitle: String
    let style: RequestMessageStyle
    let onDecline: () -> Void
    let onApprove: () -> Void
    let content: () -> Content

    public init(
        isFromCurrentUser: Bool,
        status: RequestStatus,
        declineButtonTitle: String,
        approveButtonTitle: String,
        style: RequestMessageStyle = .default,
        onDecline: @escaping () -> Void,
        onApprove: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isFromCurrentUser = isFromCurrentUser
        self.status = status
        self.declineButtonTitle = declineButtonTitle
        self.approveButtonTitle = approveButtonTitle
        self.style = style
        self.onDecline = onDecline
        self.onApprove = onApprove
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
                .padding(16)
                .background(style.cardBackground)
                .cornerRadius(14)

            if isFromCurrentUser || status != .pending {
                RequestStatusLabel(status: status, style: style.statusStyle)
                    .padding(.leading, 12)
                    .padding(.bottom, 4)
            } else {
                RequestActionButtons(
                    declineTitle: declineButtonTitle,
                    approveTitle: approveButtonTitle,
                    style: style.buttonStyle,
                    onDecline: onDecline,
                    onApprove: onApprove
                )
            }
        }
        .padding(8)
        .frame(maxWidth: 240)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(style.borderColor, lineWidth: 1)
        )
    }
}

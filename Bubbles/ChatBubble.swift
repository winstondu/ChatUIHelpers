import SwiftUI

public struct ChatBubble<Content: View>: View {
    private let isFromCurrentUser: Bool
    private let background: Color
    private let tailRadius: CGFloat
    private let horizontalPadding: CGFloat
    private let verticalPadding: CGFloat
    private let content: Content

    public init(
        isFromCurrentUser: Bool,
        background: Color,
        tailRadius: CGFloat = 0,
        horizontalPadding: CGFloat = 16,
        verticalPadding: CGFloat = 12,
        @ViewBuilder content: () -> Content
    ) {
        self.isFromCurrentUser = isFromCurrentUser
        self.background = background
        self.tailRadius = tailRadius
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(background)
            .clipShape(ChatBubbleShape(isFromCurrentUser: isFromCurrentUser, tailRadius: tailRadius))
    }
}

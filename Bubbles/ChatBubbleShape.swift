import SwiftUI

public struct ChatBubbleShape: Shape {
    public var isFromCurrentUser: Bool
    public var cornerRadius: CGFloat
    public var tailRadius: CGFloat

    public init(isFromCurrentUser: Bool, cornerRadius: CGFloat = 18, tailRadius: CGFloat = 0) {
        self.isFromCurrentUser = isFromCurrentUser
        self.cornerRadius = cornerRadius
        self.tailRadius = tailRadius
    }

    public func path(in rect: CGRect) -> Path {
        UnevenRoundedRectangle(
            topLeadingRadius: cornerRadius,
            bottomLeadingRadius: isFromCurrentUser ? cornerRadius : tailRadius,
            bottomTrailingRadius: isFromCurrentUser ? tailRadius : cornerRadius,
            topTrailingRadius: cornerRadius
        )
        .path(in: rect)
    }
}

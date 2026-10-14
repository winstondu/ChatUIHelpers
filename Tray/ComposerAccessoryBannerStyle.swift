import SwiftUI

public struct ComposerAccessoryBannerStyle: Sendable {
    public var contentSpacing: CGFloat
    public var textSpacing: CGFloat
    public var titleFont: Font
    public var titleColor: Color
    public var subtitleFont: Font
    public var subtitleColor: Color
    public var subtitleLineLimit: Int
    public var spacerMinLength: CGFloat?
    public var closeIconSize: CGFloat
    public var closeIconFitsAspect: Bool
    public var closeIconColor: Color
    public var closeButtonSize: CGFloat
    public var closeButtonBackground: Color
    public var padding: EdgeInsets
    public var fixesVerticalSize: Bool

    public init(
        contentSpacing: CGFloat = 12,
        textSpacing: CGFloat = 4,
        titleFont: Font = .system(size: 14, weight: .medium),
        titleColor: Color = .primary,
        subtitleFont: Font = .system(size: 12),
        subtitleColor: Color = .secondary,
        subtitleLineLimit: Int = 1,
        spacerMinLength: CGFloat? = 0,
        closeIconSize: CGFloat = 12,
        closeIconFitsAspect: Bool = true,
        closeIconColor: Color = .secondary,
        closeButtonSize: CGFloat = 32,
        closeButtonBackground: Color = Color(.secondarySystemBackground),
        padding: EdgeInsets = EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12),
        fixesVerticalSize: Bool = false
    ) {
        self.contentSpacing = contentSpacing
        self.textSpacing = textSpacing
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.subtitleFont = subtitleFont
        self.subtitleColor = subtitleColor
        self.subtitleLineLimit = subtitleLineLimit
        self.spacerMinLength = spacerMinLength
        self.closeIconSize = closeIconSize
        self.closeIconFitsAspect = closeIconFitsAspect
        self.closeIconColor = closeIconColor
        self.closeButtonSize = closeButtonSize
        self.closeButtonBackground = closeButtonBackground
        self.padding = padding
        self.fixesVerticalSize = fixesVerticalSize
    }
}

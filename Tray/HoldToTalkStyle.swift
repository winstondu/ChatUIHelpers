import SwiftUI

public struct HoldToTalkStyle: Sendable {
    public var title: String
    public var titleFont: Font
    public var recordingDurationFont: Font
    public var previewDurationFont: Font
    public var foreground: Color
    public var background: Color
    public var sendButtonBackground: Color
    public var sendButtonForeground: Color
    public var trashIcon: Image

    public init(
        title: String = "Hold to talk",
        titleFont: Font = .system(size: 15, weight: .medium),
        recordingDurationFont: Font = .system(size: 15, weight: .medium),
        previewDurationFont: Font = .system(size: 12),
        foreground: Color = .primary,
        background: Color = Color(.secondarySystemBackground),
        sendButtonBackground: Color = .primary,
        sendButtonForeground: Color = .white,
        trashIcon: Image = Image(systemName: "trash")
    ) {
        self.title = title
        self.titleFont = titleFont
        self.recordingDurationFont = recordingDurationFont
        self.previewDurationFont = previewDurationFont
        self.foreground = foreground
        self.background = background
        self.sendButtonBackground = sendButtonBackground
        self.sendButtonForeground = sendButtonForeground
        self.trashIcon = trashIcon
    }
}

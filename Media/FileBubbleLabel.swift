import SwiftUI

public struct FileBubbleStyle: Sendable {
    public let nameFont: Font
    public let nameColor: Color
    public let sizeFont: Font
    public let sizeColor: Color
    public let iconColor: Color
    public let iconBackground: Color
    public let progressTint: Color

    public init(
        nameFont: Font = .system(size: 15, weight: .medium),
        nameColor: Color = Color.white.opacity(0.8),
        sizeFont: Font = .system(size: 12),
        sizeColor: Color = Color.white.opacity(0.5),
        iconColor: Color = .white,
        iconBackground: Color = Color.white.opacity(0.1),
        progressTint: Color = .white
    ) {
        self.nameFont = nameFont
        self.nameColor = nameColor
        self.sizeFont = sizeFont
        self.sizeColor = sizeColor
        self.iconColor = iconColor
        self.iconBackground = iconBackground
        self.progressTint = progressTint
    }

    public static let `default` = FileBubbleStyle()
}

public struct FileBubbleLabel: View {
    let fileName: String
    let fileSize: String
    let icon: Image
    let isDownloading: Bool
    let style: FileBubbleStyle

    public init(
        fileName: String,
        fileSize: String,
        icon: Image = Image(systemName: "doc.fill"),
        isDownloading: Bool = false,
        style: FileBubbleStyle = .default
    ) {
        self.fileName = fileName
        self.fileSize = fileSize
        self.icon = icon
        self.isDownloading = isDownloading
        self.style = style
    }

    public var body: some View {
        HStack(spacing: 12) {
            icon
                .font(.system(size: 24))
                .foregroundStyle(style.iconColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(style.iconBackground)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 2) {
                Text(fileName)
                    .font(style.nameFont)
                    .foregroundStyle(style.nameColor)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text(fileSize)
                    .font(style.sizeFont)
                    .foregroundStyle(style.sizeColor)
            }

            if isDownloading {
                ProgressView()
                    .tint(style.progressTint)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }
}

#Preview("File Bubble") {
    FileBubbleLabel(fileName: "dummy.pdf", fileSize: "13 KB", isDownloading: true)
        .padding()
        .background(Color.black)
}

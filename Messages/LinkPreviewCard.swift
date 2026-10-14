import SwiftUI
#if canImport(UIKit)
import UIKit
public typealias LinkPreviewImage = UIImage
#else
import AppKit
public typealias LinkPreviewImage = NSImage
#endif

public enum LinkPreviewPlatformDefaults {
    public static var background: Color {
#if canImport(UIKit)
        Color(uiColor: .secondarySystemBackground)
#else
        Color(nsColor: .windowBackgroundColor)
#endif
    }

    public static var border: Color {
#if canImport(UIKit)
        Color(uiColor: .separator)
#else
        Color(nsColor: .separatorColor)
#endif
    }

    public static var domain: Color {
#if canImport(UIKit)
        Color(uiColor: .tertiaryLabel)
#else
        Color(nsColor: .tertiaryLabelColor)
#endif
    }
}

public struct LinkPreviewCardStyle: Sendable {
    public let cardWidth: CGFloat
    public let cornerRadius: CGFloat
    public let background: Color
    public let borderColor: Color
    public let titleFont: Font
    public let titleColor: Color
    public let descriptionFont: Font
    public let descriptionColor: Color
    public let domainFont: Font
    public let domainColor: Color

    public init(
        cardWidth: CGFloat = 280,
        cornerRadius: CGFloat = 16,
        background: Color = LinkPreviewPlatformDefaults.background,
        borderColor: Color = LinkPreviewPlatformDefaults.border,
        titleFont: Font = .system(size: 15, weight: .bold),
        titleColor: Color = .primary,
        descriptionFont: Font = .system(size: 13),
        descriptionColor: Color = .secondary,
        domainFont: Font = .system(size: 12),
        domainColor: Color = LinkPreviewPlatformDefaults.domain
    ) {
        self.cardWidth = cardWidth
        self.cornerRadius = cornerRadius
        self.background = background
        self.borderColor = borderColor
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.descriptionFont = descriptionFont
        self.descriptionColor = descriptionColor
        self.domainFont = domainFont
        self.domainColor = domainColor
    }

    public static let `default` = LinkPreviewCardStyle()
}

public struct LinkPreviewCard: View {
    let title: String?
    let description: String?
    let domain: String
    let image: LinkPreviewImage?
    let style: LinkPreviewCardStyle
    let onTap: () -> Void

    public init(
        title: String?,
        description: String?,
        domain: String,
        image: LinkPreviewImage?,
        style: LinkPreviewCardStyle = .default,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.domain = domain
        self.image = image
        self.style = style
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                if let image {
#if canImport(UIKit)
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: style.cardWidth, height: style.cardWidth * 9 / 16)
                        .clipped()
#else
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: style.cardWidth, height: style.cardWidth * 9 / 16)
                        .clipped()
#endif
                }

                VStack(alignment: .leading, spacing: 4) {
                    if let title {
                        Text(title)
                            .font(style.titleFont)
                            .foregroundColor(style.titleColor)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let description {
                        Text(description)
                            .font(style.descriptionFont)
                            .foregroundColor(style.descriptionColor)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.system(size: 10))
                            Text(domain)
                                .lineLimit(1)
                        }
                        .font(style.domainFont)
                        .foregroundColor(style.domainColor)

                        Spacer()

                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10))
                            .foregroundColor(style.domainColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                }
                .padding(12)
            }
            .frame(width: style.cardWidth)
            .geometryGroup()
            .background(style.background)
            .cornerRadius(style.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(style.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

public struct LinkPreviewPlaceholder: View {
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    public init(width: CGFloat = 280, height: CGFloat = 180, cornerRadius: CGFloat = 16) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
    }
}

#Preview("Card") {
    LinkPreviewCard(
        title: "Sample Article Title That Could Be Long",
        description: "This is a sample description for testing compact layout",
        domain: "example.com",
        image: nil,
        onTap: {}
    )
    .padding()
}

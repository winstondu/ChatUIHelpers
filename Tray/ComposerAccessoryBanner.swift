import SwiftUI

public struct ComposerAccessoryBanner<Thumbnail: View>: View {
    private let title: String
    private let subtitle: String
    private let closeIcon: Image
    private let style: ComposerAccessoryBannerStyle
    private let onDismiss: () -> Void
    private let thumbnail: Thumbnail

    public init(
        title: String,
        subtitle: String,
        closeIcon: Image = Image(systemName: "xmark"),
        style: ComposerAccessoryBannerStyle = ComposerAccessoryBannerStyle(),
        onDismiss: @escaping () -> Void,
        @ViewBuilder thumbnail: () -> Thumbnail
    ) {
        self.title = title
        self.subtitle = subtitle
        self.closeIcon = closeIcon
        self.style = style
        self.onDismiss = onDismiss
        self.thumbnail = thumbnail()
    }

    public var body: some View {
        content
            .modifier(VerticalFixedSizeModifier(isEnabled: style.fixesVerticalSize))
            .padding(style.padding)
    }

    private var content: some View {
        HStack(spacing: style.contentSpacing) {
            thumbnail

            VStack(alignment: .leading, spacing: style.textSpacing) {
                Text(title)
                    .font(style.titleFont)
                    .foregroundStyle(style.titleColor)
                Text(subtitle)
                    .font(style.subtitleFont)
                    .foregroundStyle(style.subtitleColor)
                    .lineLimit(style.subtitleLineLimit)
            }

            if let minLength = style.spacerMinLength {
                Spacer(minLength: minLength)
            } else {
                Spacer()
            }

            Button(action: onDismiss) {
                closeImage
                    .frame(width: style.closeIconSize, height: style.closeIconSize)
                    .foregroundStyle(style.closeIconColor)
                    .frame(width: style.closeButtonSize, height: style.closeButtonSize)
                    .background(style.closeButtonBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var closeImage: some View {
        if style.closeIconFitsAspect {
            closeIcon.resizable().aspectRatio(contentMode: .fit)
        } else {
            closeIcon.resizable()
        }
    }
}

extension ComposerAccessoryBanner where Thumbnail == EmptyView {
    public init(
        title: String,
        subtitle: String,
        closeIcon: Image = Image(systemName: "xmark"),
        style: ComposerAccessoryBannerStyle = ComposerAccessoryBannerStyle(),
        onDismiss: @escaping () -> Void
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            closeIcon: closeIcon,
            style: style,
            onDismiss: onDismiss,
            thumbnail: { EmptyView() }
        )
    }
}

private struct VerticalFixedSizeModifier: ViewModifier {
    let isEnabled: Bool

    func body(content: Content) -> some View {
        if isEnabled {
            content.fixedSize(horizontal: false, vertical: true)
        } else {
            content
        }
    }
}

#Preview {
    ComposerAccessoryBanner(
        title: "Reply",
        subtitle: "Message preview",
        onDismiss: {},
        thumbnail: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray)
                .frame(width: 36, height: 48)
        }
    )
}

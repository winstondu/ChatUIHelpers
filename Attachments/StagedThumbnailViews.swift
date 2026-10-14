//
//  StagedThumbnailViews.swift
//  Winston
//
//  Created on 1/2/26.
//

import SwiftUI

public struct StagedThumbnailStyle {
    public var size: CGFloat
    public var cornerRadius: CGFloat
    public var borderColor: Color
    public var progressTrackColor: Color
    public var progressColor: Color
    public var retryBackgroundColor: Color
    public var retryForegroundColor: Color
    public var fileFillColor: Color
    public var fileIconColor: Color
    public var fileTextColor: Color

    public init(
        size: CGFloat = 60,
        cornerRadius: CGFloat = 8,
        borderColor: Color = Color.white.opacity(0.15),
        progressTrackColor: Color = Color.white.opacity(0.3),
        progressColor: Color = .white,
        retryBackgroundColor: Color = Color.red.opacity(0.9),
        retryForegroundColor: Color = .white,
        fileFillColor: Color = Color.white.opacity(0.15),
        fileIconColor: Color = Color.white.opacity(0.6),
        fileTextColor: Color = .white
    ) {
        self.size = size
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.progressTrackColor = progressTrackColor
        self.progressColor = progressColor
        self.retryBackgroundColor = retryBackgroundColor
        self.retryForegroundColor = retryForegroundColor
        self.fileFillColor = fileFillColor
        self.fileIconColor = fileIconColor
        self.fileTextColor = fileTextColor
    }
}

public struct StagedImageThumbnailView<Attachment: UploadableAttachment>: View {
    let image: UIImage
    let attachment: Attachment
    let style: StagedThumbnailStyle

    public init(image: UIImage, attachment: Attachment, style: StagedThumbnailStyle = StagedThumbnailStyle()) {
        self.image = image
        self.attachment = attachment
        self.style = style
    }

    public var body: some View {
        ZStack {
            ThumbnailBaseImage(image: image, attachment: attachment, style: style)
            UploadProgressOverlay(attachment: attachment, style: style)
            RetryOverlay(attachment: attachment, style: style)
        }
    }
}

struct ThumbnailBaseImage<Attachment: UploadableAttachment>: View {
    let image: UIImage
    let attachment: Attachment
    let style: StagedThumbnailStyle

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: style.size, height: style.size)
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(style.borderColor, lineWidth: 1)
            )
            .opacity(attachment.isUploading ? 0.5 : 1.0)
    }
}

struct UploadProgressOverlay<Attachment: UploadableAttachment>: View {
    let attachment: Attachment
    let style: StagedThumbnailStyle

    var body: some View {
        if attachment.isUploading {
            ZStack {
                Circle()
                    .stroke(style.progressTrackColor, lineWidth: 3)
                    .frame(width: 30, height: 30)

                Circle()
                    .trim(from: 0, to: attachment.uploadProgress)
                    .stroke(style.progressColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 30, height: 30)
                    .animation(.linear(duration: 0.1), value: attachment.uploadProgress)
            }
        }
    }
}

struct RetryOverlay<Attachment: UploadableAttachment>: View {
    let attachment: Attachment
    let style: StagedThumbnailStyle

    var body: some View {
        if attachment.isFailed {
            Button(action: { attachment.retry() }) {
                ZStack {
                    Circle()
                        .fill(style.retryBackgroundColor)
                        .frame(width: 30, height: 30)

                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(style.retryForegroundColor)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

public struct StagedFileThumbnailView<Attachment: UploadableAttachment>: View {
    let fileExtension: String
    let attachment: Attachment
    let style: StagedThumbnailStyle

    public init(fileExtension: String, attachment: Attachment, style: StagedThumbnailStyle = StagedThumbnailStyle()) {
        self.fileExtension = fileExtension
        self.attachment = attachment
        self.style = style
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .fill(style.fileFillColor)
                .frame(width: style.size, height: style.size)
                .overlay(
                    RoundedRectangle(cornerRadius: style.cornerRadius)
                        .stroke(style.borderColor, lineWidth: 1)
                )

            VStack(spacing: 2) {
                Image(systemName: "doc")
                    .font(.system(size: 16))
                    .foregroundColor(style.fileIconColor)

                Text(fileExtension)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(style.fileTextColor)
                    .lineLimit(1)
            }
            .opacity(attachment.isUploading ? 0.5 : 1.0)

            UploadProgressOverlay(attachment: attachment, style: style)
            RetryOverlay(attachment: attachment, style: style)
        }
    }
}

public struct StagedMediaThumbnailView<ImageContent: View>: View {
    let showsPlayIcon: Bool
    let style: StagedThumbnailStyle
    let imageContent: ImageContent

    public init(
        showsPlayIcon: Bool,
        style: StagedThumbnailStyle = StagedThumbnailStyle(),
        @ViewBuilder imageContent: () -> ImageContent
    ) {
        self.showsPlayIcon = showsPlayIcon
        self.style = style
        self.imageContent = imageContent()
    }

    public var body: some View {
        ZStack {
            imageContent

            if showsPlayIcon {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(radius: 2)
            }
        }
        .frame(width: style.size, height: style.size)
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(style.borderColor, lineWidth: 1)
        )
    }
}

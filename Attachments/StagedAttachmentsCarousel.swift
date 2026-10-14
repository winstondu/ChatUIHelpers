//
//  StagedAttachmentsCarousel.swift
//  Winston
//
//  Created on 1/2/26.
//

import SwiftUI

// MARK: - StagedAttachmentsCarousel

/// Horizontal carousel displaying staged attachments with delete capability.
/// Mirrors the SuggestionsCarousel pattern but for attachments.
public struct StagedAttachmentsCarousel: View {
    let attachments: [any StagedAttachment]
    let onRemove: (any StagedAttachment) -> Void

    public init(attachments: [any StagedAttachment], onRemove: @escaping (any StagedAttachment) -> Void) {
        self.attachments = attachments
        self.onRemove = onRemove
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(attachments, id: \.id) { attachment in
                    AnyView(attachment.makeThumbnailView())
                        .deletable(
                            when: true,
                            trigger: .always,
                            onDelete: { onRemove(attachment) }
                        )
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
        }
        .scrollClipDisabled()
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: attachments.map(\.id))
    }
}

// MARK: - Preview

#Preview("Staged Attachments Carousel") {
    StagedAttachmentsCarouselPreview()
}

private struct MockStagedAttachment: StagedAttachment {
    let id = UUID()
    let systemName: String
    var isUploading: Bool { false }

    @MainActor
    func makeThumbnailView() -> some View {
        Image(systemName: systemName)
            .frame(width: 60, height: 60)
            .background(Color.gray.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct StagedAttachmentsCarouselPreview: View {
    @State private var attachments: [MockStagedAttachment] = [
        MockStagedAttachment(systemName: "photo"),
        MockStagedAttachment(systemName: "photo.fill"),
        MockStagedAttachment(systemName: "camera")
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Spacer()

                StagedAttachmentsCarousel(
                    attachments: attachments,
                    onRemove: { attachment in
                        withAnimation {
                            attachments.removeAll { $0.id == attachment.id }
                        }
                    }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
    }
}

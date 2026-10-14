//
//  SuggestionsCarousel.swift
//  Winston
//
//  Created on 12/10/25.
//

import SwiftUI

public struct SuggestionPillStyle: Sendable {
    public var font: Font
    public var foreground: Color
    public var background: Color

    public init(
        font: Font = .system(size: 12),
        foreground: Color = .secondary,
        background: Color = Color.gray.opacity(0.25)
    ) {
        self.font = font
        self.foreground = foreground
        self.background = background
    }
}

public struct SuggestionsCarousel: View {
    let items: [ChatContextMenuItem]
    var style: SuggestionPillStyle = SuggestionPillStyle()

    public init(items: [ChatContextMenuItem], style: SuggestionPillStyle = SuggestionPillStyle()) {
        self.items = items
        self.style = style
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items) { item in
                    SuggestionPill(icon: item.icon, title: item.title, style: style, action: item.action)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: items)
        }
        .scrollClipDisabled()
    }
}

public struct SuggestionPill: View {
    let icon: Image
    let title: String
    var style: SuggestionPillStyle = SuggestionPillStyle()
    let action: () -> Void

    public init(icon: Image, title: String, style: SuggestionPillStyle = SuggestionPillStyle(), action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)

                Text(title)
                    .font(style.font)
                    .lineLimit(1)
            }
            .foregroundStyle(style.foreground)
            .padding(.leading, 12)
            .padding(.trailing, 16)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(style.background)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

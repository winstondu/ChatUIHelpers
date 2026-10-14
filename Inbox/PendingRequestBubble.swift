//
//  PendingRequestBubble.swift
//  Winston
//
//  Pill-shaped bubble showing "Pending request" status.
//  Displayed in ChatDetailView when the OTHER user has a pending invite.
//

import SwiftUI
import WinstonUIFoundation

/// Pill-shaped bubble showing "Pending request" status
public struct PendingRequestBubble: View {
    let title: String
    let font: Font
    let titleColor: Color
    let indicatorColor: Color

    public init(
        title: String,
        font: Font = .system(size: 15),
        titleColor: Color = .white,
        indicatorColor: Color = .red
    ) {
        self.title = title
        self.font = font
        self.titleColor = titleColor
        self.indicatorColor = indicatorColor
    }

    public var body: some View {
        HStack {
            Spacer(minLength: 0)
            HStack(spacing: 8) {
                // Red dot indicator
                Circle()
                    .fill(indicatorColor)
                    .frame(width: 5, height: 5)

                // "Pending request" text
                Text(title)
                    .font(font)
                    .foregroundColor(titleColor)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .padding(.leading, 8)
        .padding(.trailing, 12)
        .frame(height: 56)
        .applyGlassEffectForButton(shape: Capsule())
    }
}

#Preview {
    ZStack {
        Color.black
        PendingRequestBubble(title: "Pending request")
    }
}

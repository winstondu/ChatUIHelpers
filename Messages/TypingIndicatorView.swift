//
//  TypingIndicatorView.swift
//  Winston
//
//  Created on 12/22/25.
//

import SwiftUI
import WinstonUIFoundation

public struct TypingIndicatorView: View {
    public enum Style {
        case bounce
        case pulse
    }

    let style: Style
    let dotColor: Color

    public init(style: Style = .pulse, dotColor: Color = .primary) {
        self.style = style
        self.dotColor = dotColor
    }

    public var body: some View {
        switch style {
        case .bounce:
            bounceIndicator
        case .pulse:
            pulseIndicator
        }
    }

    private var bounceIndicator: some View {
        TimelineView(.animation(minimumInterval: 0.2)) { timeline in
            let phase = Int(timeline.date.timeIntervalSince1970 / 0.2) % 3
            HStack(alignment: .center, spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color(hex: 0xBDBDBD))
                        .frame(width: 8, height: 8)
                        .offset(y: phase == index ? -4 : 0)
                        .animation(.easeInOut(duration: 0.15), value: phase)
                }
            }
        }
        .fixedSize()
    }

    private var pulseIndicator: some View {
        TimelineView(.animation(minimumInterval: 0.4)) { timeline in
            let phase = Int(timeline.date.timeIntervalSince1970 / 0.4) % 3
            HStack(alignment: .center, spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(dotColor.opacity(index == phase ? 0.25 : 0.10))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: phase)
                }
            }
        }
        .fixedSize()
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Pulse").foregroundColor(.white).font(.caption)
                TypingIndicatorView(style: .pulse, dotColor: .black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 18,
                            bottomLeadingRadius: 2,
                            bottomTrailingRadius: 18,
                            topTrailingRadius: 18
                        )
                    )
            }
            VStack(spacing: 8) {
                Text("Bounce").foregroundColor(.white).font(.caption)
                TypingIndicatorView(style: .bounce)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 18,
                            bottomLeadingRadius: 2,
                            bottomTrailingRadius: 18,
                            topTrailingRadius: 18
                        )
                    )
            }
        }
    }
}

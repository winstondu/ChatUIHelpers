//
//  ToggleRealtimeButton.swift
//  Winston
//
//  Created on 12/8/25.
//

import SwiftUI
import WinstonUIFoundation

public struct ToggleRealtimeButtonStyle: Sendable {
    public var font: Font
    public var expandedForeground: Color
    public var collapsedForeground: Color
    public var connectingTextColor: Color
    public var expandedBackground: Color
    public var collapsedBackground: Color
    public var borderColor: Color
    public var listeningTitle: String
    public var connectingTitle: String

    public init(
        font: Font = .system(size: 15, weight: .medium),
        expandedForeground: Color = .primary,
        collapsedForeground: Color = .secondary,
        connectingTextColor: Color = .secondary,
        expandedBackground: Color = Color(.systemBackground),
        collapsedBackground: Color = Color(.secondarySystemBackground),
        borderColor: Color = Color(.separator),
        listeningTitle: String = "",
        connectingTitle: String = ""
    ) {
        self.font = font
        self.expandedForeground = expandedForeground
        self.collapsedForeground = collapsedForeground
        self.connectingTextColor = connectingTextColor
        self.expandedBackground = expandedBackground
        self.collapsedBackground = collapsedBackground
        self.borderColor = borderColor
        self.listeningTitle = listeningTitle
        self.connectingTitle = connectingTitle
    }
}

public struct ToggleRealtimeButton: View {
    let icon: Image
    let isExpanded: Bool
    let isOn: Bool
    let style: ToggleRealtimeButtonStyle
    @State private var isLoading: Bool = false

    let onTap: () async -> Void

    public init(
        icon: Image,
        isExpanded: Bool,
        isOn: Bool,
        style: ToggleRealtimeButtonStyle = ToggleRealtimeButtonStyle(),
        onTap: @escaping () async -> Void
    ) {
        self.icon = icon
        self.isExpanded = isExpanded
        self.isOn = isOn
        self.style = style
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: handleTap) {
            HStack(spacing: 8) {
                if isExpanded {
                    Spacer(minLength: 0)
                }

                icon
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: isExpanded ? 24 : 20, height: isExpanded ? 24 : 20)
                    .opacity(isLoading ? 0 : 1)
                    .overlay {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: isExpanded ? style.expandedForeground : style.collapsedForeground))
                        }
                    }

                if isExpanded {
                    Text(isOn ? style.listeningTitle : style.connectingTitle)
                        .font(style.font)
                        .foregroundStyle(isOn ? style.expandedForeground : style.connectingTextColor)

                    Spacer(minLength: 0)
                }
            }
            .foregroundStyle(isExpanded ? style.expandedForeground : style.collapsedForeground)
            .padding(isExpanded ? 8 : 14)
            .frame(maxWidth: isExpanded ? .infinity : nil)
            .frame(width: isExpanded ? nil : 48, height: 48)
            .contentShape(Rectangle())
            .background(isExpanded ? style.expandedBackground : style.collapsedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 999, style: .continuous))
            .overlay {
                if isExpanded {
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .stroke(style.borderColor, lineWidth: 2)
                }
            }
        }
        .disabled(isLoading)
        .buttonStyle(BounceButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExpanded)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
    }

    private func handleTap() {
        guard !isLoading else { return }

        Task {
            isLoading = true
            await onTap()
            isLoading = false
        }
    }
}

#Preview("Toggle Realtime Button") {
    ToggleRealtimeButtonPreview()
}

private struct ToggleRealtimeButtonPreview: View {
    @State private var isMessageMode = true

    var body: some View {
        VStack(spacing: 24) {
            Text("isMessageMode: \(isMessageMode ? "true" : "false")")
                .font(.caption)
                .foregroundStyle(.secondary)

            ToggleRealtimeButton(
                icon: Image(systemName: "waveform"),
                isExpanded: !isMessageMode,
                isOn: !isMessageMode,
                style: ToggleRealtimeButtonStyle(listeningTitle: "Listening", connectingTitle: "Connecting..."),
                onTap: {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    isMessageMode.toggle()
                }
            )

            Button("Toggle State") {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isMessageMode.toggle()
                }
            }
        }
        .padding()
    }
}

//
//  ChatActionButton.swift
//  Winston
//
//  Created on 12/8/25.
//

import SwiftUI
import WinstonUIFoundation

public struct ChatActionButton: View {
    let icon: Image
    let action: () async -> Void
    let rotation: Angle

    @State private var isLoading: Bool = false

    public init(icon: Image, action: @escaping () async -> Void, rotation: Angle = .zero) {
        self.icon = icon
        self.action = action
        self.rotation = rotation
    }

    public var body: some View {
        Button(action: handleTap) {
            icon
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .rotationEffect(rotation)
                .foregroundStyle(.white.opacity(0.7))
                .opacity(isLoading ? 0 : 1)
                .overlay {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.7)))
                    }
                }
        }
        .frame(width: 48, height: 48)
        .contentShape(Circle())
        .background(Color.white.opacity(0.15))
        .clipShape(Circle())
        .disabled(isLoading)
        .buttonStyle(BounceButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
    }

    private func handleTap() {
        guard !isLoading else { return }

        Task {
            isLoading = true
            await action()
            isLoading = false
        }
    }
}

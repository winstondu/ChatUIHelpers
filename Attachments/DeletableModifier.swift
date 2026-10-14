//
//  DeletableModifier.swift
//  Winston
//
//  Created on 1/2/26.
//

import SwiftUI

// MARK: - DeletableModifier

/// ViewModifier that adds a delete icon (revealed by long-press or always shown) to a view.
public struct DeletableModifier: ViewModifier {
    public enum DeletionTrigger: Equatable {
        case always
        case longPress(autoHideAfter: TimeInterval)

        public static func == (lhs: DeletionTrigger, rhs: DeletionTrigger) -> Bool {
            switch (lhs, rhs) {
            case (.always, .always):
                return true
            case (.longPress(let lhsDuration), .longPress(let rhsDuration)):
                return lhsDuration == rhsDuration
            default:
                return false
            }
        }
    }

    let isDeletable: Bool  // Whether the delete button should EVER be shown.
    let trigger: DeletionTrigger
    let onDelete: () -> Void

    @State private var showDeleteButton = false
    @State private var deleteButtonTimer: Timer?

    public init(isDeletable: Bool, trigger: DeletionTrigger, onDelete: @escaping () -> Void) {
        self.isDeletable = isDeletable
        self.trigger = trigger
        self.onDelete = onDelete
        self._showDeleteButton = State(
            initialValue: isDeletable && (trigger == DeletionTrigger.always))
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .overlay(
                // Delete button overlay (prevents clipping)
                showDeleteButton ? deleteButton : nil,
                alignment: .topTrailing
            )
            .onLongPressGesture {
                handleLongPress()
            }
            .onChange(of: isDeletable) { _, newValue in
                if !newValue {
                    cancelDeleteButtonTimer()
                    showDeleteButton = false
                }

                if newValue, case .always = trigger {
                    showDeleteButton = true
                }
            }
            .animation(.easeInOut(duration: 0.2), value: showDeleteButton)
    }

    // MARK: - Private Views

    @ViewBuilder
    private var deleteButton: some View {
        Button(action: handleDelete) {
            ZStack(alignment: .center) {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 20, height: 20)

                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    // .blendMode(.destinationOut)
            }
            .compositingGroup()
        }
        .offset(x: 8, y: -8)
        .allowsHitTesting(true)
    }

    // MARK: - Private Methods

    private func handleLongPress() {
        guard case .longPress = trigger else { return }
        guard isDeletable else { return }

        showDeleteButton = true
        startDeleteButtonTimer()
    }

    private func handleDelete() {
        showDeleteButton = false
        cancelDeleteButtonTimer()
        onDelete()
    }

    private func startDeleteButtonTimer() {
        guard case .longPress(let autoHideAfter) = trigger else { return }
        cancelDeleteButtonTimer()  // Cancel any existing timer

        deleteButtonTimer = Timer.scheduledTimer(withTimeInterval: autoHideAfter, repeats: false) {
            _ in
            Task { @MainActor in
                showDeleteButton = false
            }
        }
    }

    private func cancelDeleteButtonTimer() {
        deleteButtonTimer?.invalidate()
        deleteButtonTimer = nil
    }
}

// MARK: - View Extension

extension View {
    public func deletable(
        when isDeletable: Bool,
        trigger: DeletableModifier.DeletionTrigger = .longPress(autoHideAfter: 5.0),
        onDelete: @escaping () -> Void
    ) -> some View {
        modifier(
            DeletableModifier(
                isDeletable: isDeletable,
                trigger: trigger,
                onDelete: onDelete
            ))
    }
}

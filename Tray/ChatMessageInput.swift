//
//  ChatMessageInput.swift
//  Winston
//
//  Created on 12/8/25.
//

import SwiftUI
import WinstonUIFoundation

public struct ChatMessageInput<LeadingButton: View, TrailingButton: View>: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    var onSend: () -> Void
    var hasOtherSendableContent: Bool = false  // e.g., staged attachments
    var isSendDisabled: Bool = false  // Disable send button (e.g., while uploads in progress)
    var forceShowLeadingButton: Bool = false  // Always show leading button (e.g., image request mode)
    var placeholder: String = ""
    var font: Font = .system(size: 15)
    var sendIconColor: Color = .black
    @ViewBuilder var leadingButton: () -> LeadingButton
    @ViewBuilder var trailingButton: () -> TrailingButton

    public init(
        text: Binding<String>,
        isFocused: FocusState<Bool>.Binding,
        onSend: @escaping () -> Void,
        hasOtherSendableContent: Bool = false,
        isSendDisabled: Bool = false,
        forceShowLeadingButton: Bool = false,
        placeholder: String = "",
        font: Font = .system(size: 15),
        sendIconColor: Color = .black,
        @ViewBuilder leadingButton: @escaping () -> LeadingButton,
        @ViewBuilder trailingButton: @escaping () -> TrailingButton
    ) {
        self._text = text
        self._isFocused = isFocused
        self.onSend = onSend
        self.hasOtherSendableContent = hasOtherSendableContent
        self.isSendDisabled = isSendDisabled
        self.forceShowLeadingButton = forceShowLeadingButton
        self.placeholder = placeholder
        self.font = font
        self.sendIconColor = sendIconColor
        self.leadingButton = leadingButton
        self.trailingButton = trailingButton
    }

    private var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Whether to show send button (has text or other content to send)
    private var canSend: Bool {
        hasText || hasOtherSendableContent
    }

    /// Whether to show the leading button (always show when we have attachments or forced, hide when typing text only)
    private var showLeadingButton: Bool {
        !hasText || hasOtherSendableContent || forceShowLeadingButton
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Leading button (shown when attachments present OR no text entered)
            if showLeadingButton {
                leadingButton()
                    .id("LeadingButton")
            }

            // Text field
            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(.white.opacity(0.4)))
                .font(font)
                .foregroundStyle(.white)
                .padding(.leading, showLeadingButton ? 0 : 8)
                .focused($isFocused)
                .onSubmit {
                    if canSend {
                        onSend()
                    }
                }

            Spacer(minLength: 0)

            // Trailing button (shown when nothing to send yet)
            if !canSend {
                trailingButton()
                    .id("TrailingButton")
            }

            // Send button (shown when there's content to send)
            if canSend {
                Button(action: onSend) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(sendIconColor)
                }
                .frame(width: 32, height: 32)
                .background(Color.white)
                .clipShape(Circle())
                .contentShape(Circle().scale(1.5))
                .buttonStyle(BounceButtonStyle())
                .disabled(isSendDisabled)
                .opacity(isSendDisabled ? 0.5 : 1.0)
            }
        }
        .padding(.leading, showLeadingButton ? 4 : 12)
        .padding(.trailing, canSend ? 8 : 12)
        .padding(.vertical, 8)
        .frame(height: 48)
        .background(Color.white.opacity(0.15))
        .clipShape(Capsule())
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: canSend)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: showLeadingButton)
    }
}

public extension ChatMessageInput where TrailingButton == EmptyView {
    init(
        text: Binding<String>,
        isFocused: FocusState<Bool>.Binding,
        onSend: @escaping () -> Void,
        hasOtherSendableContent: Bool = false,
        isSendDisabled: Bool = false,
        forceShowLeadingButton: Bool = false,
        placeholder: String = "",
        font: Font = .system(size: 15),
        sendIconColor: Color = .black,
        @ViewBuilder leadingButton: @escaping () -> LeadingButton
    ) {
        self._text = text
        self._isFocused = isFocused
        self.onSend = onSend
        self.hasOtherSendableContent = hasOtherSendableContent
        self.isSendDisabled = isSendDisabled
        self.forceShowLeadingButton = forceShowLeadingButton
        self.placeholder = placeholder
        self.font = font
        self.sendIconColor = sendIconColor
        self.leadingButton = leadingButton
        self.trailingButton = { EmptyView() }
    }
}

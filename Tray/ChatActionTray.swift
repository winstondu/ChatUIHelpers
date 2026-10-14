//
//  ChatActionTray.swift
//  Winston
//
//  Created on 12/8/25.
//

import SwiftUI
import Observation
import WinstonUIFoundation

public enum ChatTrayCallState: Sendable, Equatable {
    case idle
    case voiceCall
    case videoCall
}

public struct ChatActionTrayStyle: Sendable {
    public var plusIcon: Image
    public var imageRequestIcon: Image
    public var micIcon: Image
    public var closeIcon: Image
    public var textIcon: Image
    public var voiceIcon: Image
    public var videoIcon: Image
    public var closeButtonBackground: Color
    public var inputPlaceholder: String
    public var inputFont: Font
    public var sendIconColor: Color
    public var holdToTalk: HoldToTalkStyle
    public var suggestionPill: SuggestionPillStyle
    public var contextMenu: ChatContextMenuStyle
    public var toggleRealtime: ToggleRealtimeButtonStyle

    public init(
        plusIcon: Image = Image(systemName: "plus"),
        imageRequestIcon: Image = Image(systemName: "camera.badge.plus"),
        micIcon: Image = Image(systemName: "mic"),
        closeIcon: Image = Image(systemName: "xmark"),
        textIcon: Image = Image(systemName: "text.bubble"),
        voiceIcon: Image = Image(systemName: "waveform"),
        videoIcon: Image = Image(systemName: "video.fill"),
        closeButtonBackground: Color = Color(.secondarySystemBackground),
        inputPlaceholder: String = "",
        inputFont: Font = .system(size: 15),
        sendIconColor: Color = .black,
        holdToTalk: HoldToTalkStyle = HoldToTalkStyle(),
        suggestionPill: SuggestionPillStyle = SuggestionPillStyle(),
        contextMenu: ChatContextMenuStyle = ChatContextMenuStyle(),
        toggleRealtime: ToggleRealtimeButtonStyle = ToggleRealtimeButtonStyle()
    ) {
        self.plusIcon = plusIcon
        self.imageRequestIcon = imageRequestIcon
        self.micIcon = micIcon
        self.closeIcon = closeIcon
        self.textIcon = textIcon
        self.voiceIcon = voiceIcon
        self.videoIcon = videoIcon
        self.closeButtonBackground = closeButtonBackground
        self.inputPlaceholder = inputPlaceholder
        self.inputFont = inputFont
        self.sendIconColor = sendIconColor
        self.holdToTalk = holdToTalk
        self.suggestionPill = suggestionPill
        self.contextMenu = contextMenu
        self.toggleRealtime = toggleRealtime
    }
}

// MARK: - ChatActionTray

public struct ChatActionTray<StagedContent: View, Recording: VoiceRecording>: View {
    @Binding var messageText: String
    @Binding var isImageRequestOn: Bool
    @FocusState.Binding var isInputFocused: Bool
    @State private var isComposingText: Bool = true
    @State private var contextMenuPresentation = ContextMenuPresentation()

    public enum TrayMode {
        case message
        case voiceRecording
        case videoConnecting
    }
    @State private var trayMode: TrayMode = .message

    let callState: ChatTrayCallState

    let connectingCallState: ChatTrayCallState?

    let isVoiceCallEnabled: Bool

    let style: ChatActionTrayStyle

    let onEnd: () async -> Bool
    let onVideo: () async -> Bool
    let onVoice: () async -> Bool
    let onMute: () async -> Void
    let onSend: () -> Void

    let isMuted: Bool

    let voiceRecording: Recording
    var currentUserAvatarURL: URL?
    var onSendVoiceMessage: (() async -> Void)?

    var menuItems: [ChatContextMenuItem] = []

    var suggestionItems: [ChatContextMenuItem] = []

    var hasStagedContent: Bool = false

    var isSendDisabled: Bool = false

    var isVoiceButtonDisabled: Bool = false

    var isVideoButtonDisabled: Bool = false

    @ViewBuilder var stagedContent: () -> StagedContent

    private let contextMenuId = "chatActionTrayContextMenu"

    public init(
        messageText: Binding<String>,
        isImageRequestOn: Binding<Bool>,
        isInputFocused: FocusState<Bool>.Binding,
        callState: ChatTrayCallState,
        connectingCallState: ChatTrayCallState?,
        isVoiceCallEnabled: Bool,
        style: ChatActionTrayStyle = ChatActionTrayStyle(),
        onEnd: @escaping () async -> Bool,
        onVideo: @escaping () async -> Bool,
        onVoice: @escaping () async -> Bool,
        onMute: @escaping () async -> Void,
        onSend: @escaping () -> Void,
        isMuted: Bool,
        voiceRecording: Recording,
        currentUserAvatarURL: URL? = nil,
        onSendVoiceMessage: (() async -> Void)? = nil,
        menuItems: [ChatContextMenuItem] = [],
        suggestionItems: [ChatContextMenuItem] = [],
        hasStagedContent: Bool = false,
        isSendDisabled: Bool = false,
        isVoiceButtonDisabled: Bool = false,
        isVideoButtonDisabled: Bool = false,
        @ViewBuilder stagedContent: @escaping () -> StagedContent
    ) {
        self._messageText = messageText
        self._isImageRequestOn = isImageRequestOn
        self._isInputFocused = isInputFocused
        self.callState = callState
        self.connectingCallState = connectingCallState
        self.isVoiceCallEnabled = isVoiceCallEnabled
        self.style = style
        self.onEnd = onEnd
        self.onVideo = onVideo
        self.onVoice = onVoice
        self.onMute = onMute
        self.onSend = onSend
        self.isMuted = isMuted
        self.voiceRecording = voiceRecording
        self.currentUserAvatarURL = currentUserAvatarURL
        self.onSendVoiceMessage = onSendVoiceMessage
        self.menuItems = menuItems
        self.suggestionItems = suggestionItems
        self.hasStagedContent = hasStagedContent
        self.isSendDisabled = isSendDisabled
        self.isVoiceButtonDisabled = isVoiceButtonDisabled
        self.isVideoButtonDisabled = isVideoButtonDisabled
        self.stagedContent = stagedContent
    }

    private var hasText: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private enum ExpandedButton {
        case none, voice, video
    }

    private enum AboveTrayContent: Equatable {
        case stagedContent
        case suggestions
        case none
    }

    private var expandedButton: ExpandedButton {
        if let connecting = connectingCallState {
            switch connecting {
                case .videoCall: return .video
                case .voiceCall: return .voice
                case .idle: break
            }
        }

        guard !isComposingText else { return .none }
        switch callState {
            case .idle:
                return .none
            case .videoCall:
                return .video
            case .voiceCall:
                return .voice
        }
    }

    private var isConnecting: Bool {
        connectingCallState != nil
    }

    private var aboveTrayContent: AboveTrayContent {
        guard trayMode == .message && isComposingText else {
            return .none
        }

        if hasStagedContent {
            return .stagedContent
        }

        if !suggestionItems.isEmpty && !hasText {
            return .suggestions
        }

        return .none
    }


    public var body: some View {
        VStack(spacing: 12) {
            aboveTrayContentView

            HStack(spacing: 12) {
                switch trayMode {
                case .message:
                    messageModeTray

                case .voiceRecording:
                    voiceRecordingModeTray

                case .videoConnecting:
                    videoConnectingModeTray
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: voiceRecording.isRecording)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: voiceRecording.showPreview)
        }
        .contextMenuHost(presentation: contextMenuPresentation, style: style.contextMenu)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isComposingText)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hasText)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: suggestionItems)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: trayMode)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: connectingCallState)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: aboveTrayContent)
        .onChange(of: connectingCallState) { _, newValue in
            if newValue == .videoCall {
                trayMode = .videoConnecting
            } else if trayMode == .videoConnecting {
                trayMode = .message
            }
        }
    }

    // MARK: - Above Tray Content

    @ViewBuilder
    private var aboveTrayContentView: some View {
        switch aboveTrayContent {
        case .stagedContent:
            stagedContent()
                .transition(.move(edge: .bottom).combined(with: .opacity))
        case .suggestions:
            SuggestionsCarousel(items: suggestionItems, style: style.suggestionPill)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        case .none:
            EmptyView()
        }
    }

    // MARK: - Message Mode Tray

    @ViewBuilder
    private var messageModeTray: some View {
        if isComposingText {
            // Composing Text: Input + (optionally) collapsed end + video
            ChatMessageInput(
                text: $messageText,
                isFocused: $isInputFocused,
                onSend: onSend,
                hasOtherSendableContent: hasStagedContent,
                isSendDisabled: isSendDisabled,
                forceShowLeadingButton: isImageRequestOn,
                placeholder: style.inputPlaceholder,
                font: style.inputFont,
                sendIconColor: style.sendIconColor
            ) {
                ContextMenuPlusButton(
                    presentation: contextMenuPresentation,
                    menuId: contextMenuId,
                    alternateIcon: isImageRequestOn ? style.imageRequestIcon : nil,
                    plusIcon: style.plusIcon
                )
                .contextMenuAnchor(
                    id: contextMenuId,
                    presentation: contextMenuPresentation,
                    items: menuItems
                )
                .id("ChatContextMenuPlusButton")
            } trailingButton: {
                if callState == .idle && !isConnecting {
                    Button {
                        trayMode = .voiceRecording
                    } label: {
                        style.micIcon
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
        } else {
            ContextMenuPlusButton(
                presentation: contextMenuPresentation,
                menuId: contextMenuId,
                size: 48,
                alternateIcon: isImageRequestOn ? style.imageRequestIcon : nil,
                backgroundColor: Color.white.opacity(0.15),
                plusIcon: style.plusIcon
            )
            .contextMenuAnchor(
                id: contextMenuId,
                presentation: contextMenuPresentation,
                items: menuItems
            )
            .id("ChatContextMenuPlusButton")

            ChatActionButton(icon: style.textIcon) {
                isComposingText = true
            }
        }

        if !hasText && !hasStagedContent && (isVoiceCallEnabled || callState == .voiceCall || connectingCallState == .voiceCall) {
            ToggleRealtimeButton(
                icon: style.voiceIcon,
                isExpanded: expandedButton == .voice,
                isOn: callState == .voiceCall,
                style: style.toggleRealtime,
                onTap: {
                    if callState == .voiceCall || connectingCallState == .voiceCall {
                        if await onEnd() {
                            isComposingText = true
                        }
                    } else {
                        if await onVoice() {
                            isComposingText = false
                        }
                    }
                }
            )
            .id("voiceToggle")
            .disabled(isVoiceButtonDisabled)
            .opacity(isVoiceButtonDisabled ? 0.5 : 1.0)

            if callState == .voiceCall {
                ChatActionButton(
                    icon: Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill"),
                    action: onMute
                )
                .id("muteButton")
            }
        }
    }

    // MARK: - Voice Recording Mode Tray

    @ViewBuilder
    private var voiceRecordingModeTray: some View {
        // Plus button (leading) - hidden during preview/recording
        if !voiceRecording.showPreview && !voiceRecording.isRecording {
            ContextMenuPlusButton(
                presentation: contextMenuPresentation,
                menuId: contextMenuId,
                size: 48,
                alternateIcon: isImageRequestOn ? style.imageRequestIcon : nil,
                backgroundColor: Color.white.opacity(0.15),
                plusIcon: style.plusIcon
            )
            .contextMenuAnchor(
                id: contextMenuId,
                presentation: contextMenuPresentation,
                items: menuItems
            )
            .id("ChatContextMenuPlusButton")
            .transition(.move(edge: .leading).combined(with: .opacity))
        }

        HoldToTalkButton(
            voiceRecording: voiceRecording,
            avatarURL: currentUserAvatarURL,
            style: style.holdToTalk,
            onSend: {
                await onSendVoiceMessage?()
            }
        )

        if !voiceRecording.showPreview && !voiceRecording.isRecording {
            Button {
                voiceRecording.cancelRecording()
                trayMode = .message
            } label: {
                style.closeIcon
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 48, height: 48)
                    .contentShape(Circle())
                    .background(style.closeButtonBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(BounceButtonStyle())
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
    }


    @ViewBuilder
    private var videoConnectingModeTray: some View {
        HStack {
            Spacer()
            ToggleRealtimeButton(
                icon: style.videoIcon,
                isExpanded: true,
                isOn: false,
                style: style.toggleRealtime,
                onTap: {
                    _ = await onEnd()
                }
            )
            .id("videoButton")
            Spacer()
        }
    }
}

#Preview("Chat Action Tray") {
    ChatActionTrayPreview()
}

@MainActor
@Observable
private final class PreviewVoiceRecording: VoiceRecording {
    var isRecording = false
    var showPreview = false
    var audioLevels: [Float] = []
    var fileURL: URL?
    var displayDuration = "0:00"

    func startRecording() {
        isRecording = true
    }

    func stopRecording() {
        isRecording = false
        showPreview = true
    }

    func cancelRecording() {
        isRecording = false
        showPreview = false
    }

    func audioLevelStream() -> AsyncStream<CGFloat> {
        AsyncStream { $0.finish() }
    }
}

private struct ChatActionTrayPreview: View {
    @State private var messageText = ""
    @State private var isImageRequestOn = false
    @FocusState private var isInputFocused: Bool
    @State private var voiceRecording = PreviewVoiceRecording()

    private var sampleMenuItems: [ChatContextMenuItem] {
        [
            ChatContextMenuItem(icon: Image(systemName: "photo"), title: "Send Photo", action: {}),
            ChatContextMenuItem(icon: Image(systemName: "camera"), title: "Take Photo", action: {}),
            ChatContextMenuItem(icon: Image(systemName: "face.smiling"), title: "Send Reaction", action: {})
        ]
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack {
                Spacer()

                ChatActionTray(
                    messageText: $messageText,
                    isImageRequestOn: $isImageRequestOn,
                    isInputFocused: $isInputFocused,
                    callState: .idle,
                    connectingCallState: nil,
                    isVoiceCallEnabled: true,
                    style: ChatActionTrayStyle(
                        inputPlaceholder: "Message",
                        toggleRealtime: ToggleRealtimeButtonStyle(listeningTitle: "Listening", connectingTitle: "Connecting...")
                    ),
                    onEnd: { true },
                    onVideo: { true },
                    onVoice: { true },
                    onMute: {},
                    onSend: { messageText = "" },
                    isMuted: false,
                    voiceRecording: voiceRecording,
                    menuItems: sampleMenuItems,
                    suggestionItems: sampleMenuItems,
                    stagedContent: { EmptyView() }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
    }
}

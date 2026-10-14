//
//  HoldToTalkButton.swift
//  Winston
//
//  Created on 12/22/25.
//

import SwiftUI
import AVFoundation
import Observation

public struct HoldToTalkButton<Recording: VoiceRecording>: View {
    let voiceRecording: Recording
    let avatarURL: URL?
    let style: HoldToTalkStyle
    let onSend: () async -> Void

    @State private var isHolding: Bool = false
    @State private var isPlaying: Bool = false
    @State private var player: AVPlayer?
    @State private var playbackProgress: Double = 0
    @State private var timeObserver: Any?

    // Show recording UI when holding OR when there's a valid recording to preview
    public init(
        voiceRecording: Recording,
        avatarURL: URL?,
        style: HoldToTalkStyle = HoldToTalkStyle(),
        onSend: @escaping () async -> Void
    ) {
        self.voiceRecording = voiceRecording
        self.avatarURL = avatarURL
        self.style = style
        self.onSend = onSend
    }

    private var showRecordingUI: Bool {
        isHolding || voiceRecording.showPreview || voiceRecording.isRecording
    }

    public var body: some View {
        // Single button container that morphs its content
        HStack(spacing: showRecordingUI ? 12 : 8) {
            if showRecordingUI {
                // Recording/Preview content INSIDE the button
                recordingContent
            } else {
                // "Hold to talk" content
                holdToTalkContent
            }
        }
        .padding(.horizontal, 12)
        .foregroundStyle(style.foreground)
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .background(style.background)
        .clipShape(Capsule())
        .contentShape(Rectangle())
        .scaleEffect(isHolding && !showRecordingUI ? 0.95 : 1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    // Only respond to gestures when in idle state
                    if !isHolding && !showRecordingUI {
                        isHolding = true
                        voiceRecording.startRecording()
                    }
                }
                .onEnded { _ in
                    if isHolding {
                        isHolding = false
                        voiceRecording.stopRecording()
                    }
                }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showRecordingUI)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isHolding)
        .onChange(of: voiceRecording.showPreview) { _, showPreview in
            if !showPreview {
                stopPlayback()
            }
        }
    }

    @ViewBuilder
    private var holdToTalkContent: some View {
        Spacer(minLength: 0)
        Image(systemName: "mic.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
        Text(style.title)
            .font(style.titleFont)
        Spacer(minLength: 0)
    }

    @ViewBuilder
    private var recordingContent: some View {
        // Trash button (leading) - returns to "Hold to talk"
        Button {
            stopPlayback()
            voiceRecording.cancelRecording()
        } label: {
            style.trashIcon
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundStyle(style.foreground)
        }
        .frame(width: 40, height: 40)
        .buttonStyle(BounceButtonStyle())

        // Center content: Live waveform during recording, static waveform in preview
        if voiceRecording.isRecording {
            // Live waveform during recording
            ScrollingWaveformView(
                audioLevels: voiceRecording.audioLevelStream(),
                barWidth: 2,
                barSpacing: 2,
                maxBarHeight: 20
            )
            .frame(maxWidth: .infinity)

            Text(voiceRecording.displayDuration)
                .font(style.recordingDurationFont)
                .foregroundStyle(style.foreground)
        } else {
            // Play/Pause button
            Button(action: togglePlayback) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(style.foreground)
            }
            .frame(width: 24, height: 24)

            // Seekable waveform with progress indicator
            SeekableWaveformView(
                audioLevels: voiceRecording.audioLevels,
                progress: playbackProgress,
                onSeek: { newProgress in
                    seek(to: newProgress)
                }
            )
            .frame(maxWidth: .infinity)

            Text(voiceRecording.displayDuration)
                .font(style.previewDurationFont)
                .foregroundStyle(style.foreground)
        }

        // Trailing: Avatar during recording, Send button in preview
        if voiceRecording.isRecording {
            // User avatar (indicator only, not interactive)
            AsyncImage(url: avatarURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.3))
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
        } else {
            // Send button (after release) - same style as message mode
            Button {
                Task {
                    stopPlayback()
                    await onSend()
                }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(style.sendButtonForeground)
            }
            .frame(width: 32, height: 32)
            .background(style.sendButtonBackground)
            .clipShape(Circle())
            .buttonStyle(BounceButtonStyle())
        }
    }

    private func togglePlayback() {
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
    }

    private func startPlayback() {
        guard let audioURL = voiceRecording.fileURL else { return }

        if player == nil {
            player = AVPlayer(url: audioURL)
            setupTimeObserver()
        }

        player?.play()
        isPlaying = true

        // Listen for playback end
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            Task { @MainActor in
                isPlaying = false
                playbackProgress = 0
                player?.seek(to: .zero)
            }
        }
    }

    private func pausePlayback() {
        player?.pause()
        isPlaying = false
    }

    private func stopPlayback() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player?.pause()
        player?.seek(to: .zero)
        player = nil
        isPlaying = false
        playbackProgress = 0
    }

    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [self] time in
            guard let duration = player?.currentItem?.duration,
                  duration.seconds.isFinite && duration.seconds > 0 else { return }
            Task { @MainActor in
                playbackProgress = time.seconds / duration.seconds
            }
        }
    }

    private func seek(to progress: Double) {
        guard let duration = player?.currentItem?.duration,
              duration.seconds.isFinite && duration.seconds > 0 else {
            // If player not initialized, create it first
            if let audioURL = voiceRecording.fileURL {
                player = AVPlayer(url: audioURL)
                setupTimeObserver()
                // Seek after a small delay to let the player initialize
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    if let newDuration = player?.currentItem?.duration,
                       newDuration.seconds.isFinite {
                        let targetTime = CMTime(seconds: progress * newDuration.seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                        await player?.seek(to: targetTime)
                        playbackProgress = progress
                    }
                }
            }
            return
        }

        let targetTime = CMTime(seconds: progress * duration.seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: targetTime)
        playbackProgress = progress
    }
}

#Preview("Hold to Talk Button") {
    HoldToTalkButtonPreview()
}

@MainActor
@Observable
private final class MockVoiceRecording: VoiceRecording {
    var isRecording = false
    var showPreview = false
    var audioLevels: [Float] = (0..<40).map { _ in Float.random(in: 0.1...1) }
    var fileURL: URL?
    var displayDuration = "0:03"

    func startRecording() {
        isRecording = true
        showPreview = false
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
        AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    continuation.yield(CGFloat.random(in: 0.1...1))
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

private struct HoldToTalkButtonPreview: View {
    @State private var voiceRecording = MockVoiceRecording()

    var body: some View {
        HoldToTalkButton(
            voiceRecording: voiceRecording,
            avatarURL: nil,
            onSend: {
                voiceRecording.cancelRecording()
            }
        )
        .padding(.horizontal, 16)
    }
}

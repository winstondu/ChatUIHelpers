import SwiftUI
import AVFoundation
#if !canImport(UIKit)
import AVKit
#endif

public struct ChatVideoPlayerView: View {
    let url: URL
    let playIcon: Image
    let cornerRadius: CGFloat
    let onWillPlay: () -> Void

    @State private var player: AVPlayer?
    @State private var isPlaying = true
    @State private var showControls = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var isSeeking = false
    @State private var timeObserver: Any?
    @State private var hideControlsTask: Task<Void, Never>?

    public init(
        url: URL,
        playIcon: Image = Image(systemName: "play.fill"),
        cornerRadius: CGFloat = 44,
        onWillPlay: @escaping () -> Void = {}
    ) {
        self.url = url
        self.playIcon = playIcon
        self.cornerRadius = cornerRadius
        self.onWillPlay = onWillPlay
    }

    public var body: some View {
#if canImport(UIKit)
        ZStack {
            VideoPlayerLayer(player: player)

            if showControls {
                controlsOverlay
                    .transition(.opacity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
        .onTapGesture { handleTap() }
        .onAppear { setupPlayer() }
        .onDisappear { cleanupPlayer() }
#else
        VideoPlayer(player: player)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .padding(.horizontal, 12)
            .onAppear { setupPlayer() }
            .onDisappear { cleanupPlayer() }
#endif
    }

    private var controlsOverlay: some View {
        VStack {
            Spacer()

            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .overlay(alignment: .bottom) {
                controlsBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
    }

    private var controlsBar: some View {
        HStack(spacing: 12) {
            Button {
                handleTap()
            } label: {
                Group {
                    if isPlaying {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 16))
                    } else {
                        playIcon
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                }
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
            }

            scrubBar

            Text(formatTime(duration - currentTime))
                .font(.system(size: 12, weight: .medium).monospacedDigit())
                .foregroundStyle(.white.opacity(0.7))
                .fixedSize()
        }
    }

    private var scrubBar: some View {
        GeometryReader { geometry in
            let progress = duration > 0 ? currentTime / duration : 0
            let trackHeight: CGFloat = isSeeking ? 6 : 4

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.3))
                    .frame(height: trackHeight)

                Capsule()
                    .fill(.white)
                    .frame(width: max(0, geometry.size.width * progress), height: trackHeight)
            }
            .animation(.easeInOut(duration: 0.15), value: isSeeking)
            .frame(height: 14)
            .frame(maxHeight: .infinity, alignment: .center)
            .contentShape(Rectangle().inset(by: -12))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isSeeking = true
                        cancelHideControls()
                        let proportion = max(0, min(1, value.location.x / geometry.size.width))
                        currentTime = proportion * duration
                        let cmTime = CMTime(seconds: currentTime, preferredTimescale: 600)
                        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
                    }
                    .onEnded { _ in
                        isSeeking = false
                        if isPlaying {
                            scheduleHideControls()
                        }
                    }
            )
        }
        .frame(height: 28)
    }

    private func handleTap() {
        if isPlaying {
            player?.pause()
            isPlaying = false
            withAnimation(.easeInOut(duration: 0.2)) {
                showControls = true
            }
            cancelHideControls()
        } else {
            player?.play()
            isPlaying = true
            scheduleHideControls()
        }
    }

    private func scheduleHideControls() {
        cancelHideControls()
        hideControlsTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                showControls = false
            }
        }
    }

    private func cancelHideControls() {
        hideControlsTask?.cancel()
        hideControlsTask = nil
    }

    private func setupPlayer() {
        onWillPlay()
        let playerItem = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: playerItem)
        self.player = avPlayer

        let interval = CMTime(value: 1, timescale: 30)
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            DispatchQueue.main.async {
                guard !isSeeking else { return }
                currentTime = time.seconds
                if let dur = avPlayer.currentItem?.duration.seconds, dur.isFinite {
                    duration = dur
                }
            }
        }

        avPlayer.play()

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            avPlayer.seek(to: .zero)
            avPlayer.play()
        }
    }

    private func cleanupPlayer() {
        cancelHideControls()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player?.pause()
        player = nil
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let total = Int(seconds)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

#if canImport(UIKit)
private struct VideoPlayerLayer: UIViewRepresentable {
    let player: AVPlayer?

    func makeUIView(context: Context) -> VideoPlayerUIView {
        VideoPlayerUIView()
    }

    func updateUIView(_ uiView: VideoPlayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }
}

private final class VideoPlayerUIView: UIView {
    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.videoGravity = .resizeAspect
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        playerLayer.videoGravity = .resizeAspect
    }
}
#endif

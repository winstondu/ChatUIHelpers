//
//  ScrollingWaveformView.swift
//  Winston
//
//  Created on 12/8/25.
//

import SwiftUI

/// A scrolling waveform visualization that displays audio levels as animated bars.
/// New bars appear in the middle and existing bars shift left. Trailing half remains at zero.
/// A horizontal gradient fades out the leading and trailing edges.
public struct ScrollingWaveformView<S: AsyncSequence>: View where S.Element == CGFloat {
    let audioLevels: S
    let barColor: Color
    let barWidth: CGFloat
    let barSpacing: CGFloat
    let minBarHeight: CGFloat
    let maxBarHeight: CGFloat

    /// The active portion (left half) of the waveform where audio levels are displayed
    @State private var levels: [CGFloat] = []
    @State private var task: Task<Void, Never>?

    public init(
        audioLevels: S,
        barColor: Color = .black.opacity(0.8),
        barWidth: CGFloat = 2,
        barSpacing: CGFloat = 2,
        minBarHeight: CGFloat = 4,
        maxBarHeight: CGFloat = 24
    ) {
        self.audioLevels = audioLevels
        self.barColor = barColor
        self.barWidth = barWidth
        self.barSpacing = barSpacing
        self.minBarHeight = minBarHeight
        self.maxBarHeight = maxBarHeight
    }

    public var body: some View {
        GeometryReader { geometry in
            let totalBarCount = Int(geometry.size.width / (barWidth + barSpacing))
            // Active bars are in the left half; trailing half is zeros
            let activeBarCount = totalBarCount / 2

            HStack(spacing: barSpacing) {
                ForEach(0..<totalBarCount, id: \.self) { index in
                    // Double-sided bar: extends both up and down from center
                    Capsule()
                        .fill(barColor.opacity(0.6))
                        .frame(
                            width: barWidth,
                            height: barHeight(for: index, activeBarCount: activeBarCount)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .onChange(of: activeBarCount) { _, newCount in
                adjustLevelsBuffer(to: newCount)
            }
            .onAppear {
                adjustLevelsBuffer(to: activeBarCount)
                startListening()
            }
            .onDisappear {
                task?.cancel()
                task = nil
            }
        }
        .frame(height: maxBarHeight)
    }

    private func barHeight(for index: Int, activeBarCount: Int) -> CGFloat {
        // Trailing half (indices >= activeBarCount) use a slightly lower height
        guard index < activeBarCount, index < levels.count else {
            return minBarHeight * 0.6
        }
        let level = levels[index]
        let height = minBarHeight + (maxBarHeight - minBarHeight) * level
        return Swift.max(minBarHeight, Swift.min(maxBarHeight, height))
    }

    private func adjustLevelsBuffer(to count: Int) {
        if levels.count < count {
            // Pad with zeros at the beginning
            levels = Array(repeating: 0, count: count - levels.count) + levels
        } else if levels.count > count {
            // Trim from the beginning
            levels = Array(levels.suffix(count))
        }
    }

    private func startListening() {
        task = Task { @MainActor in
            do {
                for try await level in audioLevels {
                    if Task.isCancelled { break }

                    // Shift left and add new value at the end of active portion
                    // This makes new bars "appear" at the middle of the view
                    withAnimation(.linear(duration: 0.1)) {
                        if !levels.isEmpty {
                            levels.removeFirst()
                        }
                        levels.append(level)
                    }
                }
            } catch {
                // Stream ended or was cancelled
            }
        }
    }
}

private struct WaveformBarColorKey: EnvironmentKey {
    static let defaultValue: Color = .white
}

extension EnvironmentValues {
    public var waveformBarColor: Color {
        get { self[WaveformBarColorKey.self] }
        set { self[WaveformBarColorKey.self] = newValue }
    }
}

public extension View {
    func waveformBarColor(_ color: Color) -> some View {
        environment(\.waveformBarColor, color)
    }
}

// MARK: - Mock Audio Stream for Testing

/// A mock async sequence that generates random audio levels for testing
public struct MockAudioLevelStream: AsyncSequence {
    public typealias Element = CGFloat

    let interval: TimeInterval

    public init(interval: TimeInterval = 0.1) {
        self.interval = interval
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(interval: interval)
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        let interval: TimeInterval
        private var lastValue: CGFloat = 0.5

        init(interval: TimeInterval) {
            self.interval = interval
        }

        public mutating func next() async -> CGFloat? {
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))

            if Task.isCancelled { return nil }

            // Generate smooth random values with some continuity
            let delta = CGFloat.random(in: -0.3...0.3)
            lastValue = Swift.max(0.0, Swift.min(1.0, lastValue + delta))
            return lastValue
        }
    }
}

// MARK: - Preview

#Preview("Scrolling Waveform") {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 20) {
            Text("Scrolling Waveform Demo")
                .foregroundStyle(.white)

            ScrollingWaveformView(
                audioLevels: MockAudioLevelStream(interval: 0.1)
            )
            .frame(height: 24)
            .padding(.horizontal, 16)
        }
    }
}

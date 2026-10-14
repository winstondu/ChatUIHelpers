//
//  SeekableWaveformView.swift
//  Winston
//
//  Created on 12/23/25.
//

import SwiftUI
import AVFoundation

public struct SeekableWaveformView: View {
    let audioLevels: [Float]
    let progress: Double // 0.0 to 1.0
    let onSeek: (Double) -> Void

    let barColor: Color
    let playedColor: Color
    let seekBarColor: Color
    let barWidth: CGFloat
    let barSpacing: CGFloat
    let minBarHeight: CGFloat
    let maxBarHeight: CGFloat
    let seekBarWidth: CGFloat
    let seekBarTouchRadius: CGFloat

    @State private var isDragging: Bool = false

    public init(
        audioLevels: [Float],
        progress: Double,
        onSeek: @escaping (Double) -> Void,
        barColor: Color = .black.opacity(0.3),
        playedColor: Color = .black.opacity(0.9),
        seekBarColor: Color = .black.opacity(0.9),
        barWidth: CGFloat = 2,
        barSpacing: CGFloat = 2,
        minBarHeight: CGFloat = 4,
        maxBarHeight: CGFloat = 20,
        seekBarWidth: CGFloat = 2,
        seekBarTouchRadius: CGFloat = 20
    ) {
        self.audioLevels = audioLevels
        self.progress = progress
        self.onSeek = onSeek
        self.barColor = barColor
        self.playedColor = playedColor
        self.seekBarColor = seekBarColor
        self.barWidth = barWidth
        self.barSpacing = barSpacing
        self.minBarHeight = minBarHeight
        self.maxBarHeight = maxBarHeight
        self.seekBarWidth = seekBarWidth
        self.seekBarTouchRadius = seekBarTouchRadius
    }

    public var body: some View {
        GeometryReader { geometry in
            let totalBarCount = Int(geometry.size.width / (barWidth + barSpacing))
            let sampledLevels = sampleLevels(to: totalBarCount)
            let seekPosition = progress * geometry.size.width
            let waveformHeight = maxBarHeight

            ZStack(alignment: .leading) {
                // Waveform bars
                HStack(spacing: barSpacing) {
                    ForEach(0..<totalBarCount, id: \.self) { index in
                        let barPosition = CGFloat(index) * (barWidth + barSpacing) + barWidth / 2
                        let isPlayed = barPosition <= seekPosition

                        Capsule()
                            .fill(isPlayed ? playedColor : barColor)
                            .frame(
                                width: barWidth,
                                height: barHeight(for: index, levels: sampledLevels)
                            )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: waveformHeight, alignment: .center)

                // Seek bar (thin vertical line)
                Rectangle()
                    .fill(seekBarColor)
                    .frame(width: seekBarWidth, height: waveformHeight)
                    .frame(maxHeight: waveformHeight, alignment: .center)
                    .offset(x: seekPosition - seekBarWidth / 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let newProgress = max(0, min(1, value.location.x / geometry.size.width))
                        onSeek(newProgress)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
        }
        .frame(height: maxBarHeight)
    }

    private func sampleLevels(to count: Int) -> [Float] {
        guard !audioLevels.isEmpty, count > 0 else {
            return Array(repeating: 0, count: count)
        }

        var result: [Float] = []
        let step = Float(audioLevels.count) / Float(count)

        for i in 0..<count {
            let index = Int(Float(i) * step)
            if index < audioLevels.count {
                result.append(audioLevels[index])
            } else {
                result.append(0)
            }
        }

        return result
    }

    private func barHeight(for index: Int, levels: [Float]) -> CGFloat {
        guard index < levels.count else { return minBarHeight }
        let level = CGFloat(levels[index])
        let height = minBarHeight + (maxBarHeight - minBarHeight) * level
        return max(minBarHeight, min(maxBarHeight, height))
    }
}

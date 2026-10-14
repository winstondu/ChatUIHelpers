//
//  VideoThumbnailOverlay.swift
//  Winston
//
//
import SwiftUI

public struct VideoThumbnailOverlay: View {
    let duration: Double?
    let playIcon: Image

    public init(duration: Double?, playIcon: Image = Image(systemName: "play.fill")) {
        self.duration = duration
        self.playIcon = playIcon
    }

    private var formattedDuration: String? {
        guard let duration, duration > 0 else { return nil }
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    public var body: some View {
        ZStack {
            playIcon
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(.ultraThinMaterial)
                .clipShape(Circle())

            if let formattedDuration {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(formattedDuration)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.black.opacity(0.6))
                            .cornerRadius(4)
                    }
                }
                .padding(8)
            }
        }
    }
}

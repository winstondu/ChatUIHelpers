import Foundation
import Observation

@MainActor
public protocol VoiceRecording: AnyObject, Observable {
    var isRecording: Bool { get }
    var showPreview: Bool { get }
    var audioLevels: [Float] { get }
    var fileURL: URL? { get }
    var displayDuration: String { get }

    func startRecording()
    func stopRecording()
    func cancelRecording()
    func audioLevelStream() -> AsyncStream<CGFloat>
}

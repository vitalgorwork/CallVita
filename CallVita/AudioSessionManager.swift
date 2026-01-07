import AVFoundation

final class AudioSessionManager {

    static let shared = AudioSessionManager()
    private let session = AVAudioSession.sharedInstance()

    private init() {}

    // 📞 Ringing (playback only)
    func activateForRinging() {
        do {
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try session.setActive(true)
        } catch {
            print("❌ AudioSession ringing error:", error)
        }
    }

    // 🔊 Connected (voice call)
    func activateForCall() {
        do {
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.defaultToSpeaker, .allowBluetooth]
            )
            try session.setActive(true)
        } catch {
            print("❌ AudioSession call error:", error)
        }
    }

    // ❌ Ended
    func deactivate() {
        do {
            try session.setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            print("❌ AudioSession deactivate error:", error)
        }
    }
}

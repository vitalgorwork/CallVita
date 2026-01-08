import AVFoundation

final class AudioSessionManager {

    static let shared = AudioSessionManager()
    private let session = AVAudioSession.sharedInstance()

    private init() {}

    // 🔔 Incoming Ring (media-style, loud, foreground)
    func activateForRinging() {
        do {
            try session.setCategory(
                .playback,
                mode: .default,
                options: []
            )
            try session.setActive(true, options: [])
            print("🔔 AudioSession ACTIVE for RINGING")
        } catch {
            print("❌ AudioSession ringing error:", error.localizedDescription)
        }
    }

    // 📞 Connected Call (voice)
    func activateForCall() {
        do {
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.defaultToSpeaker, .allowBluetooth]
            )
            try session.setActive(true, options: [])
            print("📞 AudioSession ACTIVE for CALL")
        } catch {
            print("❌ AudioSession call error:", error.localizedDescription)
        }
    }

    // ❌ End Call
    func deactivate() {
        do {
            try session.setActive(false, options: [.notifyOthersOnDeactivation])
            print("🔕 AudioSession DEACTIVATED")
        } catch {
            print("❌ AudioSession deactivate error:", error.localizedDescription)
        }
    }
}

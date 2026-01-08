import Foundation
import AVFoundation

final class SoundManager {

    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?

    private init() {}

    // MARK: - Incoming Ringtone (INFINITE)

    func playRingtone() {
        stopRingtone() // защита от двойного старта

        guard let url = Bundle.main.url(forResource: "ring", withExtension: "caf") else {
            print("❌ ring.caf not found in bundle")
            return
        }

        do {
            // ⚠️ ВАЖНО: для рингтона нужен ambient + mix
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1   // ♾ бесконечно
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

            print("🔔 Ringtone STARTED (ring.caf, infinite)")

        } catch {
            print("❌ Ringtone error:", error.localizedDescription)
        }
    }

    func stopRingtone() {
        guard let audioPlayer else { return }

        audioPlayer.stop()
        self.audioPlayer = nil

        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("⚠️ AudioSession deactivate error:", error.localizedDescription)
        }

        print("🔕 Ringtone STOPPED")
    }
}

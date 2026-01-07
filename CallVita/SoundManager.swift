import Foundation
import AVFoundation

final class SoundManager {

    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?

    private init() {}

    // MARK: - Ringtone

    func playRingtone() {
        guard let url = Bundle.main.url(forResource: "ring", withExtension: "mp3") else {
            print("❌ ring.mp3 not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("❌ AudioPlayer error:", error)
        }
    }

    func stopRingtone() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

import AVFoundation

final class SoundManager {

    static let shared = SoundManager()
    private var player: AVAudioPlayer?

    private init() {}

    func playRingtone() {
        guard player == nil else { return } // ❗ не плодим плееры

        guard let url = Bundle.main.url(forResource: "ring", withExtension: "mp3") else {
            print("❌ ring.mp3 not found")
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // бесконечно
            player?.play()
        } catch {
            print("❌ Audio error:", error)
        }
    }

    func stopRingtone() {
        player?.stop()
        player = nil
    }
}

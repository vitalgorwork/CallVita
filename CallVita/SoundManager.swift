import AVFoundation

final class SoundManager {

    static let shared = SoundManager()
    private var player: AVAudioPlayer?

    private init() {}

    func playRingtone() {
        guard let url = Bundle.main.url(forResource: "ring", withExtension: "mp3") else {
            print("❌ ring.mp3 not found")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // бесконечный звонок
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("❌ Failed to play ringtone:", error)
        }
    }

    func stopRingtone() {
        player?.stop()
        player = nil
    }
}

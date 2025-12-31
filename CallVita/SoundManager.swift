import Foundation
import AVFoundation
import AudioToolbox

final class SoundManager {

    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?
    private var vibrationTimer: Timer?

    // MARK: - Ringtone

    func playRingtone() {
        startVibrationLoop()

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.ambient, options: [.mixWithOthers])
            try session.setActive(true)

            guard let url = Bundle.main.url(forResource: "ring", withExtension: "mp3") else {
                print("❌ ring.mp3 not found")
                return
            }

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("❌ Audio error:", error)
        }
    }

    func stopRingtone() {
        audioPlayer?.stop()
        audioPlayer = nil
        stopVibration()
    }

    // MARK: - Vibration

    private func startVibrationLoop() {
        stopVibration()
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }

    private func stopVibration() {
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
}

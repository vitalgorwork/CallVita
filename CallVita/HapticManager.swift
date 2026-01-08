import UIKit
import AudioToolbox

final class HapticManager {

    static let shared = HapticManager()
    private init() {}

    private var ringTimer: Timer?

    // MARK: - Incoming Ring Vibration (INFINITE)

    func startRinging() {
        stopRinging()

        ringTimer = Timer.scheduledTimer(withTimeInterval: 1.4, repeats: true) { _ in
            // Системная вибрация (как у звонка)
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

            // Дополнительный тактильный отклик
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.warning)
        }

        RunLoop.main.add(ringTimer!, forMode: .common)
        print("📳 Haptic ringing STARTED")
    }

    func stopRinging() {
        ringTimer?.invalidate()
        ringTimer = nil
        print("📳 Haptic ringing STOPPED")
    }

    // MARK: - Actions

    func answerFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    func endCallFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
}

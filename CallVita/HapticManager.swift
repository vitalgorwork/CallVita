import UIKit

final class HapticManager {

    static let shared = HapticManager()

    private init() {}

    // MARK: - Ringing (repeating soft vibration)

    private var ringTimer: Timer?

    func startRinging() {
        stopRinging()

        ringTimer = Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true) { _ in
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }
    }

    func stopRinging() {
        ringTimer?.invalidate()
        ringTimer = nil
    }

    // MARK: - Actions

    func answerFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    func endCallFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
}

import Foundation
import CallKit
import AVFoundation

final class CallKitManager: NSObject {

    // MARK: - Singleton
    static let shared = CallKitManager()

    // MARK: - Properties
    private let provider: CXProvider
    private let callController = CXCallController()
    private var currentCallUUID: UUID?

    // MARK: - Init
    private override init() {
        print("🚨 CallKitManager.init START")

        let config = CXProviderConfiguration(localizedName: "CallVita")
        config.supportsVideo = false
        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.generic]

        // Кастомный рингтон можно включить позже, но это НЕ влияет на DEV incoming
        config.iconTemplateImageData = nil
        // config.ringtoneSound = "ring.caf"

        self.provider = CXProvider(configuration: config)
        super.init()

        // Лучше на main, чтобы CallKit/UI точно не чудили
        provider.setDelegate(self, queue: DispatchQueue.main)

        print("🚨 CallKitManager.init END — provider delegate set")
    }

    // MARK: - Incoming Call (CallKit)
    func reportIncomingCall(
        uuid: UUID = UUID(),
        handle: String,
        completion: ((Error?) -> Void)? = nil
    ) {
        print("🚨 reportIncomingCall ENTERED")
        print("🚨 UUID:", uuid)
        print("🚨 Handle:", handle)

        currentCallUUID = uuid

        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: handle)
        update.hasVideo = false

        print("🚨 Calling provider.reportNewIncomingCall (completion-based)")

        // ✅ ВАЖНО: используем completion-версию (НЕ async/await), чтобы не было ошибки как на скриншоте
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error {
                print("❌ reportNewIncomingCall ERROR:", error.localizedDescription)
            } else {
                print("✅ reportNewIncomingCall SUCCESS (no error)")
            }
            completion?(error)
        }
    }

    // MARK: - End Call
    func endCall() {
        print("🚨 endCall called")

        guard let uuid = currentCallUUID else {
            print("⚠️ endCall ignored — no active UUID")
            return
        }

        let action = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: action)

        callController.request(transaction) { error in
            if let error {
                print("❌ End call error:", error.localizedDescription)
            } else {
                print("✅ End call transaction sent")
            }
        }

        currentCallUUID = nil
    }
}

// MARK: - CXProviderDelegate
extension CallKitManager: CXProviderDelegate {

    func providerDidReset(_ provider: CXProvider) {
        print("⚠️ providerDidReset")
        currentCallUUID = nil
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("📞 CXAnswerCallAction received")
        configureAudioSession()
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("📴 CXEndCallAction received")
        action.fulfill()
        currentCallUUID = nil
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("🔊 Audio session activated")
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("🔇 Audio session deactivated")
    }

    // MARK: - Audio
    private func configureAudioSession() {
        print("🎧 configureAudioSession called")

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.allowBluetooth, .defaultToSpeaker]
            )
            try session.setActive(true)
            print("🎧 Audio session ACTIVE")
        } catch {
            print("❌ Audio session error:", error.localizedDescription)
        }
    }
}

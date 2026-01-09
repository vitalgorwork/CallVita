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
        config.iconTemplateImageData = nil

        self.provider = CXProvider(configuration: config)
        super.init()

        provider.setDelegate(self, queue: DispatchQueue.main)

        print("🚨 CallKitManager.init END — provider delegate set")
    }

    // MARK: - Incoming Call (CallKit)
    func reportIncomingCall(
        uuid: UUID = UUID(),
        handle: String,
        completion: ((Error?) -> Void)? = nil
    ) {
        print("🚨 reportIncomingCall ENTERED:", handle)

        currentCallUUID = uuid

        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: handle)
        update.hasVideo = false

        DispatchQueue.main.async {
            CallSession.shared.incomingCall(from: handle)
        }

        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error {
                print("❌ reportNewIncomingCall ERROR:", error.localizedDescription)
            } else {
                print("✅ reportNewIncomingCall SUCCESS")
            }
            completion?(error)
        }
    }

    // MARK: - Outgoing Call (CallKit)
    func startCall(to handle: String) {
        print("📤 startCall called:", handle)

        let uuid = UUID()
        currentCallUUID = uuid

        // UI → dialing
        DispatchQueue.main.async {
            CallSession.shared.outgoingCall(to: handle)
        }

        // 🟢 ВАЖНО: готовим VoIP-аудио до CXTransaction!
        prepareAudioForOutgoing()

        let cxHandle = CXHandle(type: .generic, value: handle)
        let action = CXStartCallAction(call: uuid, handle: cxHandle)
        let transaction = CXTransaction(action: action)

        callController.request(transaction) { error in
            if let error {
                print("❌ startCall error:", error.localizedDescription)
                DispatchQueue.main.async {
                    CallSession.shared.callEnded()
                }
            } else {
                print("📤 startCall transaction accepted")
            }
        }
    }

    // MARK: - End Call (from UI/app)
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
                print("📴 End call transaction sent")
            }
        }
    }
}

// MARK: - CXProviderDelegate
extension CallKitManager: CXProviderDelegate {

    func providerDidReset(_ provider: CXProvider) {
        print("⚠️ providerDidReset — ignored (DEV / foreground)")
        currentCallUUID = nil
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("📞 CXAnswerCallAction received")

        configureAudioSession()
        DispatchQueue.main.async {
            CallSession.shared.callAnswered()
        }

        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("📤 CXStartCallAction received — connecting audio")

        configureAudioSession()
        DispatchQueue.main.async {
            CallSession.shared.callAnswered()
        }

        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("📴 CXEndCallAction received")

        DispatchQueue.main.async {
            CallSession.shared.callEnded()
        }
        currentCallUUID = nil

        action.fulfill()
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("🔊 Audio session activated")
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("🔇 Audio session deactivated")
    }

    // MARK: - Audio
    private func configureAudioSession() {
        print("🎧 configureAudioSession (CallKit)")

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord,
                                   mode: .voiceChat,
                                   options: [.allowBluetooth, .defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("❌ Audio session error:", error.localizedDescription)
        }
    }

    // MARK: - Outgoing Audio
    private func prepareAudioForOutgoing() {
        print("🎧 prepareAudioForOutgoing")

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord,
                                   mode: .voiceChat,
                                   options: [.allowBluetooth, .defaultToSpeaker])
            try session.setActive(true)
            print("🎧 outgoing audio OK")
        } catch {
            print("❌ outgoing audio error:", error.localizedDescription)
        }
    }
}

import Foundation
import CallKit
import AVFoundation

final class CallManager: NSObject {

    static let shared = CallManager()

    private let callController = CXCallController()
    private let provider: CXProvider
    private var currentCallUUID: UUID?

    override init() {
        let configuration = CXProviderConfiguration(localizedName: "CallVita")
        configuration.supportsVideo = false
        configuration.maximumCallsPerCallGroup = 1
        configuration.supportedHandleTypes = [.generic]

        provider = CXProvider(configuration: configuration)
        super.init()
        provider.setDelegate(self, queue: nil)
    }

    // MARK: - Outgoing Call

    func startCall() {
        let uuid = UUID()
        currentCallUUID = uuid

        let handle = CXHandle(type: .generic, value: "CallVita")
        let action = CXStartCallAction(call: uuid, handle: handle)
        let transaction = CXTransaction(action: action)

        callController.request(transaction) { error in
            if let error = error {
                print("❌ Start call error:", error)
                return
            }

            self.provider.reportOutgoingCall(
                with: uuid,
                startedConnectingAt: Date()
            )
        }
    }

    // MARK: - End Call

    func endCall() {
        guard let uuid = currentCallUUID else { return }

        let action = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: action)

        callController.request(transaction) { error in
            if let error = error {
                print("❌ End call error:", error)
            }
        }

        currentCallUUID = nil
    }

    // MARK: - Incoming Call (STEP K.6 — UI-first Simulation)

    /// DEV-симуляция входящего звонка: гарантированно открывает UI (без PushKit/сервера)
    func simulateIncomingCall() {
        print("📞 simulateIncomingCall tapped")

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: CallEvents.incomingSimulated, object: nil)
        }

        // (Опционально) можем оставить попытку CallKit для логов/экспериментов — не мешает UI
        // iOS может проигнорировать UI CallKit без PushKit — это нормально.
        let uuid = UUID()
        currentCallUUID = uuid

        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: "Family")
        update.localizedCallerName = "Incoming Call"
        update.hasVideo = false

        self.provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                print("ℹ️ CallKit incoming ignored/failed (ok for dev):", error)
            } else {
                print("✅ CallKit incoming reported")
            }
        }
    }
}

// MARK: - CXProviderDelegate

extension CallManager: CXProviderDelegate {

    func providerDidReset(_ provider: CXProvider) {
        currentCallUUID = nil
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        action.fulfill()
        provider.reportOutgoingCall(with: action.callUUID, connectedAt: Date())
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
        // в K.6 UI открываем через Notification (выше), тут можно будет потом синхронизировать state
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
        currentCallUUID = nil
    }
}

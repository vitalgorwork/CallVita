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

    // MARK: - Incoming Call (SIMULATION)

    func simulateIncomingCall() {
        let uuid = UUID()
        currentCallUUID = uuid

        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: "Family")
        update.localizedCallerName = "Incoming Call"
        update.hasVideo = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.provider.reportNewIncomingCall(with: uuid, update: update) { error in
                if let error = error {
                    print("❌ Incoming call error:", error)
                } else {
                    print("✅ Incoming call reported")

                    // 🔔 УВЕДОМЛЯЕМ SwiftUI
                    NotificationCenter.default.post(
                        name: .incomingCall,
                        object: nil
                    )
                }
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
        provider.reportOutgoingCall(
            with: action.callUUID,
            connectedAt: Date()
        )
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()

        NotificationCenter.default.post(
            name: .callAnswered,
            object: nil
        )
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
        currentCallUUID = nil

        NotificationCenter.default.post(
            name: .callEnded,
            object: nil
        )
    }
}

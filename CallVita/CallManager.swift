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

    // MARK: - Start Call

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

            // Сообщаем системе, что соединение начинается
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
}

// MARK: - CXProviderDelegate

extension CallManager: CXProviderDelegate {

    func providerDidReset(_ provider: CXProvider) {
        currentCallUUID = nil
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        action.fulfill()

        // Соединение установлено (для системы)
        provider.reportOutgoingCall(
            with: action.callUUID,
            connectedAt: Date()
        )
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
        currentCallUUID = nil
    }
}

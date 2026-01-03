import Foundation
import WebRTC

final class WebRTCManager {

    static let shared = WebRTCManager()

    private let factory: RTCPeerConnectionFactory

    private init() {
        RTCInitializeSSL()
        self.factory = RTCPeerConnectionFactory()
        print("✅ WebRTC factory initialized")
    }
}

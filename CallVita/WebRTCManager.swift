import Foundation
import WebRTC
import AVFoundation

final class WebRTCManager: NSObject {

    private var factory: RTCPeerConnectionFactory!
    private var peerConnection: RTCPeerConnection?

    override init() {
        super.init()
        setupAudio()
        setupFactory()
        setupPeerConnection()
    }

    // MARK: - Audio Setup

    private func setupAudio() {
        let audioSession = RTCAudioSession.sharedInstance()
        audioSession.lockForConfiguration()
        do {
            try audioSession.setCategory(.playAndRecord)
            try audioSession.setMode(.voiceChat)
            try audioSession.setActive(true)
        } catch let error {
            print("WebRTC audio setup error: \(error.localizedDescription)")
        }
        audioSession.unlockForConfiguration()
    }

    // MARK: - Factory Setup

    private func setupFactory() {
        RTCInitializeSSL()
        self.factory = RTCPeerConnectionFactory()
    }

    // MARK: - PeerConnection Setup

    private func setupPeerConnection() {
        let config = RTCConfiguration()
        config.iceServers = [
            RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])
        ]
        config.sdpSemantics = .unifiedPlan

        let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
                                              optionalConstraints: ["DtlsSrtpKeyAgreement": "true"])

        self.peerConnection = factory.peerConnection(with: config,
                                                     constraints: constraints,
                                                     delegate: self)
    }

    deinit {
        RTCCleanupSSL()
    }
}

extension WebRTCManager: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {}
}

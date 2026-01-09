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
            // WebRTC ожидает rawValue, иначе типы не совпадают
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try audioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)

            // WebRTC требует activation здесь
            try audioSession.setActive(true)
        } catch let error {
            print("WebRTC audio setup error:", error.localizedDescription)
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

        // Без unifiedPlan audio track может не работать
        config.sdpSemantics = .unifiedPlan

        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: ["DtlsSrtpKeyAgreement": "true"]
        )

        self.peerConnection = factory.peerConnection(
            with: config,
            constraints: constraints,
            delegate: self
        )
    }

    // MARK: - Audio Track

    private func addAudioTrack() {
        let source = factory.audioSource(with: RTCMediaConstraints(mandatoryConstraints: nil,
                                                                   optionalConstraints: nil))
        let track = factory.audioTrack(with: source, trackId: "audio0")
        peerConnection?.add(track, streamIds: ["stream0"])
    }

    // MARK: - Loopback

    func startLoopback() {
        guard let pc = peerConnection else {
            print("PeerConnection is nil")
            return
        }

        addAudioTrack()

        let offerConstraints = RTCMediaConstraints(
            mandatoryConstraints: ["OfferToReceiveAudio": "true"],
            optionalConstraints: nil
        )

        pc.offer(for: offerConstraints) { [weak self] offer, error in
            guard let self = self else { return }

            if let error = error {
                print("Offer creation failed:", error.localizedDescription)
                return
            }
            guard let offer = offer else {
                print("Offer is nil")
                return
            }

            self.peerConnection?.setLocalDescription(offer) { error in
                if let error = error {
                    print("Failed setLocalDescription(offer):", error.localizedDescription)
                    return
                }

                // loopback = удалённый = локальный
                self.peerConnection?.setRemoteDescription(offer) { error in
                    if let error = error {
                        print("Failed setRemoteDescription(offer):", error.localizedDescription)
                        return
                    }
                    self.createAnswerForLoopback()
                }
            }
        }
    }

    private func createAnswerForLoopback() {
        guard let pc = peerConnection else { return }

        let answerConstraints = RTCMediaConstraints(mandatoryConstraints: nil,
                                                    optionalConstraints: nil)

        pc.answer(for: answerConstraints) { [weak self] answer, error in
            guard let self = self else { return }

            if let error = error {
                print("Answer creation failed:", error.localizedDescription)
                return
            }
            guard let answer = answer else {
                print("Answer is nil")
                return
            }

            self.peerConnection?.setLocalDescription(answer) { error in
                if let error = error {
                    print("Failed setLocalDescription(answer):", error.localizedDescription)
                    return
                }

                self.peerConnection?.setRemoteDescription(answer) { error in
                    if let error = error {
                        print("Failed setRemoteDescription(answer):", error.localizedDescription)
                        return
                    }

                    print("Loopback negotiation complete")
                }
            }
        }
    }

    deinit {
        RTCCleanupSSL()
    }
}

// MARK: - RTCPeerConnectionDelegate

extension WebRTCManager: RTCPeerConnectionDelegate {

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange stateChanged: RTCSignalingState) {
        print("Signaling state:", stateChanged.rawValue)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didAdd stream: RTCMediaStream) {
        print("Stream added")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didRemove stream: RTCMediaStream) {
        print("Stream removed")
    }

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("Negotiation needed")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange newState: RTCIceConnectionState) {
        print("ICE connection state:", newState.rawValue)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange newState: RTCIceGatheringState) {
        print("ICE gathering state:", newState.rawValue)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didGenerate candidate: RTCIceCandidate) {
        print("ICE candidate:", candidate.sdp)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didRemove candidates: [RTCIceCandidate]) {
        print("ICE candidates removed:", candidates.count)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didOpen dataChannel: RTCDataChannel) {
        print("Data channel opened")
    }
}

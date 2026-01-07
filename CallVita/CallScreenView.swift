import SwiftUI
import Combine

// MARK: - Call Direction

enum CallDirection {
    case outgoing
    case incoming
}

// MARK: - Call State

enum CallState: Equatable {
    case ringing
    case connected
    case ended
}

// MARK: - Call Screen

struct CallScreenView: View {

    let contact: Contact
    let direction: CallDirection
    @Binding var isCalling: Bool

    @State private var callState: CallState = .ringing
    @State private var seconds: Int = 0
    @State private var timer: Timer?
    @State private var buttonPressed = false

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    // MARK: - Animation

    private var transitionAnimation: Animation {
        reduceMotion
        ? .easeInOut(duration: 0.15)
        : .spring(response: 0.35, dampingFraction: 0.85)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Text(contact.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                statusView

                if callState == .connected {
                    Text(timeString)
                        .font(.system(size: 36, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                }

                Spacer()

                Button(action: primaryAction) {
                    Text(buttonTitle)
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(buttonColor)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .scaleEffect(buttonPressed ? 0.96 : 1.0)
                }
                .padding(.horizontal, 24)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in buttonPressed = true }
                        .onEnded { _ in buttonPressed = false }
                )

                Spacer()
            }
            .animation(transitionAnimation, value: callState)
        }
        .onAppear {
            startRinging()

            if direction == .outgoing {
                simulateOutgoingConnection()
            }
        }
        .onDisappear {
            cleanup()
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Status View

    @ViewBuilder
    private var statusView: some View {
        switch callState {
        case .ringing:
            Text(direction == .incoming ? "Incoming Call…" : "Calling…")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)

        case .connected:
            Text("Connected")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)

        case .ended:
            Text("Call Ended")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }

    // MARK: - Button UI

    private var buttonTitle: String {
        switch callState {
        case .ringing:
            return direction == .incoming ? "Answer" : "Cancel"
        case .connected:
            return "End Call"
        case .ended:
            return "Close"
        }
    }

    private var buttonColor: Color {
        switch callState {
        case .ringing: return .green
        case .connected: return .red
        case .ended: return .gray
        }
    }

    // MARK: - Actions

    private func primaryAction() {
        switch callState {
        case .ringing:
            direction == .incoming ? answerCall() : endCall()
        case .connected:
            endCall()
        case .ended:
            isCalling = false
        }
    }

    private func answerCall() {
        stopRinging()
        transition(to: .connected)
        startTimer()
    }

    private func endCall() {
        cleanup()
        transition(to: .ended)
        CallManager.shared.endCall()
    }

    // MARK: - Helpers

    private func startRinging() {
        SoundManager.shared.playRingtone()
        HapticManager.shared.startRinging()
    }

    private func stopRinging() {
        SoundManager.shared.stopRingtone()
        HapticManager.shared.stopRinging()
    }

    private func cleanup() {
        stopRinging()
        stopTimer()
    }

    private func simulateOutgoingConnection() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard callState == .ringing else { return }
            transition(to: .connected)
            startTimer()
        }
    }

    private func transition(to newState: CallState) {
        callState = newState
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            seconds += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        seconds = 0
    }

    private var timeString: String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

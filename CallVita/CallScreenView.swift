import SwiftUI
import Combine

// MARK: - Call State

enum CallState: Equatable {
    case ringing
    case connected
    case ended
}

// MARK: - Call Screen

struct CallScreenView: View {
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
            // 🔒 Lock-style dark background
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // STATUS (spring animated)
                statusView
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))

                // TIMER (animated)
                if callState == .connected {
                    Text(timeString)
                        .font(.system(size: 36, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                        .transition(.opacity.combined(with: .scale))
                }

                Spacer()

                // MAIN BUTTON (scale feedback)
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
                        .onChanged { _ in
                            withAnimation(.easeOut(duration: 0.1)) {
                                buttonPressed = true
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.easeOut(duration: 0.1)) {
                                buttonPressed = false
                            }
                        }
                )

                Spacer()
            }
            .animation(transitionAnimation, value: callState)
        }

        // ▶️ Ringing start
        .onAppear {
            if callState == .ringing {
                SoundManager.shared.playRingtone()
                HapticManager.shared.startRinging()
            }
        }

        // 🛑 Global cleanup
        .onDisappear {
            stopTimer()
            SoundManager.shared.stopRingtone()
            HapticManager.shared.stopRinging()
        }

        // 🔒 Background / Lock
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.willResignActiveNotification
            )
        ) { _ in
            SoundManager.shared.stopRingtone()
            HapticManager.shared.stopRinging()
            stopTimer()
        }

        // 🔓 Foreground
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.didBecomeActiveNotification
            )
        ) { _ in
            if callState == .ringing {
                SoundManager.shared.playRingtone()
                HapticManager.shared.startRinging()
            }
        }

        .navigationBarBackButtonHidden(true)
    }

    // MARK: - STATUS VIEW

    @ViewBuilder
    private var statusView: some View {
        switch callState {
        case .ringing:
            RingingView()

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

    // MARK: - BUTTON UI

    private var buttonTitle: String {
        switch callState {
        case .ringing:
            return "Answer"
        case .connected:
            return "End Call"
        case .ended:
            return "Close"
        }
    }

    private var buttonColor: Color {
        switch callState {
        case .ringing:
            return .green
        case .connected:
            return .red
        case .ended:
            return .gray
        }
    }

    // MARK: - ACTIONS

    private func primaryAction() {
        switch callState {
        case .ringing:
            answerCall()
        case .connected:
            endCall()
        case .ended:
            closeScreen()
        }
    }

    private func answerCall() {
        HapticManager.shared.stopRinging()
        HapticManager.shared.answerFeedback()

        SoundManager.shared.stopRingtone()
        callState = .connected
        startTimer()
    }

    private func endCall() {
        HapticManager.shared.stopRinging()
        HapticManager.shared.endCallFeedback()

        SoundManager.shared.stopRingtone()
        stopTimer()
        callState = .ended
        CallManager.shared.endCall()
    }

    private func closeScreen() {
        isCalling = false
    }

    // MARK: - TIMER

    private func startTimer() {
        stopTimer()
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
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d", min, sec)
    }
}

// MARK: - RINGING VIEW

private struct RingingView: View {
    @State private var pulse = false

    var body: some View {
        Text("Ringing…")
            .font(.title)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .scaleEffect(pulse ? 1.12 : 1.0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.9)
                        .repeatForever(autoreverses: true)
                ) {
                    pulse = true
                }
            }
            .onDisappear {
                pulse = false
            }
    }
}

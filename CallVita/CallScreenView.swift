import SwiftUI

enum CallState: Equatable {
    case ringing
    case connected
    case ended
}

struct CallScreenView: View {
    @Binding var isCalling: Bool

    @State private var callState: CallState = .ringing
    @State private var seconds: Int = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // MARK: - STATUS
            statusView

            // MARK: - TIMER (only when connected)
            if callState == .connected {
                Text(timeString)
                    .font(.system(size: 36, weight: .medium, design: .monospaced))
            }

            Spacer()

            // MARK: - MAIN BUTTON
            Button(action: primaryAction) {
                Text(buttonTitle)
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(buttonColor)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .onDisappear {
            stopTimer()
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

        case .ended:
            Text("Call Ended")
                .font(.title)
                .fontWeight(.semibold)
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
        callState = .connected
        startTimer()
    }

    private func endCall() {
        callState = .ended
        stopTimer()
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

// MARK: - RINGING VIEW (ANIMATION ONLY HERE)

private struct RingingView: View {
    @State private var pulse = false

    var body: some View {
        Text("Ringing…")
            .font(.title)
            .fontWeight(.semibold)
            .scaleEffect(pulse ? 1.15 : 1.0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.8)
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

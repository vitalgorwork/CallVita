import SwiftUI

struct ContentView: View {

    @StateObject private var callSession = CallSession.shared

    var body: some View {
        NavigationStack {
            Group {
                switch callSession.state {

                case .idle:
                    mainScreen

                case .incoming, .dialing, .connected:
                    if let name = callSession.callerName {
                        CallScreenView(
                            contact: Contact(id: UUID().uuidString, name: name),
                            direction: callSession.state == .incoming ? .incoming : .outgoing,
                            isCalling: isCallingBinding
                        )
                    } else {
                        mainScreen
                    }

                case .ended:
                    mainScreen
                }
            }
        }
    }

    // MARK: - Binding for CallScreenView

    private var isCallingBinding: Binding<Bool> {
        Binding(
            get: { callSession.state != .idle },
            set: { newValue in
                if newValue == false {
                    CallKitManager.shared.endCall()
                    callSession.reset()
                }
            }
        )
    }

    // MARK: - Main Screen

    private var mainScreen: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("CallVita")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Private internet calls")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Button {
                startOutgoingCall()
            } label: {
                Text("Press to Call")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)

            Button {
                simulateDevIncomingCall()
            } label: {
                Text("Simulate Incoming Call (DEV)")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.15))
                    .foregroundColor(.purple)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)

            NavigationLink {
                ContactsView()
            } label: {
                Text("Contacts")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Actions

    private func startOutgoingCall() {
        CallKitManager.shared.startCall(to: "Bob")
    }

    private func simulateDevIncomingCall() {
        CallKitManager.shared.reportIncomingCall(handle: "John Appleseed")
    }
}

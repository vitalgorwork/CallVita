import SwiftUI

struct ContentView: View {

    @State private var isCalling: Bool = false
    @State private var selectedContact: Contact?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("CallVita")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Private internet calls")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                // 🔵 OUTGOING CALL
                Button {
                    startOutgoingCall()
                } label: {
                    Text("Press to Call")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isCalling ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .disabled(isCalling)
                .padding(.horizontal, 24)

                // 🟣 INCOMING CALL (DEV SIMULATION)
                Button {
                    simulateIncomingCall()
                } label: {
                    Text("Simulate Incoming Call")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)

                // 📇 CONTACTS
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
            // ⬇️ Переход ТОЛЬКО для звонков
            .navigationDestination(isPresented: $isCalling) {
                if let contact = selectedContact {
                    CallScreenView(
                        contact: contact,
                        isCalling: $isCalling
                    )
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: CallEvents.incomingSimulated
                )
            ) { _ in
                handleIncomingCall()
            }
        }
    }

    // MARK: - Actions

    private func startOutgoingCall() {
        let contact = Contact(
            id: UUID().uuidString,
            name: "Alice"
        )
        selectedContact = contact
        CallManager.shared.startCall()
        isCalling = true
    }

    private func simulateIncomingCall() {
        CallManager.shared.simulateIncomingCall()
    }

    private func handleIncomingCall() {
        guard !isCalling else { return }

        selectedContact = Contact(
            id: UUID().uuidString,
            name: "Incoming Call"
        )
        isCalling = true
    }
}

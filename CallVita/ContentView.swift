import SwiftUI

struct ContentView: View {

    @State private var isCalling: Bool = false
    @State private var selectedContact: Contact?

    @State private var incomingContact: Contact?
    @State private var showIncomingCall: Bool = false

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

                // 🟣 DEV INCOMING CALL (без CallKit)
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
            // ⬇️ OUTGOING CALL SCREEN
            .navigationDestination(isPresented: $isCalling) {
                if let contact = selectedContact {
                    CallScreenView(
                        contact: contact,
                        direction: .outgoing,
                        isCalling: $isCalling
                    )
                }
            }
            // ⬇️ DEV INCOMING CALL SCREEN
            .navigationDestination(isPresented: $showIncomingCall) {
                if let contact = incomingContact {
                    CallScreenView(
                        contact: contact,
                        direction: .incoming,
                        isCalling: $showIncomingCall
                    )
                }
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

    // ✅ DEV Incoming (без CallKit)
    private func simulateDevIncomingCall() {
        let contact = Contact(
            id: UUID().uuidString,
            name: "John Appleseed"
        )
        incomingContact = contact
        showIncomingCall = true
    }
}

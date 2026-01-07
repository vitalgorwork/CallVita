import SwiftUI
import Combine

struct ContentView: View {

    @State private var isCalling = false
    @State private var selectedContact: Contact? = nil

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
                Button(action: {
                    let contact = Contact(id: UUID(), name: "Alice")
                    selectedContact = contact
                    CallManager.shared.startCall()
                    isCalling = true
                }) {
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
                Button(action: {
                    let contact = Contact(id: UUID(), name: "Incoming Call")
                    selectedContact = contact
                    CallManager.shared.simulateIncomingCall()
                }) {
                    Text("Simulate Incoming Call")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
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
                if !isCalling {
                    selectedContact = Contact(id: UUID(), name: "Incoming Call")
                    isCalling = true
                }
            }
        }
    }
}

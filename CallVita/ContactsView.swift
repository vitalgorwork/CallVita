import SwiftUI

struct ContactsView: View {

    // 🔹 Тестовые контакты (id = String, как в реальных CNContact)
    private let contacts: [Contact] = [
        Contact(id: "test-alice", name: "Alice"),
        Contact(id: "test-bob", name: "Bob")
    ]

    @State private var selectedContact: Contact? = nil
    @State private var isCalling = false

    var body: some View {
        NavigationStack {
            List(contacts) { contact in
                HStack {
                    Text(contact.name)
                        .font(.headline)

                    Spacer()

                    Button("Call") {
                        selectedContact = contact
                        isCalling = true
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Contacts")

            // ✅ ЕДИНСТВЕННАЯ точка навигации
            .navigationDestination(isPresented: $isCalling) {
                if let contact = selectedContact {
                    CallScreenView(
                        contact: contact,
                        isCalling: $isCalling
                    )
                }
            }
        }
    }
}

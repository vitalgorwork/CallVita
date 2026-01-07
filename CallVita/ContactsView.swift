import SwiftUI

struct ContactsView: View {

    // Тестовые контакты
    private let contacts: [Contact] = [
        Contact(id: UUID(), name: "Alice"),
        Contact(id: UUID(), name: "Bob")
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

            // ✅ ЕДИНСТВЕННОЕ место перехода
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

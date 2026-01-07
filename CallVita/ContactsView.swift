import SwiftUI

struct ContactsView: View {

    private let contacts: [Contact] = [
        Contact(id: UUID(), name: "Alice"),
        Contact(id: UUID(), name: "Bob")
    ]

    @State private var isCalling = false
    @State private var selectedContact: Contact? = nil

    var body: some View {
        NavigationView {
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
        }
        .fullScreenCover(isPresented: $isCalling) {
            CallScreenView(isCalling: $isCalling)
        }
    }
}

#Preview {
    ContactsView()
}

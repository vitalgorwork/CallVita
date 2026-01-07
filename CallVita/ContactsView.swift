import SwiftUI

struct ContactsView: View {

    // Временные тестовые контакты
    private let contacts: [Contact] = [
        Contact(id: UUID(), name: "Alice"),
        Contact(id: UUID(), name: "Bob")
    ]

    var body: some View {
        NavigationView {
            List(contacts) { contact in
                HStack {
                    Text(contact.name)
                        .font(.headline)

                    Spacer()

                    Button("Call") {
                        print("Call \(contact.name)")
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Contacts")
        }
    }
}

#Preview {
    ContactsView()
}

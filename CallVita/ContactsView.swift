import SwiftUI

struct ContactsView: View {

    @State private var contacts: [Contact] = []
    @State private var isLoading = true
    @State private var accessDenied = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading contacts...")
            } else if accessDenied {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)

                    Text("Access to contacts is denied")
                        .font(.headline)

                    Text("Please enable contacts access in Settings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding()
            } else {
                List(contacts) { contact in
                    NavigationLink {
                        CallHostView(contact: contact)
                    } label: {
                        Text(contact.name)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .navigationTitle("Contacts")
        .task {
            await loadContacts()
        }
    }

    // MARK: - Contacts Loading

    @MainActor
    private func loadContacts() async {
        isLoading = true
        accessDenied = false

        let granted = await ContactService.shared.requestAccess()

        if granted {
            contacts = await ContactService.shared.fetchContacts()
            isLoading = false
        } else {
            accessDenied = true
            isLoading = false
        }
    }
}

// MARK: - Call Host (Contacts → Call Screen)

private struct CallHostView: View {
    let contact: Contact

    @State private var isCalling = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        CallScreenView(
            contact: contact,
            direction: .outgoing,   // ✅ ОБЯЗАТЕЛЬНО
            isCalling: $isCalling
        )
        .onAppear {
            CallManager.shared.startCall()
        }
        .onChange(of: isCalling) { newValue in
            if newValue == false {
                dismiss()
            }
        }
    }
}

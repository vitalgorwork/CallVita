import Foundation
import Contacts

final class ContactService {
    static let shared = ContactService()
    private init() {}

    private let store = CNContactStore()

    func requestAccess() async -> Bool {
        let status = CNContactStore.authorizationStatus(for: .contacts)

        switch status {
        case .authorized:
            return true
        case .notDetermined:
            do {
                return try await store.requestAccess(for: .contacts)
            } catch {
                print("❌ Contacts permission error: \(error)")
                return false
            }
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    func fetchContacts(limit: Int = 50) -> [Contact] {
        let keys: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor
        ]

        let request = CNContactFetchRequest(keysToFetch: keys)
        request.unifyResults = true

        var result: [Contact] = []
        var count = 0

        do {
            try store.enumerateContacts(with: request) { cn, stop in
                let fullName = "\(cn.givenName) \(cn.familyName)".trimmingCharacters(in: .whitespaces)
                let name = fullName.isEmpty ? "No Name" : fullName

                result.append(Contact(id: UUID(), name: name))
                count += 1

                if count >= limit {
                    stop.pointee = true
                }
            }
        } catch {
            print("❌ Fetch contacts error: \(error)")
        }

        return result
    }
}

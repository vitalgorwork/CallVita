import Foundation
import Contacts

final class ContactService {
    static let shared = ContactService()
    private init() {}

    private let store = CNContactStore()

    // MARK: - Permission

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

    // MARK: - Fetch Contacts

    func fetchContacts(limit: Int = 50) async -> [Contact] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let keys: [CNKeyDescriptor] = [
                    CNContactIdentifierKey as CNKeyDescriptor,
                    CNContactGivenNameKey as CNKeyDescriptor,
                    CNContactFamilyNameKey as CNKeyDescriptor
                ]

                let request = CNContactFetchRequest(keysToFetch: keys)
                request.unifyResults = true

                var result: [Contact] = []
                var count = 0

                do {
                    try self.store.enumerateContacts(with: request) { cn, stop in
                        let fullName = "\(cn.givenName) \(cn.familyName)"
                            .trimmingCharacters(in: .whitespaces)

                        let name = fullName.isEmpty ? "No Name" : fullName

                        result.append(
                            Contact(
                                id: cn.identifier,
                                name: name
                            )
                        )

                        count += 1
                        if count >= limit {
                            stop.pointee = true
                        }
                    }
                } catch {
                    print("❌ Fetch contacts error: \(error)")
                }

                // сортировка по имени
                let sorted = result.sorted {
                    $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }

                continuation.resume(returning: sorted)
            }
        }
    }
}

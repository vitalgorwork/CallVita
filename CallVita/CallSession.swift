import Foundation
import Combine

// MARK: - Call Lifecycle State
enum CallLifecycleState {
    case idle
    case incoming
    case dialing
    case connected
    case ended
}

// MARK: - Call Session (Single Source of Truth)
final class CallSession: ObservableObject {

    static let shared = CallSession()

    @Published private(set) var state: CallLifecycleState = .idle
    @Published private(set) var callerName: String?

    private init() {}

    // MARK: - State transitions (ALWAYS main-thread)
    func incomingCall(from name: String) {
        DispatchQueue.main.async {
            self.callerName = name
            self.state = .incoming
        }
    }

    func outgoingCall(to name: String) {
        DispatchQueue.main.async {
            self.callerName = name
            self.state = .dialing
        }
    }

    func callAnswered() {
        DispatchQueue.main.async {
            self.state = .connected
        }
    }

    /// Переходное состояние — затем возврат в idle
    func callEnded() {
        DispatchQueue.main.async {
            self.state = .ended
            self.callerName = nil

            // переход в idle — следующий runloop тик
            DispatchQueue.main.async {
                self.state = .idle
            }
        }
    }

    /// Полный ручной сброс
    func reset() {
        DispatchQueue.main.async {
            self.state = .idle
            self.callerName = nil
        }
    }
}

import Foundation
import UIKit

// MARK: - App Lifecycle Events

extension Notification.Name {
    static let appWillEnterForeground = Notification.Name("appWillEnterForeground")
    static let appDidEnterBackground = Notification.Name("appDidEnterBackground")
    static let appDidBecomeActive = Notification.Name("appDidBecomeActive")
    static let appWillResignActive = Notification.Name("appWillResignActive")
}

// MARK: - AppLifecycleObserver

final class AppLifecycleObserver {

    static let shared = AppLifecycleObserver()

    private init() {
        subscribe()
    }

    private func subscribe() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    // MARK: - System Callbacks

    @objc private func willEnterForeground() {
        NotificationCenter.default.post(name: .appWillEnterForeground, object: nil)
    }

    @objc private func didEnterBackground() {
        NotificationCenter.default.post(name: .appDidEnterBackground, object: nil)
    }

    @objc private func didBecomeActive() {
        NotificationCenter.default.post(name: .appDidBecomeActive, object: nil)
    }

    @objc private func willResignActive() {
        NotificationCenter.default.post(name: .appWillResignActive, object: nil)
    }
}

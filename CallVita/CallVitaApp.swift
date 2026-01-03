import SwiftUI
import UserNotifications

@main
struct CallVitaApp: App {

    // Подключаем AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    init() {
        requestPushPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func requestPushPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("❌ Push permission error:", error)
                } else {
                    print("✅ Push permission granted:", granted)
                }
            }

        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}

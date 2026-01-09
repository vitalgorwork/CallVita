//
//  CallVitaApp.swift
//  CallVita
//
//  Created by Vitaliy Gorpenko on 12/31/25.
//

import SwiftUI
import FirebaseCore

// MARK: - Firebase AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        FirebaseApp.configure()
        return true
    }
}

@main
struct CallVitaApp: App {

    // Register Firebase delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        // 🔁 Start observing app lifecycle events
        _ = AppLifecycleObserver.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

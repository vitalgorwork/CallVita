//
//  CallVitaApp.swift
//  CallVita
//
//  Created by Vitaliy Gorpenko on 12/31/25.
//

import SwiftUI

@main
struct CallVitaApp: App {

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

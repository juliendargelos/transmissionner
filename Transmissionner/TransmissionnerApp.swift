//
//  TransmissionnerApp.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 13/03/2024.
//

import SwiftUI
import SwiftData

@main
struct TransmissionnerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Connection.self
        ])
      
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .windowToolbarStyle(.unified)
    }
}

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
        
    #if DEBUG
      let isStoredInMemoryOnly = true
    #else
      let isStoredInMemoryOnly = false
    #endif
      
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)

    do {
      let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
      
      #if DEBUG
        modelContainer.mainContext.insert(Connection(
          name: "",
          hostname: "localhost",
          port: 9091,
          path: "/transmission/rpc",
          ssl: false,
          username: nil,
          password: nil,
          updateInterval: 1
        ))
      #endif
          
      return modelContainer
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(sharedModelContainer)
#if os(macOS)
    .windowToolbarStyle(.unified)
#endif
  }
}

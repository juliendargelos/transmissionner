//
//  ContentView.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 13/03/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var connection: Connection?
  @ObservedObject private var client: Client = Client()
  
  func initializeClient() {
    client.set(connection: connection)
  }
  
  func onToolbarStart() {
    client.torrents.start()
  }
  
  func onToolbarStop() {
    client.torrents.stop()
  }

  var body: some View {
    GeometryReader { geometry in
      NavigationStack {
        VStack {
          TorrentListView(torrents: client.torrents)
            .frame(width: geometry.size.width)
        }
        .navigationTitle("")
        .frame(minWidth: 600, minHeight: 100)
        .toolbar {
          TransmissionnerToolbarContent(
            connection: $connection,
            canStart: client.canStartAll,
            canStop: client.canStopAll,
            onStart: onToolbarStart,
            onStop: onToolbarStop
          )
        }
      }
      .onChange(of: connection) { oldValue, newValue in
        initializeClient()
      }
      .onAppear {
        initializeClient()
      }
      .onDrop(of: ["public.url", "public.file-url"], isTargeted: nil) { (items) -> Bool in
        for item in items {
          let identifier = item.registeredTypeIdentifiers.first
          
          if item.registeredTypeIdentifiers.first == nil {
            continue
          }
          
          if identifier != "public.url" && identifier != "public.file-url" {
            continue
          }
          
          item.loadItem(forTypeIdentifier: identifier!, options: nil) { (urlData, error) in
            if urlData == nil {
              return
            }
            
            DispatchQueue.main.async {
              let url = NSURL(absoluteURLWithDataRepresentation: urlData as! Data, relativeTo: nil) as URL
              client.addTorrentFile(url: url)
            }
          }
        }
        
        return true
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Connection.self, inMemory: true)
}

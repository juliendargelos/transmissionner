//
//  ContentView.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 13/03/2024.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var connection: Connection?
  @ObservedObject private var client: Client = Client()
  @State private var importing: Bool = false
  
  func initializeClient() {
    client.set(connection: connection)
  }
  
  func onToolbarStart() {
    client.torrents.start()
  }
  
  func onToolbarStop() {
    client.torrents.stop()
  }
  
  func onToolbarAdd() {
    importing = true
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
            onStop: onToolbarStop,
            onAdd: onToolbarAdd
          )
        }
      }
      .fileImporter(
         isPresented: $importing,
         allowedContentTypes: [UTType.init(filenameExtension: "torrent")!],
         allowsMultipleSelection: true
       ) { result in
         switch result {
           case .success(let files):
             files.forEach { url in
               let gotAccess = url.startAccessingSecurityScopedResource()
               if !gotAccess { return }
               
               DispatchQueue.main.async {
                 client.addTorrentFile(url: url)
               }
               
               url.stopAccessingSecurityScopedResource()
             }
           
           case .failure(let error):
             print(error)
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
              
              if (url.pathExtension != "torrent") {
                return
              }
              
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

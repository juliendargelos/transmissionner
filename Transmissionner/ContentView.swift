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
  @State private var inspectorView: String?
  @State private var inspectorPresented: Bool = false
  @State private var selectedTorrent: Torrent? = nil
  
  private var inspectorSelection: Binding<String?> {
    Binding(
      get: {
        return inspectorPresented ? inspectorView : nil
      },
      set: { value in
        inspectorView = value
        inspectorPresented = value != nil
      }
    )
  }
  
  func initializeClient() {
    client.set(connection: connection)
    client.fetch()
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
  
  func onToolbarEditStart() {
    client.disableSync()
  }
  
  func onToolbarEditEnd() {
    client.enableSync()
  }
  
  func onPreferencesFetch(complete: (() -> Void)? = nil) {
    client.fetchPreferences(complete)
  }
  
  func onPreferencesSave(complete: (() -> Void)? = nil) {
    client.postPreferences(complete)
  }
  
  func onToolbarToggleAlternativeLimits() {
    client.preferences.altSpeedEnabled = !client.preferences.altSpeedEnabled
    client.postPreferences()
  }

  var body: some View {
    VStack{
      NavigationStack {
        VStack {
          TorrentListView(
            torrents: client.torrents,
            onSelect: { torrent in
              selectedTorrent = torrent
            }
          )
        }
        .navigationTitle("")
        .frame(minWidth: 600, minHeight: 100)
        .toolbar {
          TransmissionnerToolbarContent(
            connection: $connection,
            preferences: client.preferences,
            inspectorSelection: inspectorSelection,
            canStart: client.canStartAll,
            canStop: client.canStopAll,
            onStart: onToolbarStart,
            onStop: onToolbarStop,
            onAdd: onToolbarAdd,
            onToggleAlternativeLimits: onToolbarToggleAlternativeLimits
          )
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
    .inspector(isPresented: $inspectorPresented) {
      VStack {
        if !inspectorPresented {
          
        } else if inspectorView == "preferences" {
          PreferencesView(
            preferences: client.preferences,
            onSave: onPreferencesSave,
            onFetch: onPreferencesFetch
          )
        } else if inspectorView == "torrent" {
          if selectedTorrent == nil {
            Text("No torrent selected")
              .foregroundColor(.secondary)
          } else {
            TorrentDetailsView(
              torrent: selectedTorrent!,
              onSave: { complete in
                selectedTorrent?.post(complete)
              }
            )
          }
        }
      }
      .inspectorColumnWidth(min: 400, ideal: 400, max: 600)
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Connection.self, inMemory: true)
    .frame(width: 800)
}

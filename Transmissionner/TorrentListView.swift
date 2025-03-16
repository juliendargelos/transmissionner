//
//  TorrentListView.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 18/03/2024.
//

import SwiftUI

struct TorrentListView: View {
  @ObservedObject public var torrents: TorrentList
  @State public var selection: Int?
  @State private var isDeleting: Bool = false
  @State private var deletingTorrent: Torrent?
  
  public var onSelect: ((_ torrent: Torrent?) -> Void)? = nil
  
  var body: some View {
    let list = List(selection: $selection) {
      ForEach(torrents.items, id: \.id) { torrent in
        TorrentView(
          torrent: torrent,
          selected: selection == torrent.id
        )
        .onChange(of: selection) { oldValue, newValue in
          let torrent = newValue == nil ? nil : torrents.items.first(where: { torrent in
            torrent.id == newValue
          })
          
           onSelect?(torrent)
        }
          .padding(.horizontal, 15)
          .padding(.vertical, 10)
          .background(selection == torrent.id ? Color.accentColor : nil)
          .background()
          .clipShape(.rect(cornerRadius: 8))
          .contextMenu {
            Button {
              torrent.isStopped ? torrent.start() : torrent.stop()
            } label: {
              if torrent.isStopped {
                Label("Start", systemImage: "play.fill")
              } else {
                Label("Stop", systemImage: "pause.fill")
              }
            }
            
            Button {
              deletingTorrent = torrent
              isDeleting = true
            } label: {
              Label("Remove", systemImage: "trash.fill")
            }
          }
      }
      .onMove { from, to in
        torrents.move(from: from, to: to)
      }
      .listRowBackground(Rectangle().fill(.background))
    }
    .listStyle(.plain)
    .confirmationDialog(
        "Are you sure you want to remove this torrent?",
        isPresented: $isDeleting
    ) {
      Button {
        deletingTorrent?.remove()
      } label: {
        Text("Remove")
      }
      
      Button {
        deletingTorrent?.remove(deleteFiles: true)
      } label: {
        Text("Remove and delete files")
      }
      
      Button("Cancel", role: .cancel) {
        isDeleting = false
      }
    }
    
    #if os(macOS)
      return list
        .onDeleteCommand(perform: {
          if selection == nil {
            return
          }
          
          deletingTorrent = torrents.items.first(where: { torrent in
            torrent.id == selection!
          })
          
          isDeleting = true
        })
    #else
      return list
    #endif
  }
}

#Preview {
  TorrentListView(torrents: TorrentList(items: [
    Torrent(id: 1, name: "Lorem"),
    Torrent(id: 2, name: "Ipsum"),
    Torrent(id: 3, name: "Dolor")
  ]))
}

//
//  TorrentList.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 17/03/2024.
//

import Foundation
import SwiftUI

class TorrentList: ObservableObject {
  @Published public var items: [Torrent]
  
  public var onReorder: (() -> Void)? = nil
  public var onStart: (() -> Void)? = nil
  public var onStop: (() -> Void)? = nil
  public var onTorrentStart: ((_: Int) -> Void)? = nil
  public var onTorrentStop: ((_: Int) -> Void)? = nil
  public var onTorrentRemove: ((_: Int, _: Bool) -> Void)? = nil
  public var onTorrentPost: ((_: Torrent, _:(() -> Void)?) -> Void)? = nil
  
  init(
    items: [Torrent] = []
  ) {
    self.items = items
  }
  
  func update(items: [[String: Any]]) {
    for (_, torrent) in items.enumerated() {
      if let existing = self.items.first(where: { candidate in candidate.id == torrent["id"] as! Int }) {
        existing.update(torrent: torrent)
      } else {
        let newTorrent = Torrent()
        newTorrent.onStart = { self.onTorrentStart?(newTorrent.id) }
        newTorrent.onStop = { self.onTorrentStop?(newTorrent.id) }
        
        newTorrent.onRemove = { deleteFiles in
          self.remove(torrent: newTorrent)
          self.onTorrentRemove?(newTorrent.id, deleteFiles)
        }
        
        newTorrent.onPost = { complete in
          self.onTorrentPost?(newTorrent, complete)
        }
        
        newTorrent.update(torrent: torrent)
        self.items.append(newTorrent)
      }
    }
    
    self.items = self.items.filter { torrent in items.contains { candidate in candidate["id"] as! Int == torrent.id } }
    sort()
  }
  
  func clear() {
    self.items.removeAll()
  }
  
  func add(torrent: Torrent) {
    torrent.onStart = { self.onTorrentStart?(torrent.id) }
    torrent.onStop = { self.onTorrentStop?(torrent.id) }
    
    torrent.onRemove = { deleteFiles in
      self.remove(torrent: torrent)
      self.onTorrentRemove?(torrent.id, deleteFiles)
    }
    
    remove(torrent: torrent)
    items.append(torrent)
    sort()
  }
  
  func remove(torrent: Torrent) {
    items.removeAll { candidate in candidate.id == torrent.id }
  }
  
  func move(from: IndexSet, to: Int) {
    var changed: Bool = false
    items.move(fromOffsets: from, toOffset: to)
    
    for (i, torrent) in items.enumerated() {
      if torrent.queuePosition != i {
        changed = true
        torrent.queuePosition = i
      }
    }
    
    sort()
    
    if changed {
      onReorder?()
    }
  }
  
  func start() {
    for item in items {
      item.status = TorrentStatus.download
    }
    
    onStart?()
  }
  
  func stop() {
    for item in items {
      item.status = TorrentStatus.stopped
    }
    
    onStop?()
  }
  
  private func sort() {
    items.sort { a, b in a.queuePosition < b.queuePosition }
  }
}

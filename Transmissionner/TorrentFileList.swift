//
//  TorrentFileList.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 17/03/2024.
//

import Foundation
import SwiftUI

class TorrentFileList: ObservableObject {
  @Published public var items: [TorrentFile]
  
  init(items: [TorrentFile] = []) {
    self.items = items
  }
  
  func update(items: [[String: Any]], in torrent: [String: Any]? = nil) {
    self.items.removeAll()
    var index = 0
    
    for file in items {
      let newFile = TorrentFile()
      torrent == nil
        ? newFile.update(file: file)
        : newFile.update(file: file, at: index, in: torrent!)
      
      self.items.append(newFile)
    }
  }
}

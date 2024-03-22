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
  
  func update(items: [[String: Any]]) {
    self.items.removeAll()
    
    for file in items {
      let newFile = TorrentFile()
      newFile.update(file: file)
      self.items.append(newFile)
    }
  }
}

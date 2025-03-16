//
//  TorrentFile.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 17/03/2024.
//

import Foundation
import SwiftUI

enum TorrentFilePriority: Int {
  case low = -1
  case normal = 0
  case high = 1
}

class TorrentFile: ObservableObject {
  @Published var name: String
  @Published var length: Int
  @Published var bytesCompleted: Int
  @Published var priority: TorrentFilePriority
  @Published var wanted: Bool
  
  init(
    name: String = "",
    length: Int = 0,
    bytesCompleted: Int = 0,
    priority: TorrentFilePriority = .normal,
    wanted: Bool = true
  ) {
    self.name = name
    self.length = length
    self.bytesCompleted = bytesCompleted
    self.priority = priority
    self.wanted = wanted
  }
  
  func update(file: [String: Any]) {
    name = file["name"] as! String
    length = file["length"] as! Int
    bytesCompleted = file["bytesCompleted"] as! Int
  }
  
  func update(file: [String: Any], at index: Int, in torrent: [String: Any]) {
    update(file: file)
    wanted = (torrent["wanted"] as! [Int])[index] == 1
    priority = TorrentFilePriority(rawValue: (torrent["priorities"] as! [Int])[index]) ?? .normal
  }
}

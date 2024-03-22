//
//  TorrentFile.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 17/03/2024.
//

import Foundation
import SwiftUI

class TorrentFile: ObservableObject {
  @Published var name: String
  @Published var length: Int
  @Published var bytesCompleted: Int
  
  init(
    name: String = "",
    length: Int = 0,
    bytesCompleted: Int = 0
  ) {
    self.name = name
    self.length = length
    self.bytesCompleted = 0
  }
  
  func update(file: [String: Any]) {
    name = file["name"] as! String
    length = file["length"] as! Int
    bytesCompleted = file["bytesCompleted"] as! Int
  }
}

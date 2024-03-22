//
//  Preferences.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 17/03/2024.
//

import Foundation
import SwiftUI

class Preferences: ObservableObject {
  @Published var downloadDir: String
  @Published var incompleteDir: String
  
  init(
    downloadDir: String = "",
    incompleteDir: String = ""
  ) {
    self.downloadDir = downloadDir
    self.incompleteDir = incompleteDir
  }
  
  func update(preferences: [String: Any]) {
    downloadDir = preferences["download-dir"] as! String
    incompleteDir = preferences["incomplete-dir"] as! String
  }
  
  func clear() {
    downloadDir = ""
    incompleteDir = ""
  }
}

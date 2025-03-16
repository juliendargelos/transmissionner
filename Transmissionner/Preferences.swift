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
  @Published var incompleteDirEnabled: Bool
  @Published var renamePartialFiles: Bool
  
  @Published var peerLimitGlobal: Int
  @Published var peerLimitPerTorrent: Int
  
  @Published var speedLimitDownEnabled: Bool
  @Published var speedLimitDown: Int
  @Published var speedLimitUpEnabled: Bool
  @Published var speedLimitUp: Int
  
  @Published var altSpeedDown: Int
  @Published var altSpeedUp: Int
  @Published var altSpeedEnabled: Bool
  
  @Published var downloadQueueSize: Int
  @Published var downloadQueueEnabled: Bool
  
  public var onFetch: ((_ complete: (() -> Void)?) -> Void)? = nil
  public var onPost: ((_ complete: (() -> Void)?) -> Void)? = nil
  
  init(
    downloadDir: String = "",
    incompleteDir: String = "",
    incompleteDirEnabled: Bool = false,
    renamePartialFiles: Bool = false,
    
    peerLimitGlobal: Int = 0,
    peerLimitPerTorrent: Int = 0,
    
    speedLimitDownEnabled: Bool = false,
    speedLimitDown: Int = 0,
    speedLimitUpEnabled: Bool = false,
    speedLimitUp: Int = 0,
    
    altSpeedDown: Int = 0,
    altSpeedUp: Int = 0,
    altSpeedEnabled: Bool = false,
    
    downloadQueueSize: Int = 0,
    downloadQueueEnabled: Bool = false
  ) {
    self.downloadDir = downloadDir
    self.incompleteDir = incompleteDir
    self.incompleteDirEnabled = incompleteDirEnabled
    self.renamePartialFiles = renamePartialFiles
    
    self.peerLimitGlobal = peerLimitGlobal
    self.peerLimitPerTorrent = peerLimitPerTorrent
    
    self.speedLimitDownEnabled = speedLimitDownEnabled
    self.speedLimitDown = speedLimitDown
    self.speedLimitUpEnabled = speedLimitUpEnabled
    self.speedLimitUp = speedLimitUp
    
    self.altSpeedDown = altSpeedDown
    self.altSpeedUp = altSpeedUp
    self.altSpeedEnabled = altSpeedEnabled
    
    self.downloadQueueSize = downloadQueueSize
    self.downloadQueueEnabled = downloadQueueEnabled
  }
  
  func update(preferences: [String: Any]) {
    downloadDir = preferences["download-dir"] as! String
    incompleteDir = preferences["incomplete-dir"] as! String
    incompleteDirEnabled = preferences["incomplete-dir-enabled"] as! Bool
    renamePartialFiles = preferences["rename-partial-files"] as! Bool
    
    peerLimitGlobal = preferences["peer-limit-global"] as! Int
    peerLimitPerTorrent = preferences["peer-limit-per-torrent"] as! Int
    
    speedLimitDownEnabled = preferences["speed-limit-down-enabled"] as! Bool
    speedLimitDown = preferences["speed-limit-down"] as! Int
    speedLimitUpEnabled = preferences["speed-limit-up-enabled"] as! Bool
    speedLimitUp = preferences["speed-limit-up"] as! Int
    
    altSpeedDown = preferences["alt-speed-down"] as! Int
    altSpeedUp = preferences["alt-speed-up"] as! Int
    altSpeedEnabled = preferences["alt-speed-enabled"] as! Bool
    
    downloadQueueSize = preferences["download-queue-size"] as! Int
    downloadQueueEnabled = preferences["download-queue-enabled"] as! Bool
  }
  
  func clear() {
    downloadDir = ""
    incompleteDir = ""
    incompleteDirEnabled = false
    renamePartialFiles = false
    
    peerLimitGlobal = 0
    peerLimitPerTorrent = 0
    
    speedLimitDownEnabled = false
    speedLimitDown = 0
    speedLimitUpEnabled = false
    speedLimitUp = 0
    
    altSpeedDown = 0
    altSpeedUp = 0
    altSpeedEnabled = false
    
    downloadQueueSize = 0
    downloadQueueEnabled = false
  }
  
  func post(_ complete: (() -> Void)? = nil) {
    onPost?(complete)
  }
  
  func fetch(_ complete: (() -> Void)? = nil) {
    onFetch?(complete)
  }
}


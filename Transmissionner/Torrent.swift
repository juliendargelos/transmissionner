//
//  Torrent.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 17/03/2024.
//

import Foundation
import SwiftUI

enum TorrentStatus: Int {
  case stopped = 0
  case checkWait = 1
  case check = 2
  case downloadWait = 3
  case download = 4
  case seedWait = 5
  case seed = 6
}

enum TorrentRatioLimitMode: Int {
  case global = 0
  case single = 1
  case unlimited = 2
}

enum TorrentIdleLimitMode: Int {
  case global = 0
  case single = 1
  case unlimited = 2
}

class Torrent: Identifiable, ObservableObject {
  @Published var id: Int
  @Published var name: String
  @Published var queuePosition: Int
  @Published var downloadDir: String
  @Published var error: Int
  @Published var errorString: String
  @Published var totalSize: Double
  @Published var percentComplete: Double
  @Published var rateDownload: Double
  @Published var rateUpload: Double
  @Published var eta: Double
  @Published var isFinished: Bool
  @Published var peersGettingFromUs: Int
  @Published var peersSendingToUs: Int
  @Published var status: TorrentStatus
  @Published var files: TorrentFileList
  
  @Published var peerLimit: Int
  @Published var downloadLimit: Int
  @Published var downloadLimited: Bool
  @Published var uploadLimit: Int
  @Published var uploadLimited: Bool
  @Published var honorsSessionLimits: Bool
  @Published var seedIdleLimit: Int
  @Published var seedIdleMode: TorrentIdleLimitMode
  @Published var seedRatioLimit: Float
  @Published var seedRatioMode: TorrentRatioLimitMode
  
  public var onStart: (() -> Void)? = nil
  public var onStop: (() -> Void)? = nil
  public var onPost: ((_: (() -> Void)?) -> Void)? = nil
  public var onRemove: ((_: Bool) -> Void)? = nil
  
  var sizeComplete: Double {
    get { totalSize * percentComplete }
  }
  
  var isStopped: Bool {
    get { status == TorrentStatus.stopped }
  }
  
  var isPreparing: Bool {
    get { !isStopped && status.rawValue < 4 }
  }
  
  var hasError: Bool {
    get { error != 0 }
  }
  
  var isComplete: Bool {
    get { isFinished || percentComplete == 1 }
  }
  
  init(
    id: Int = -1,
    name: String = "",
    queuePosition: Int = -1,
    downloadDir: String = "",
    error: Int = 0,
    errorString: String = "",
    totalSize: Double = 0,
    percentComplete: Double = 0,
    rateDownload: Double = 0,
    rateUpload: Double = 0,
    eta: Double = -1,
    isFinished: Bool = false,
    peersGettingFromUs: Int = 0,
    peersSendingToUs: Int = 0,
    status: TorrentStatus = TorrentStatus.stopped,
    files: TorrentFileList = TorrentFileList(),
    
    peerLimit: Int = 0,
    downloadLimit: Int = 0,
    downloadLimited: Bool = false,
    uploadLimit: Int = 0,
    uploadLimited: Bool = false,
    honorsSessionLimits: Bool = false,
    seedIdleLimit: Int = 0,
    seedIdleMode: TorrentIdleLimitMode = .global,
    seedRatioLimit: Float = 0,
    seedRatioMode: TorrentRatioLimitMode = .global
  ) {
    self.id = id
    self.name = name
    self.queuePosition = queuePosition
    self.downloadDir = downloadDir
    self.error = error
    self.errorString = errorString
    self.totalSize = totalSize
    self.percentComplete = percentComplete
    self.rateDownload = rateDownload
    self.rateUpload = rateUpload
    self.eta = eta
    self.isFinished = isFinished
    self.peersGettingFromUs = peersGettingFromUs
    self.peersSendingToUs = peersSendingToUs
    self.status = status
    self.files = files
    
    self.peerLimit = peerLimit
    self.downloadLimit = downloadLimit
    self.downloadLimited = downloadLimited
    self.uploadLimit = uploadLimit
    self.uploadLimited = uploadLimited
    self.honorsSessionLimits = honorsSessionLimits
    self.seedIdleLimit = seedIdleLimit
    self.seedIdleMode = seedIdleMode
    self.seedRatioLimit = seedRatioLimit
    self.seedRatioMode = seedRatioMode
  }
  
  func update(torrent: [String: Any]) {
    id = torrent["id"] as! Int
    name = torrent["name"] as! String
    queuePosition = torrent["queuePosition"] as! Int
    downloadDir = torrent["downloadDir"] as! String
    error = torrent["error"] as! Int
    errorString = torrent["errorString"] as! String
    totalSize = torrent["totalSize"] as! Double
    percentComplete = torrent["percentComplete"] as! Double
    rateDownload = torrent["rateDownload"] as! Double
    rateUpload = torrent["rateUpload"] as! Double
    eta = torrent["eta"] as! Double
    isFinished = torrent["isFinished"] as! Bool
    peersGettingFromUs = torrent["peersGettingFromUs"] as! Int
    peersSendingToUs = torrent["peersSendingToUs"] as! Int
    status = TorrentStatus(rawValue: torrent["status"] as! Int)!
    files.update(items: torrent["files"] as! [[String: Any]], in: torrent)
    
    peerLimit = torrent["peer-limit"] as! Int
    downloadLimit = torrent["downloadLimit"] as! Int
    downloadLimited = torrent["downloadLimited"] as! Bool
    uploadLimit = torrent["uploadLimit"] as! Int
    uploadLimited = torrent["uploadLimited"] as! Bool
    honorsSessionLimits = torrent["honorsSessionLimits"] as! Bool
    seedIdleLimit = torrent["seedIdleLimit"] as! Int
    seedIdleMode = TorrentIdleLimitMode(rawValue: torrent["seedIdleMode"] as! Int) ?? .global
    seedRatioLimit = torrent["seedRatioLimit"] as! Float
    seedRatioMode = TorrentRatioLimitMode(rawValue: torrent["seedRatioMode"] as! Int) ?? .global
  }
  
  func start() {
    status = TorrentStatus.download
    onStart?()
  }
  
  func stop() {
    status = TorrentStatus.stopped
    onStop?()
  }
  
  func post(_ complete: (() -> Void)? = nil) {
    onPost?(complete)
  }
  
  func remove(deleteFiles: Bool = false) {
    onRemove?(deleteFiles)
  }
}

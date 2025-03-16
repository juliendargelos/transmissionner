//
//  Client.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 13/03/2024.
//

import Foundation
import SwiftUI

class Client: ObservableObject {
  var connection: Connection?
  var sessionId: String = ""
  @Published var torrents: TorrentList = TorrentList()
  @Published var preferences: Preferences = Preferences()
  @Published var canStartAll: Bool = false
  @Published var canStopAll: Bool = false
  
  private var updateTimer: Timer?
  private var updating: Bool = false
  
  init(connection: Connection? = nil) {
    self.connection = connection
    self.torrents.onReorder = self.onTorrentListReorder
    self.torrents.onStart = self.onTorrentListStartAll
    self.torrents.onStop = self.onTorrentListStopAll
    self.torrents.onTorrentStart = self.onTorrentListStart
    self.torrents.onTorrentStop = self.onTorrentListStop
    self.torrents.onTorrentRemove = self.onTorrentListRemove
    self.torrents.onTorrentPost = self.onTorrentListPost
    
    self.preferences.onPost = self.onPreferencesPost
    self.preferences.onFetch = self.onPreferencesFetch
  }
  
  var scheme: String {
    get {
      return connection?.ssl == true ? "https" : "http"
    }
  }
  
  var url: URL? {
    get {
      if connection == nil {
        return nil
      }
      
      let path = connection!.path.first == "/" ? connection!.path : "/\(connection!.path)"
      return URL(string: "\(scheme)://\(connection!.hostname):\(connection!.port)\(path)")!
    }
  }
  
  var authorization: String? {
    get {
      if connection == nil {
        return nil
      }
      
      if (connection!.username != nil) {
        let password = connection!.password != nil ? connection!.password! : ""
        return "Basic \(Data("\(connection!.username!):\(password)".utf8).base64EncodedString())"
      } else {
        return nil
      }
    }
  }
  
  var headers: [String: String] {
    get {
      var headers: [String: String] = [
        "Accept": "application/json",
        "Content-Type": "application/json",
        "X-Transmission-Session-Id": sessionId
      ]
      
      if (authorization != nil) {
        headers["Authorization"] = authorization
      }
      
      return headers
    }
  }
  
  func enableSync() {
    if updateTimer != nil {
      return
    }
    
    if (connection == nil) {
      return
    }
    
    updating = true
    fetchTorrents { self.updating = false }
    
    updateTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(connection!.updateInterval), repeats: true) { timer in
      if self.connection == nil {
        self.disconnect()
        return
      }
      
      if self.updating {
        return
      }
      
      var loading = 2
      
      let complete = {
        loading -= 1
        if loading <= 0 {
          self.updating = false
        }
      }

      self.updating = true
      self.fetchTorrents(complete)
      self.fetchPreferences(complete)
    }
  }
  
  func disableSync() {
    if updateTimer == nil {
      return
    }
    
    updateTimer!.invalidate()
    updateTimer = nil
  }
  
  func disconnect() {
    disableSync()
    connection = nil
    sessionId = ""
    canStartAll = false
    canStopAll = false
    torrents.clear()
  }
  
  func set(connection: Connection?) {
    self.disconnect()
    
    if (connection == nil) {
      return
    }
    
    self.connection = connection
    self.enableSync()
  }
  
  func fetch(_ complete: (() -> Void)? = nil) {
    var torrentsCompleted = false
    var preferencesCompleted = false
    
    fetchTorrents {
      if preferencesCompleted {
        complete?()
      } else {
        torrentsCompleted = true
      }
    }
    
    fetchPreferences {
      if torrentsCompleted {
        complete?()
      } else {
        preferencesCompleted = true
      }
    }
  }
  
  func addTorrentFile(url: URL) {
    do {
      let data = try Data.init(contentsOf: url)
      let base64Data = data.base64EncodedString()
      
      post(
        method: "torrent-add",
        arguments: [
          "metainfo": base64Data
        ]
      )
    } catch {
      print("error")
      print(error.localizedDescription)
    }
  }
  
  func fetchTorrents(_ complete: (() -> Void)? = nil) {
    post(
      method: "torrent-get",
      arguments: [
        "fields": [
          "id",
          "name",
          "status",
          "error",
          "errorString",
          "totalSize",
          "eta",
          "isFinished",
          "peersGettingFromUs",
          "peersSendingToUs",
          "rateDownload",
          "rateUpload",
          "eta",
          "percentComplete",
          "queuePosition",
          "downloadDir",
          "uploadRatio",
          "files",
          
          "wanted",
          "priorities",
          "peer-limit",
          "downloadLimit",
          "downloadLimited",
          "uploadLimit",
          "uploadLimited",
          "honorsSessionLimits",
          "seedIdleLimit",
          "seedIdleMode",
          "seedRatioLimit",
          "seedRatioMode"
        ]
      ],
      complete: { data, response, error in
        if (error != nil) {
          print("Error: \(error!)")
          return
        }
        
        if (response!.statusCode != 200) {
          print("Error: \(response!.statusCode)")
          return
        }
        
        let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
        let arguments = json["arguments"] as! [String: Any]
        let torrents = arguments["torrents"] as! [[String: Any]]
        
        self.torrents.update(items: torrents)
        
        self.updateCanStartStopAll()
        
        complete?()
      }
    )
  }
  
  func fetchPreferences(_ complete: (() -> Void)? = nil) {
    post(
      method: "session-get",
      arguments: [
        "fields": [
          "download-dir",
          "incomplete-dir",
          "incomplete-dir-enabled",
          "rename-partial-files",
          "peer-limit-global",
          "peer-limit-per-torrent",
          "speed-limit-down-enabled",
          "speed-limit-down",
          "speed-limit-up-enabled",
          "speed-limit-up",
          "alt-speed-down",
          "alt-speed-up",
          "alt-speed-enabled",
          "download-queue-size",
          "download-queue-enabled"
        ]
      ],
      complete: { data, response, error in
        if (error != nil) {
          print("Error: \(error!)")
          if data != nil {
            print(String(decoding: data!, as: UTF8.self))
          }
          return
        }
        
        if (response!.statusCode != 200) {
          print("Error: \(response!.statusCode)")
          if data != nil {
            print(String(decoding: data!, as: UTF8.self))
          }
          return
        }
        
        let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
        let arguments = json["arguments"] as! [String: Any]
                
        self.preferences.update(preferences: arguments)
        complete?()
      }
    )
  }
  
  func postPreferences(_ complete: (() -> Void)? = nil) {
    post(
      method: "session-set",
      arguments: [
        "download-dir": preferences.downloadDir,
        "incomplete-dir": preferences.incompleteDir,
        "incomplete-dir-enabled": preferences.incompleteDirEnabled,
        "rename-partial-files": preferences.renamePartialFiles,
        "peer-limit-global": preferences.peerLimitGlobal,
        "peer-limit-per-torrent": preferences.peerLimitPerTorrent,
        "speed-limit-down-enabled": preferences.speedLimitDownEnabled,
        "speed-limit-down": preferences.speedLimitDown,
        "speed-limit-up-enabled": preferences.speedLimitUpEnabled,
        "speed-limit-up": preferences.speedLimitUp,
        "alt-speed-down": preferences.altSpeedDown,
        "alt-speed-up": preferences.altSpeedUp,
        "alt-speed-enabled": preferences.altSpeedEnabled,
        "download-queue-size": preferences.downloadQueueSize,
        "download-queue-enabled": preferences.downloadQueueEnabled
      ],
      complete: { data, response, error in
        complete?()
      }
    )
  }
  
  func post(
    method: String,
    arguments: [String: Any]?,
    complete: ((_: Data?, _: HTTPURLResponse?, _: Error?) -> Void)? = nil
  ) {
    if connection == nil {
      return
    }
    
    var request = URLRequest(url: url!)
    request.httpMethod = "post"
    request.allHTTPHeaderFields = headers
        
    var data: [String: Any] = [
      "method": method
    ]
    
    if (arguments != nil) {
      data["arguments"] = arguments
    }
    
    request.httpBody = try! JSONSerialization.data(withJSONObject: data, options: [])
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if ((response as! HTTPURLResponse?)?.statusCode == 409) {
        self.sessionId = (response as! HTTPURLResponse).allHeaderFields["X-Transmission-Session-Id"] as! String
        request.setValue(self.sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          DispatchQueue.main.async {
            complete?(data, response as! HTTPURLResponse?, error)
          }
        }
        
        task.resume()
      } else {
        DispatchQueue.main.async {
          complete?(data, response as! HTTPURLResponse?, error)
        }
      }
    }
    
    task.resume()
  }
  
  private func updateCanStartStopAll() {
    self.canStartAll = self.torrents.items.count > 0 && self.torrents.items.filter({ torrent in torrent.status == .stopped }).count > 0
    self.canStopAll = self.torrents.items.count > 0 && self.torrents.items.filter({ torrent in torrent.status != .stopped }).count > 0
  }
  
  private func onTorrentListReorder() {
    for (_, torrent) in torrents.items.enumerated() {
      post(
        method: "torrent-set",
        arguments: [
          "ids": [torrent.id],
          "queuePosition": torrent.queuePosition
        ]
      )
    }
  }
  
  private func onTorrentListStart(id: Int) {
    self.canStopAll = true
    
    post(
      method: "torrent-start",
      arguments: [
        "ids": [id]
      ]
    )
  }
  
  private func onTorrentListStop(id: Int) {
    self.canStartAll = true
    
    post(
      method: "torrent-stop",
      arguments: [
        "ids": [id]
      ]
    )
  }
  
  private func onTorrentListRemove(id: Int, deleteFiles: Bool) {
    post(
      method: "torrent-remove",
      arguments: [
        "ids": [id],
        "delete-local-data": deleteFiles
      ]
    )
  }
  
  private func onTorrentListPost(torrent: Torrent, complete: (() -> Void)? = nil) {
    var priorityLow: [Int] = []
    var priorityNormal: [Int] = []
    var priorityHigh: [Int] = []
    var filesWanted: [Int] = []
    var filesUnwanted: [Int] = []
    
    var index = 0
    
    for file in torrent.files.items {
      switch file.priority {
        case .low:
          priorityLow.append(index)
          
        case .normal:
          priorityNormal.append(index)
        
        case .high:
          priorityHigh.append(index)
      }
      
      file.wanted ? filesWanted.append(index) : filesUnwanted.append(index)
      
      index += 1
    }
    
    print([
      "ids": torrent.id,
      "peer-limit": torrent.peerLimit,
      "downloadLimit": torrent.downloadLimit,
      "downloadLimited": torrent.downloadLimited,
      "uploadLimit": torrent.uploadLimit,
      "uploadLimited": torrent.uploadLimited,
      "honorsSessionLimits": torrent.honorsSessionLimits,
      "seedIdleLimit": torrent.seedIdleLimit,
      "seedIdleMode": torrent.seedIdleMode,
      "seedRatioLimit": torrent.seedRatioLimit,
      "seedRatioMode": torrent.seedRatioMode,
      "priority-low": priorityLow,
      "priority-normal": priorityNormal,
      "priority-high": priorityHigh,
      "files-wanted": filesWanted,
      "files-unwanted": filesUnwanted
    ])
    
    post(
      method: "torrent-set",
      arguments: [
        "ids": torrent.id,
        "peer-limit": torrent.peerLimit,
        "downloadLimit": torrent.downloadLimit,
        "downloadLimited": torrent.downloadLimited,
        "uploadLimit": torrent.uploadLimit,
        "uploadLimited": torrent.uploadLimited,
        "honorsSessionLimits": torrent.honorsSessionLimits,
        "seedIdleLimit": torrent.seedIdleLimit,
        "seedIdleMode": torrent.seedIdleMode.rawValue,
        "seedRatioLimit": torrent.seedRatioLimit,
        "seedRatioMode": torrent.seedRatioMode.rawValue,
        "priority-low": priorityLow,
        "priority-normal": priorityNormal,
        "priority-high": priorityHigh,
        "files-wanted": filesWanted,
        "files-unwanted": filesUnwanted
      ],
      complete: { data, response, error in
        complete?()
      }
    )
  }
  
  private func onTorrentListStartAll() {
    if (torrents.items.count == 0) {
      return
    }
    
    self.canStartAll = false
    self.canStopAll = true
    
    post(
      method: "torrent-start",
      arguments: [
        "ids": torrents.items.map({ torrent in torrent.id })
      ]
    )
  }
  
  private func onTorrentListStopAll() {
    if (torrents.items.count == 0) {
      return
    }
    
    self.canStopAll = false
    self.canStartAll = true
    
    post(
      method: "torrent-stop",
      arguments: [
        "ids": torrents.items.map({ torrent in torrent.id })
      ]
    )
  }
  
  private func onPreferencesPost(_ complete: (() -> Void)? = nil) {
    postPreferences(complete)
  }
  
  private func onPreferencesFetch(_ complete: (() -> Void)? = nil) {
    fetchPreferences(complete)
  }
}

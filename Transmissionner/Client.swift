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
  
  func set(connection: Connection?) {
    if updateTimer != nil {
      updateTimer!.invalidate()
    }
    
    self.connection = connection
    self.sessionId = ""
    self.canStartAll = false
    self.canStopAll = false
    self.torrents.clear()
    
    if (connection != nil) {
      self.updating = true
      self.fetchTorrents { self.updating = false }
      
      updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
        if self.connection == nil {
          self.updateTimer!.invalidate()
          self.updateTimer = nil
          self.sessionId = ""
          self.torrents.clear()
          return
        }
        
        if self.updating {
          return
        }
        
        self.updating = true
        self.fetchTorrents { self.updating = false }
      }
    }
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
          "files"
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
      arguments: nil,
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
    for (index, torrent) in torrents.items.enumerated() {
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
}

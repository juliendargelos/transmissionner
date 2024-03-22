//
//  Connection.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 13/03/2024.
//

import Foundation
import SwiftData

@Model
class Connection {
  var name: String
  var hostname: String
  var port: Int
  var path: String
  var ssl: Bool
  var lastUsed: Date
  @Attribute(.allowsCloudEncryption) var username: String?
  @Attribute(.allowsCloudEncryption) var password: String?
  
  init(
    name: String,
    hostname: String,
    port: Int = Connection.defaultPort,
    path: String = Connection.defaultPath,
    ssl: Bool = false,
    username: String? = nil,
    password: String? = nil
  ) {
    self.name = name
    self.hostname = hostname
    self.port = port
    self.path = path
    self.ssl = ssl
    self.username = username
    self.password = password
    self.lastUsed = Date()
  }
  
  func use() {
    lastUsed = Date()
  }
  
  static let defaultPort: Int = 9091
  static let defaultPath: String = "/transmission/rpc"
}

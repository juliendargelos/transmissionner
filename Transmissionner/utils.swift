//
//  utils.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 18/03/2024.
//

import Foundation

func formatBytes(_ bytes: Double) -> String {
  let units = ["ko", "Mo", "Go", "To", "Po"]
  var remainingBytes = bytes / 1000
  var unitIndex = 0
  
  while remainingBytes >= 1000 && unitIndex < units.count - 1 {
    remainingBytes /= 1000
    unitIndex += 1
  }
  
  return String(format: "%.2f %@", remainingBytes, units[unitIndex])
}

func formatDuration(_ duration: Double) -> String {
  let secondsInMinute = 60.0
  let secondsInHour = 3600.0
  let secondsInDay = 86400.0
    
  if duration >= secondsInDay * 3 {
    let days = Int(duration / secondsInDay)
    return "\(days) days"
  } else {
    let hours = Int(duration / secondsInHour)
    let minutes = Int((duration.truncatingRemainder(dividingBy: secondsInHour)) / secondsInMinute)
    let seconds = Int(duration.truncatingRemainder(dividingBy: secondsInMinute))
    
    var components: [String] = []
    if hours > 0 {
      components.append("\(hours)h")
    }
    
    if hours > 0 || minutes > 0 {
      components.append(String(format: "%02dmin", minutes))
    }
    
    components.append(String(format: "%02ds", seconds))
    
    return components.joined(separator: " ")
  }
}

func formatPercentage(_ percentage: Double) -> String {
  if (percentage == 1) {
    return "100%"
  } else {
    return "\(String(format: "%.2f", percentage * 100))%"
  }
}

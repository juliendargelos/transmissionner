//
//  UpdateIntervalFormatter.swift
//  Transmissionner
//
//  Created by Julien Dargelos on 28/09/2024.
//

import SwiftUI

extension NumberFormatter {
  static func integer(
    in range: ClosedRange<Int>? = nil,
    minimum: Int? = nil,
    maximum: Int? = nil,
    unit: String = ""
  ) -> Self {
    let formatter = Self()
    formatter.isLenient = true
    formatter.roundingMode = .halfUp
    formatter.roundingIncrement = 1
    formatter.allowsFloats = false
    formatter.maximumFractionDigits = 0
    if range != nil {
      formatter.minimum = NSNumber(value: range!.lowerBound)
      formatter.maximum = NSNumber(value: range!.upperBound)
    } else {
      formatter.minimum = minimum == nil ? nil : NSNumber(value: minimum!)
      formatter.maximum = maximum == nil ? nil : NSNumber(value: maximum!)
    }
    formatter.numberStyle = .currency
    formatter.currencySymbol = unit
    formatter.locale = Locale(identifier: "fr_FR_POSIX")

    return formatter
  }
  
  static func float(
    in range: ClosedRange<Float>? = nil,
    minimum: Float? = nil,
    maximum: Float? = nil,
    step: Float? = 0.1,
    unit: String = ""
  ) -> Self {
    let formatter = Self()
    formatter.isLenient = true
    formatter.roundingMode = .halfUp
    formatter.roundingIncrement = step == nil ? nil : NSNumber(value: step!)
    formatter.allowsFloats = true
    formatter.maximumFractionDigits = Int(ceil(-min(0, log10(step ?? 0.1))))
    if range != nil {
      formatter.minimum = NSNumber(value: range!.lowerBound)
      formatter.maximum = NSNumber(value: range!.upperBound)
    } else {
      formatter.minimum = minimum == nil ? nil : NSNumber(value: minimum!)
      formatter.maximum = maximum == nil ? nil : NSNumber(value: maximum!)
    }
    formatter.numberStyle = .currency
    formatter.currencySymbol = unit
    formatter.locale = Locale(identifier: "fr_FR_POSIX")

    return formatter
  }
}

// class UpdateIntervalFormatter: NumberFormatter, @unchecked Sendable {
//   required init?(coder: NSCoder) {
//     super.init(coder: coder)
//     self.roundingMode = .toNearestOrAwayFromZero
//     self.roundingIncrement = 1
//     self.@
//   }
// }

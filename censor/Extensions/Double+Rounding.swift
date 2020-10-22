//
//  Double+Rounding.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import Foundation

extension Double {
  
  /// Round number and convert it to string
  /// - Parameters:
  ///   - symbolsAfter: amount of symbols after dot (example: 1.0 -> 1.000)
  ///   - symbolsBefore: amount of symbols before actual number (example: 1.0 -> 001)
  ///   - absolute: if true, absolute value is used (example: -1.0 -> 1.0)
  ///   - toLessValue: if true, number is rounded to smaller value (example: 4.89 -> 4.8)
  ///   - separator: decimal separator (example: 1.0 -> 1,0)
  func roundedString(symbolsAfter: Int,
                     symbolsBefore: Int = 0,
                     absolute: Bool = false,
                     toLessValue: Bool = false,
                     separator: String = ".") -> String {
    var number = self
    
    if absolute {
      number = abs(number)
    }
    
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.decimalSeparator = separator
    numberFormatter.roundingMode = toLessValue ? .down : .halfEven
    numberFormatter.minimumFractionDigits = symbolsAfter
    numberFormatter.maximumFractionDigits = symbolsAfter

    let outputString = numberFormatter.string(from: NSNumber(value: number)) ?? String(number)
    if symbolsBefore == 0 || outputString.count >= symbolsBefore {
      return outputString
    } else {
      return String(repeating: "0", count: symbolsBefore - outputString.count) + outputString
    }
  }
  
  func rounded(to symbols: Int = 0) -> Double {
    guard symbols != 0 else { return Double(Int(self)) }
    let divisor = pow(10.0, Double(symbols))
    return (self * divisor).rounded() / divisor
  }
}

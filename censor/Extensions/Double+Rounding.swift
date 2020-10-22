//
//  Double+Rounding.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import Foundation

extension Double {
  
  /// Округление числа и его конвертация в строку
  /// - Parameters:
  ///   - symbolsAfter: кол-во символов после точки
  ///   - symbolsBefore: кол-во символов перед числом (например, 1 -> 01)
  ///   - absolute: если true, то берется модуль числа
  ///   - toLessValue: если true, то число округляется в меньшую сторону (например, 4.89 -> 4.8)
  ///   - separator: разделитель целой и дробной части
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

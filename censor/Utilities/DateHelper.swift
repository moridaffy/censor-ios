//
//  DateHelper.swift
//  censor
//
//  Created by Maxim Skryabin on 24.10.2020.
//

import Foundation

class DateHelper {
  
  static let shared = DateHelper()
  
  func getString(from date: Date, of format: DateFormat) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format.format
    return formatter.string(from: date)
  }
  
  func getDate(from string: String, of format: DateFormat) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = format.format
    return formatter.date(from: string)
  }
  
  func getString(from fromString: String, of fromFormat: DateFormat, to toFormat: DateFormat) -> String? {
    guard let date = getDate(from: fromString, of: fromFormat) else { return nil }
    return getString(from: date, of: toFormat)
  }
  
}

extension DateHelper {
  enum DateFormat {
    case full
    case humanTimeDate
    
    var format: String {
      switch self {
      case .full:
        return "yyyy-MM-dd'T'HH:mm:ss"
      case .humanTimeDate:
        return "dd.MM.yyyy HH:mm"
      }
    }
  }
}

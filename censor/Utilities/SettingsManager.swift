//
//  SettingsManager.swift
//  censor
//
//  Created by Maxim Skryabin on 05.12.2020.
//

import Foundation

class SettingsManager {
  
  static let shared = SettingsManager()
  
  private let keyPrefix: String = {
    return (Bundle.main.bundleIdentifier ?? "ru.mskr.censor") + ".settings."
  }()
  
  func getValue<T>(of type: T.Type, for key: SettingKey) -> T? {
    return UserDefaults.standard.value(forKey: keyPrefix + key.rawValue) as? T
  }
  
  func setValue(for key: SettingKey, value: Any) {
    UserDefaults.standard.set(value, forKey: keyPrefix + key.rawValue)
  }
  
}

extension SettingsManager {
  enum SettingKey: String {
    case coachMarkersDisplayed
  }
}


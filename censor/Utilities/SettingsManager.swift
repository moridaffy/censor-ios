//
//  SettingsManager.swift
//  censor
//
//  Created by Maxim Skryabin on 05.12.2020.
//

import UIKit

class SettingsManager {
  
  static let shared = SettingsManager()
  
  var isIpad: Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
  }
  
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


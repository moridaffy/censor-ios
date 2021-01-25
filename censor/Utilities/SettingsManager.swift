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
  
  var isPremiumFeaturesUnlocked: Bool {
    get {
      return getValue(of: Bool.self, for: .anyTipPurchased) ?? false
    }
    set {
      setValue(for: .anyTipPurchased, value: true)
    }
  }
  
  // MARK: - Private
  
  private let keyPrefix: String = {
    return (Bundle.main.bundleIdentifier ?? "ru.mskr.censor") + ".settings."
  }()
  
  // MARK: - Custom icons
  
  var isCustomIconsSupported: Bool {
    return UIApplication.shared.supportsAlternateIcons
  }
  
  var currentIcon: AppIconType {
    return AppIconType.getIconType(for: UIApplication.shared.alternateIconName)
  }
  
  func setCustomIcon(_ iconType: AppIconType) {
    guard isCustomIconsSupported,
          iconType != currentIcon else { return }
    UIApplication.shared.setAlternateIconName(iconType.iconName, completionHandler: nil)
  }
  
  // MARK: - UserDefaults
  
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
    case anyTipPurchased
  }
  
  enum AppIconType: Equatable {
    
    static let allCases: [AppIconType] = [.blackColor, .blackBw, .whiteColor, .whiteBw]
    
    static func getIconType(for key: String?) -> AppIconType {
      switch key {
      case "black-bw":
        return .blackBw
      case "white-color":
        return .whiteColor
      case "white-bw":
        return .whiteBw
      default:
        return .blackColor
      }
    }
    
    case blackColor
    case blackBw
    case whiteColor
    case whiteBw
    
    var iconName: String? {
      switch self {
      case .blackColor:
        return nil
      case .blackBw:
        return "black-bw"
      case .whiteColor:
        return "white-color"
      case .whiteBw:
        return "white-bw"
      }
    }
    
    var previewImage: UIImage? {
        switch self {
        case .blackColor:
          return UIImage(imageLiteralResourceName: "appicon_black_color@3x.png")
        case .blackBw:
          return UIImage(imageLiteralResourceName: "appicon_black_bw@3x.png")
        case .whiteColor:
          return UIImage(imageLiteralResourceName: "appicon_white_color@3x.png")
        case .whiteBw:
          return UIImage(imageLiteralResourceName: "appicon_white_bw@3x.png")
        }
      }
  }
}


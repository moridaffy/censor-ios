//
//  SettingsManager.swift
//  censor
//
//  Created by Maxim Skryabin on 05.12.2020.
//

import AVKit
import UIKit

class SettingsManager {
  
  static let shared = SettingsManager()
  
  // MARK: - Properties
  
  var isIpad: Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
  }
  
  var isSmallScreen: Bool {
    return UIScreen.main.bounds.height < 600.0
  }
  
  var isPremiumFeaturesUnlocked: Bool {
    get {
      return getValue(of: Bool.self, for: .anyTipPurchased) ?? false
    }
    set {
      setValue(for: .anyTipPurchased, value: true)
    }
  }
  
  var isCustomIconsSupported: Bool {
    return UIApplication.shared.supportsAlternateIcons
  }
  
  var currentIcon: AppIconType {
    return AppIconType.getIconType(for: UIApplication.shared.alternateIconName)
  }
  
  var languageCode: String = "" {
    didSet {
      guard oldValue != "" else { return }
      setValue(for: .languageCode, value: languageCode)
    }
  }
  
  // MARK: - Private methods
  
  private init() {
    updateLanguageCode()
    updateSilentAudioPlayback()
  }
  
  private let keyPrefix: String = {
    return (Bundle.main.bundleIdentifier ?? "ru.mskr.censor") + ".settings."
  }()
  
  private func updateLanguageCode() {
    let storedLanguageCode = getValue(of: String.self, for: .languageCode)
    if let storedLanguageCode = storedLanguageCode, !storedLanguageCode.isEmpty {
      self.languageCode = storedLanguageCode
    } else if let systemLanguageCode = Locale.current.languageCode,
              let language = LocalizeSystem.Language.allCases.first(where: { $0.languageCode == systemLanguageCode }) {
      self.languageCode = language.languageCode
    } else {
      self.languageCode = "en"
    }
  }
  
  // MARK: - Public methods
  
  func setCustomIcon(_ iconType: AppIconType) {
    guard isCustomIconsSupported,
          iconType != currentIcon else { return }
    UIApplication.shared.setAlternateIconName(iconType.iconName, completionHandler: nil)
  }
  
  func getValue<T>(of type: T.Type, for key: SettingKey) -> T? {
    return UserDefaults.standard.value(forKey: keyPrefix + key.key) as? T
  }
  
  func setValue(for key: SettingKey, value: Any) {
    UserDefaults.standard.set(value, forKey: keyPrefix + key.key)
  }
  
  func updateSilentAudioPlayback(_ value: Bool? = nil) {
    let playSoundWhileSilenced = value ?? getValue(of: Bool.self, for: .playSoundWhileSilenced) ?? false
    do {
      try AVAudioSession.sharedInstance().setCategory(playSoundWhileSilenced ? .playback : .ambient)
    } catch let error {
      print("🔥 Failed to switch AVAudioSession category: \(error.localizedDescription)")
    }
  }
}

extension SettingsManager {
  enum SettingKey: String {
    case coachMarkersDisplayed
    case anyTipPurchased
    case languageCode
    case playSoundWhileSilenced
    
    var key: String {
      switch self {
      case .anyTipPurchased:
        return rawValue + "_debug"
      default:
        return rawValue
      }
    }
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


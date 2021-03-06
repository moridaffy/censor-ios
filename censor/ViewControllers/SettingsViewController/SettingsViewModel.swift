//
//  SettingsViewModel.swift
//  censor
//
//  Created by Maxim Skryabin on 26.10.2020.
//

import Foundation

class SettingsViewModel {
  
  let sections: [SectionType] = {
//    #if DEBUG
    return SectionType.debugAllCases
//    #else
//    return SectionType.allCases
//    #endif
  }()
  
  weak var view: SettingsViewController?
  
  private var iapPrices: [IAPManager.IAPType: String] = [:] {
    didSet {
      view?.reloadTableView()
    }
  }
  
  init() {
    loadTipPrices()
  }
  
  private func loadTipPrices() {
    IAPManager.shared.requestPurchasePrices { [weak self] (error, prices) in
      guard let prices = prices else { return }
      self?.iapPrices = prices
    }
  }
  
  func getCellModel(at indexPath: IndexPath) -> Any? {
    switch sections[indexPath.section] {
    case .icon:
      switch indexPath.row {
      case 0:
        return SettingsTitleTableViewCellModel(title: LocalizeSystem.shared.settings(.iconTitle))
      case 1:
        return SettingsIconsTableViewCellModel()
      default:
        return nil
      }
    case .language:
      switch indexPath.row {
      case 0:
        return SettingsTitleTableViewCellModel(title: LocalizeSystem.shared.settings(.languageTitle))
      case 1:
        return SettingsLanguageTableViewCellModel()
      default:
        return nil
      }
    case .otherSettings:
      return SettingsSwitchTableViewCellModel(type: .playSoundWhileSilenced, value: SettingsManager.shared.getValue(of: Bool.self, for: .playSoundWhileSilenced) ?? false)
    case .tips:
      switch indexPath.row {
      case 0:
        return SettingsTitleTableViewCellModel(title: LocalizeSystem.shared.settings(.tipTitle))
      case 1:
        return SettingsTipsTableViewCellModel(iapPrices: iapPrices)
      case 2:
        return SettingsButtonTableViewCellModel(type: .restorePurchases)
      default:
        return nil
      }
    case .debug:
      switch indexPath.row {
      case 0:
        return SettingsButtonTableViewCellModel(type: .activateFeatures)
      case 1:
        return SettingsButtonTableViewCellModel(type: .deactivateFeatures)
      case 2:
        return SettingsButtonTableViewCellModel(type: .wipeData)
      default:
        return nil
      }
    }
  }
  
  func purchaseTip(_ tipType: SettingsTipsTableViewCellModel.TipType, completionHandler: @escaping (Error?, Bool) -> Void) {
    IAPManager.shared.requestPurchase(tipType.iapType, viewController: view, completionHandler: completionHandler)
  }
  
  func restoreTip(completionHandler: @escaping (Error?, Bool) -> Void) {
    IAPManager.shared.requestRestore(viewController: view, completionHandler: completionHandler)
  }
  
  func activatePremiumFeatures() {
    SettingsManager.shared.isPremiumFeaturesUnlocked = true
    NotificationCenter.default.post(name: .purchasedTip, object: nil, userInfo: nil)
  }
  
  func wipeProjectsData() {
    let storage = StorageManager.shared
    
    let projects = storage.getProjects()
    projects.forEach({ storage.deleteProject($0) })
  }
}

extension SettingsViewModel {
  enum SectionType: Int {
    
    static let allCases: [SectionType] = [.icon, .language, .otherSettings, .tips]
    static let debugAllCases: [SectionType] = [.icon, .language, .otherSettings, .tips, .debug]
    
    case icon = 1
    case language = 2
    case otherSettings = 3
    case tips = 4
    case debug = 5
    
    var numberOfRows: Int {
      switch self {
      case .icon:
        return 2
      case .language:
        return 2
      case .otherSettings:
        return 1
      case .tips:
        return 3
      case .debug:
        return 3
      }
    }
  }
  
  enum SwitchType {
    case playSoundWhileSilenced
    
    var title: String {
      switch self {
      case .playSoundWhileSilenced:
        return LocalizeSystem.shared.settings(.playSoundWhileSilent)
      }
    }
    
    var settingsKey: SettingsManager.SettingKey {
      switch self {
      case .playSoundWhileSilenced:
        return .playSoundWhileSilenced
      }
    }
  }
}

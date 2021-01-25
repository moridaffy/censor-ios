//
//  SettingsViewModel.swift
//  censor
//
//  Created by Maxim Skryabin on 26.10.2020.
//

import Foundation

class SettingsViewModel {
  
  let sections: [SectionType] = SectionType.allCases.sorted(by: { $0.rawValue < $1.rawValue })
  
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
        return SettingsTitleTableViewCellModel(title: "Select app icon")
      case 1:
        return SettingsIconsTableViewCellModel()
      default:
        return nil
      }
    case .tips:
      switch indexPath.row {
      case 0:
        return SettingsTitleTableViewCellModel(title: "Leave a tip")
      case 1:
        return SettingsTipsTableViewCellModel(iapPrices: iapPrices)
      case 2:
        return SettingsButtonTableViewCellModel(type: .restorePurchases)
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
}

extension SettingsViewModel {
  enum SectionType: Int, CaseIterable {
    case icon = 1
    case tips = 2
    
    var numberOfRows: Int {
      switch self {
      case .icon:
        return 2
      case .tips:
        return 3
      }
    }
  }
}

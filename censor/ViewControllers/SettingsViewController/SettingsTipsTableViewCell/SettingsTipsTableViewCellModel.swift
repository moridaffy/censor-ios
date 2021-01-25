//
//  SettingsTipsTableViewCellModel.swift
//  censor
//
//  Created by Maxim Skryabin on 26.10.2020.
//

import Foundation

class SettingsTipsTableViewCellModel {
  
  let iapPrices: [IAPManager.IAPType: String]
  
  init(iapPrices: [IAPManager.IAPType: String]) {
    self.iapPrices = iapPrices
  }
  
}

extension SettingsTipsTableViewCellModel {
  enum TipType: Int {
    case small = 1
    case middle = 2
    case large = 3
    
    var iconName: String {
      switch self {
      case .small:
        return "icon_tip_small"
      case .middle:
        return "icon_tip_middle"
      case .large:
        return "icon_tip_large"
      }
    }
    
    var iapType: IAPManager.IAPType {
      switch self {
      case .small:
        return .smallTip
      case .middle:
        return .mediumTip
      case .large:
        return .largeTip
      }
    }
  }
}

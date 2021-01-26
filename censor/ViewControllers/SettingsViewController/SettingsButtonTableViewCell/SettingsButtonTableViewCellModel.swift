//
//  SettingsButtonTableViewCellModel.swift
//  censor
//
//  Created by Maxim Skryabin on 26.10.2020.
//

import Foundation

class SettingsButtonTableViewCellModel {
  
  let type: ButtonType
  
  init(type: ButtonType) {
    self.type = type
  }
  
}

extension SettingsButtonTableViewCellModel {
  enum ButtonType {
    case restorePurchases
    case activateFeatures
    case deactivateFeatures
    case wipeData
    
    var title: String {
      switch self {
      case .restorePurchases:
        return NSLocalizedString("Restore purchases", comment: "")
      case .activateFeatures:
        return NSLocalizedString("Activate premium features", comment: "")
      case .deactivateFeatures:
        return NSLocalizedString("Deactivate premium features", comment: "")
      case .wipeData:
        return NSLocalizedString("Wipe projects", comment: "")
      }
    }
  }
}

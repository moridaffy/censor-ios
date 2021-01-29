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
        return LocalizeSystem.shared.settings(.purchaseRestoreButton)
      case .activateFeatures:
        return LocalizeSystem.shared.settings(.premiumUnlockButton)
      case .deactivateFeatures:
        return LocalizeSystem.shared.settings(.premiumLockButton)
      case .wipeData:
        return LocalizeSystem.shared.settings(.projectsDeleteButton)
      }
    }
  }
}

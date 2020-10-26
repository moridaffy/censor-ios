//
//  SettingsViewModel.swift
//  censor
//
//  Created by Maxim Skryabin on 26.10.2020.
//

import Foundation

class SettingsViewModel {
  
  let sections: [SectionType] = SectionType.allCases.sorted(by: { $0.rawValue < $1.rawValue })
  
  func getCellModel(at indexPath: IndexPath) -> Any? {
    switch sections[indexPath.section] {
//    case .theme:
//      switch indexPath.row {
//      case 0:
//        return SettingsTitleTableViewCellModel(title: "Select color theme")
//      case 1:
//        return nil
//      default:
//        return nil
//      }
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
        return SettingsTipsTableViewCellModel()
      case 2:
        return SettingsButtonTableViewCellModel(type: .restorePurchases)
      default:
        return nil
      }
    }
  }
}

extension SettingsViewModel {
  enum SectionType: Int, CaseIterable {
//    case theme = 0
    case icon = 1
    case tips = 2
    
    var numberOfRows: Int {
      switch self {
//      case .theme:
//        return 2
      case .icon:
        return 2
      case .tips:
        return 3
      }
    }
  }
}

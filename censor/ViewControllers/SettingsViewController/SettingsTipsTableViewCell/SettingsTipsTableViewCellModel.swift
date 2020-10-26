//
//  SettingsTipsTableViewCellModel.swift
//  censor
//
//  Created by Maxim Skryabin on 26.10.2020.
//

import Foundation

class SettingsTipsTableViewCellModel {
  
}

extension SettingsTipsTableViewCellModel {
  enum TipType: Int {
    case small = 1
    case middle = 2
    case large = 3
    
    var iconName: String {
      return "icon_coffee\(rawValue)"
    }
  }
}

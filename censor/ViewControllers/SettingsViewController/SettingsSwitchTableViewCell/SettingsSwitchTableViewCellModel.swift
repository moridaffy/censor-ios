//
//  SettingsSwitchTableViewCellModel.swift
//  censor
//
//  Created by Maxim Skryabin on 02.02.2021.
//

import Foundation

class SettingsSwitchTableViewCellModel {
  
  let type: SettingsViewModel.SwitchType
  var value: Bool
  
  init(type: SettingsViewModel.SwitchType, value: Bool) {
    self.type = type
    self.value = value
  }
  
}

//
//  SettingsLanguageTableViewCellModel.swift
//  censor
//
//  Created by Maxim Skryabin on 30.01.2021.
//

import Foundation

class SettingsLanguageTableViewCellModel {
  
  var currentLanguage: String {
    let languageCode = SettingsManager.shared.languageCode
    guard let language = LocalizeSystem.Language.allCases.first(where: { $0.languageCode == languageCode }) else { return "wrong code: \(languageCode)" }
    return language.title
  }
  
}

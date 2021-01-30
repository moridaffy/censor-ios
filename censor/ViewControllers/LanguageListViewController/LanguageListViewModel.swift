//
//  LanguageListViewModel.swift
//  censor
//
//  Created by Maxim Skryabin on 30.01.2021.
//

import Foundation

class LanguageListViewModel {
  
  var languages: [LocalizeSystem.Language] {
    return LocalizeSystem.Language.allCases
  }
  
  lazy var currentLanguage: LocalizeSystem.Language? = {
    let languageCode = SettingsManager.shared.languageCode
    if let language = languages.first(where: { $0.languageCode == languageCode }) {
      return language
    } else {
      print("🔥 Unknown language code received: \(languageCode)")
      return nil
    }
  }()
  
  func languageSelected(at row: Int) {
    let selectedLanguage = languages[row]
    guard selectedLanguage != currentLanguage else { return }
    
    currentLanguage = selectedLanguage
    LocalizeSystem.shared.updateLanguage(to: selectedLanguage)
  }
  
}

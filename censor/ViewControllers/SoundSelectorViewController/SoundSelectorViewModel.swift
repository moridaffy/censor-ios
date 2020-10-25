//
//  SoundSelectorViewModel.swift
//  censor
//
//  Created by Maxim Skryabin on 25.10.2020.
//

import Foundation

class SoundSelectorViewModel {
  
  var searchText: String = ""
  
  private let availableSoundTypes: [Sound.SoundType] = Sound.SoundType.allCasesSorted
  private(set) var displayedSoundTypes: [Sound.SoundType] = [] {
    didSet {
      view?.reloadTableView()
    }
  }
  
  weak var view: SoundSelectorViewController?
  
  init() {
    self.displayedSoundTypes = availableSoundTypes
  }
}

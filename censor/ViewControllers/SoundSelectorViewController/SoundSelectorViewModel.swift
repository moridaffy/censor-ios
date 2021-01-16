//
//  SoundSelectorViewModel.swift
//  censor
//
//  Created by Maxim Skryabin on 25.10.2020.
//

import Foundation

class SoundSelectorViewModel {
  
  var searchText: String = ""
  var currentlyPlayingSound: SoundManager.SoundType?
  
  private let availableSoundTypes: [SoundManager.SoundType] = SoundManager.shared.allSoundTypes
  private(set) var displayedSoundTypes: [SoundManager.SoundType] = [] {
    didSet {
      view?.reloadTableView()
    }
  }
  
  weak var view: SoundSelectorViewController?
  
  init() {
    updateDisplayedSoundTypes()
  }
  
  func updateDisplayedSoundTypes() {
    if searchText.isEmpty {
      displayedSoundTypes = availableSoundTypes
    } else {
      displayedSoundTypes = availableSoundTypes.filter({ $0.name.lowercased().contains(searchText.lowercased()) })
    }
  }
}

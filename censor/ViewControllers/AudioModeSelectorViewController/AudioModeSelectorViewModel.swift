//
//  AudioModeSelectorViewModel.swift
//  censor
//
//  Created by Maxim Skryabin on 27.01.2021.
//

import Foundation

class AudioModeSelectorViewModel {
  
  var selectedAudioMode: VideoRenderer.AudioMode
  
  init(audioMode: VideoRenderer.AudioMode) {
    self.selectedAudioMode = audioMode
  }
  
}

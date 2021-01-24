//
//  Sound.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import Foundation

struct Sound: Codable {
  let timestamp: Double
  let type: SoundManager.SoundType
  
  init(timestamp: Double, type: SoundManager.SoundType) {
    self.timestamp = timestamp
    self.type = type
  }
}

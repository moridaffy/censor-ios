//
//  SoundManager.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import AVFoundation

class SoundManager {
  
  static let shared = SoundManager()
  
  private var players: [String: AVAudioPlayer] = [:]
  private var lastActivePlayer: AVAudioPlayer?
  
  private func getPlayerFor(sound: Sound) -> AVAudioPlayer? {
    if let player = players[sound.type.filename] {
      return player
    } else if let player = try? AVAudioPlayer(contentsOf: sound.type.fileUrl) {
      players[sound.type.filename] = player
      return player
    } else {
      return nil
    }
  }
  
  func playSound(_ sound: Sound) {
    if let lastActivePlayer = lastActivePlayer {
      lastActivePlayer.stop()
    }
    lastActivePlayer = getPlayerFor(sound: sound)
    lastActivePlayer?.currentTime = 0.0
    lastActivePlayer?.play()
  }
  
}

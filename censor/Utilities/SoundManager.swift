//
//  SoundManager.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import AVFoundation

class SoundManager: NSObject {
  
  static let shared = SoundManager()
  
  private var players: [String: AVAudioPlayer] = [:]
  private var lastActivePlayer: AVAudioPlayer?
  
  private func getPlayerFor(soundType: Sound.SoundType) -> AVAudioPlayer? {
    if let player = players[soundType.filename] {
      return player
    } else if let player = try? AVAudioPlayer(contentsOf: soundType.fileUrl) {
      player.delegate = self
      players[soundType.filename] = player
      return player
    } else {
      return nil
    }
  }
  
  func playSound(_ soundType: Sound.SoundType) {
    if let lastActivePlayer = lastActivePlayer {
      lastActivePlayer.stop()
    }
    lastActivePlayer = getPlayerFor(soundType: soundType)
    lastActivePlayer?.currentTime = 0.0
    lastActivePlayer?.play()
  }
}

extension SoundManager: AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    NotificationCenter.default.post(name: .soundPlayerFinishedPlaying, object: nil, userInfo: nil)
  }
}

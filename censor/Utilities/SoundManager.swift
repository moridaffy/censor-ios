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
  
  private(set) var allSoundTypes: [SoundType] = []
  
  override init() {
    super.init()
    
    loadAllSounds()
  }
  
  private func loadAllSounds() {
    guard let soundsJsonUrl = Bundle.main.url(forResource: "sounds", withExtension: "json"),
          let soundsJsonData = try? Data(contentsOf: soundsJsonUrl),
          let sounds = try? JSONDecoder().decode([SoundType].self, from: soundsJsonData) else { fatalError() }
    self.allSoundTypes = sounds
  }
  
  private func getPlayerFor(soundType: SoundManager.SoundType) -> AVAudioPlayer? {
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
  
  func playSound(_ soundType: SoundManager.SoundType) {
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

extension SoundManager {
  class SoundType: Codable, Equatable {
    
    static func == (lhs: SoundType, rhs: SoundType) -> Bool {
      return lhs.filename == rhs.filename
    }
    
    let filename: String
    let name: String
    
    lazy var duration: Double = {
      let asset = AVAsset(url: fileUrl)
      return asset.duration.seconds
    }()
    
    required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.filename = try container.decode(String.self, forKey: .filename)
      self.name = try container.decode(String.self, forKey: .name)
    }
    
    var fileUrl: URL {
      let filenameComponents = filename
        .split(separator: ".")
        .compactMap({ String($0) })
      let path = Bundle.main.path(forResource: filenameComponents[0], ofType: filenameComponents[1])!
      return URL(fileURLWithPath: path)
    }
  }
}

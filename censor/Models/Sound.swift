//
//  Sound.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import Foundation

struct Sound {
  let timestamp: Double
  let type: SoundType
}

extension Sound {
  enum SoundType {
    case horn1
    case horn2
    
    var filename: String {
      switch self {
      case .horn1:
        return "horn_1.wav"
      case .horn2:
        return "horn_2.wav"
      }
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

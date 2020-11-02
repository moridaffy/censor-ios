//
//  Sound.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import Foundation

struct Sound: Codable {
  let timestamp: Double
  private let typeValue: String
  
  var type: SoundType {
    return SoundType(rawValue: typeValue) ?? .beep2sec
  }
  
  init(timestamp: Double, type: SoundType) {
    self.timestamp = timestamp
    self.typeValue = type.rawValue
  }
}

extension Sound {
  enum SoundType: String, CaseIterable {
    
    static var allCasesSorted: [SoundType] {
      return allCases.sorted(by: { $0.title < $1.title })
    }
    
    case beep2sec
    case beep1sec
    case beep05sec
    case beep025sec
    case carCrash1
    case carCrash2
    case carCrash3
    case carCrash4
    case carCrash5
    case carFastBreaking1
    case carFastBreaking2
    case carHorn1
    case carHorn2
    case explosion1
    case explosion2
    case explosion3
    
    var title: String {
      switch self {
      case .beep2sec:
        return "Censore beep (2 sec)"
      case .beep1sec:
        return "Censore beep (1 sec)"
      case .beep05sec:
        return "Censore beep (0.5 sec)"
      case .beep025sec:
        return "Censore beep (0.25 sec)"
      case .carCrash1:
        return "Car crash 1"
      case .carCrash2:
        return "Car crash 2"
      case .carCrash3:
        return "Car crash 3"
      case .carCrash4:
        return "Car crash 4"
      case .carCrash5:
        return "Car crash 5"
      case .carFastBreaking1:
        return "Car fast breaking 1"
      case .carFastBreaking2:
        return "Car fast breaking 2"
      case .carHorn1:
        return "Car horn 1"
      case .carHorn2:
        return "Car horn 2"
      case .explosion1:
        return "Explosion 1"
      case .explosion2:
        return "Explosion 2"
      case .explosion3:
        return "Explosion 3"
      }
    }
    
    var filename: String {
      switch self {
      case .beep2sec:
        return "beep_2sec.mp3"
      case .beep1sec:
        return "beep_1sec.mp3"
      case .beep05sec:
        return "beep_05sec.mp3"
      case .beep025sec:
        return "beep_025sec.mp3"
      case .carCrash1:
        return "car_crash_1.mp3"
      case .carCrash2:
        return "car_crash_2.mp3"
      case .carCrash3:
        return "car_crash_3.mp3"
      case .carCrash4:
        return "car_crash_4.mp3"
      case .carCrash5:
        return "car_crash_5.mp3"
      case .carFastBreaking1:
        return "car_fast_breaking_1.mp3"
      case .carFastBreaking2:
        return "car_fast_breaking_2.mp3"
      case .carHorn1:
        return "car_horn_1.mp3"
      case .carHorn2:
        return "car_horn_2.mp3"
      case .explosion1:
        return "explosion_1.mp3"
      case .explosion2:
        return "explosion_2.mp3"
      case .explosion3:
        return "explosion_3.mp3"
      }
    }
    
    var duration: Double {
      switch self {
      case .beep2sec:
        return 2.0
      case .beep1sec:
        return 1.0
      case .beep05sec:
        return 0.5
      case .beep025sec:
        return 0.25
      case .carCrash1:
        return 2.0
      case .carCrash2:
        return 3.0
      case .carCrash3:
        return 1.0
      case .carCrash4:
        return 3.0
      case .carCrash5:
        return 2.0
      case .carFastBreaking1:
        return 1.0
      case .carFastBreaking2:
        return 2.0
      case .carHorn1:
        return 2.0
      case .carHorn2:
        return 1.0
      case .explosion1:
        return 2.0
      case .explosion2:
        return 3.0
      case .explosion3:
        return 4.0
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

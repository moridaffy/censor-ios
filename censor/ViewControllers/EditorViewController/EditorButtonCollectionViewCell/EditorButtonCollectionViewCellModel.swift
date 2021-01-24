//
//  EditorButtonCollectionViewCellModel.swift
//  censor
//
//  Created by Maxim Skryabin on 02.11.2020.
//

import UIKit

class EditorButtonCollectionViewCellModel {
  
  let type: ButtonType
  var text: String
  
  init(type: ButtonType, text: String) {
    self.type = type
    self.text = text
  }
  
}

extension EditorButtonCollectionViewCellModel {
  enum ButtonType: Equatable {
    case audioMode(selectedMode: VideoRenderer.AudioMode)
    case soundSelection
    case export
    
    var icon: UIImage? {
      switch self {
      case .audioMode(let selectedMode):
        return UIImage(systemName: selectedMode.iconSystemName)
      case .soundSelection:
        return UIImage(systemName: "music.note")
      case .export:
        return UIImage(systemName: "square.and.arrow.up")
      }
    }
  }
}

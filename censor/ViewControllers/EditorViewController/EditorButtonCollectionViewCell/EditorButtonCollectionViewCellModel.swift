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
  enum ButtonType {
    case soundSelection
    case export
    
    var icon: UIImage? {
      switch self {
      case .soundSelection:
        return UIImage(systemName: "music.note")
      case .export:
        return UIImage(systemName: "square.and.arrow.up")
      }
    }
  }
}

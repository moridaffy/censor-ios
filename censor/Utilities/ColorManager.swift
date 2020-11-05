//
//  ColorManager.swift
//  censor
//
//  Created by Maxim Skryabin on 05.11.2020.
//

import UIKit

class ColorManager {
  
  static let shared = ColorManager()
  
  var isDarkModeEnabled: Bool {
    if RootViewController.shared.traitCollection.userInterfaceStyle == .dark {
      return true
    } else {
      return false
    }
  }
  
  var bottomBackground: UIColor {
    return isDarkModeEnabled
      ? UIColor(red: 0.114, green: 0.118, blue: 0.122, alpha: 1.000)
      : UIColor(red: 0.976, green: 0.976, blue: 0.976, alpha: 1.000)
  }
  
  var topBackground: UIColor {
    return isDarkModeEnabled
      ? UIColor(red: 0.180, green: 0.184, blue: 0.188, alpha: 1.000)
      : UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1.000)
  }
  
  var accent: UIColor {
    return isDarkModeEnabled
      ? UIColor(red: 0.553, green: 0.890, blue: 0.106, alpha: 1.000)
      : UIColor(red: 0.467, green: 0.788, blue: 0.039, alpha: 1.000)
  }
  
  var text: UIColor {
    return isDarkModeEnabled
      ? UIColor(red: 0.976, green: 0.976, blue: 0.976, alpha: 1.000)
      : UIColor(red: 0.180, green: 0.184, blue: 0.188, alpha: 1.000)
  }
  
  var subtext: UIColor {
    return isDarkModeEnabled
      ? UIColor(red: 0.502, green: 0.502, blue: 0.502, alpha: 1.000)
      : UIColor(red: 0.580, green: 0.580, blue: 0.580, alpha: 1.000)
  }
  
  var subtext50opacity: UIColor {
    return subtext.withAlphaComponent(0.5)
  }
  
  var subtext25opacity: UIColor {
    return subtext.withAlphaComponent(0.25)
  }
  
}

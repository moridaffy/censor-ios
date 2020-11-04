//
//  UIViewController+NavigaionController.swift
//  censor
//
//  Created by Maxim Skryabin on 20.10.2020.
//

import UIKit

extension UIViewController {
  func embedInNavigationController() -> DimmableNavigationController {
    return DimmableNavigationController(rootViewController: self)
  }
}

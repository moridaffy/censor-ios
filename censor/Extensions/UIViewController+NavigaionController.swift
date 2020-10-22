//
//  UIViewController+NavigaionController.swift
//  censor
//
//  Created by Maxim Skryabin on 20.10.2020.
//

import UIKit

extension UIViewController {
  func embedInNavigationController() -> UINavigationController {
    return UINavigationController(rootViewController: self)
  }
}

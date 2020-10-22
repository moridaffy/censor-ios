//
//  UINavigationController+CompletionHandler.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import UIKit

extension UINavigationController {

  func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    pushViewController(viewController, animated: animated)
    CATransaction.commit()
  }

}

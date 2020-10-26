//
//  UITableViewCell+Separator.swift
//  censor
//
//  Created by Maxim Skryabin on 26.10.2020.
//

import UIKit

extension UITableViewCell {
  func removeSeparator() {
    separatorInset = UIEdgeInsets(top: 0.0, left: UIScreen.main.bounds.width, bottom: 0.0, right: 0.0)
  }
}

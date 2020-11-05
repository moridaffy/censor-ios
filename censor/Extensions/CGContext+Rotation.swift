//
//  CGContext+Rotation.swift
//  censor
//
//  Created by Maxim Skryabin on 05.11.2020.
//

import CoreGraphics

extension CGContext {
  func rotate(with height: CGFloat) {
    translateBy(x: 0, y: height)
    scaleBy(x: 1.0, y: -1.0)
  }
}

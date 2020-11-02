//
//  UIView+Rendering.swift
//  censor
//
//  Created by Maxim Skryabin on 02.11.2020.
//

import UIKit

extension UIView {
  func toImage() -> UIImage {
      let renderer = UIGraphicsImageRenderer(size: bounds.size)
      let image = renderer.image { _ in
          drawHierarchy(in: bounds, afterScreenUpdates: true)
      }
      return image
  }
}

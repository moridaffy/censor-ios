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
  
  func addDashedBorder(ofColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
    let borderRect = CGRect(origin: .zero, size: bounds.size)
    let borderLayer = CAShapeLayer()
    borderLayer.path = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius).cgPath
    borderLayer.strokeColor = ofColor.cgColor
    borderLayer.lineDashPattern = [10, 7]
    borderLayer.lineWidth = borderWidth
    borderLayer.backgroundColor = UIColor.clear.cgColor
    borderLayer.fillColor = UIColor.clear.cgColor
    layer.addSublayer(borderLayer)
  }
}

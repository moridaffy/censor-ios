//
//  VideoTimelineSoundView.swift
//  censor
//
//  Created by Maxim Skryabin on 05.11.2020.
//

import UIKit

class VideoTimelineSoundView: UIView {
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.isUserInteractionEnabled = false
    return imageView
  }()
  
  init(index: Int) {
    super.init(frame: .zero)
    
    self.tag = index
    
    setupLayout()
    imageView.image = VideoTimelineSoundView.getImage(for: index)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayout() {
    addSubview(imageView)
    
    addConstraints([
      imageView.topAnchor.constraint(equalTo: topAnchor),
      imageView.leftAnchor.constraint(equalTo: leftAnchor),
      imageView.rightAnchor.constraint(equalTo: rightAnchor),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
}

extension VideoTimelineSoundView {
  
  private static let rendererFormat: UIGraphicsImageRendererFormat = {
      let format = UIGraphicsImageRendererFormat()
      format.scale = 3
      return format
  }()
  
  static let width: CGFloat = 33.0
  static let height: CGFloat = 40.0
  
  static func getImage(for index: Int) -> UIImage {
    
    let bounds = CGRect(origin: .zero,
                        size: CGSize(width: width, height: height))
    let renderer = UIGraphicsImageRenderer(size: bounds.size, format: rendererFormat)
    
    return renderer.image { (rendererContext) in
      
      let cgContext = rendererContext.cgContext
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .center
      paragraphStyle.lineBreakMode = .byTruncatingTail
      
      // Shape image
      let shapeImage = UIImage(named: "shape_sound_view")!
      let shapeRect = bounds
      ColorManager.shared.bottomBackground.setFill()
      
      cgContext.clip(to: shapeRect, mask: shapeImage.cgImage!)
      cgContext.fill(shapeRect)
      
      // Index text
      let indexRect = CGRect(origin: CGPoint(x: 0.0, y: height / 3.0),
                             size: CGSize(width: bounds.width, height: bounds.width))
      
      let indexString = NSAttributedString(string: String(index),
                                           attributes: [.paragraphStyle: paragraphStyle,
                                                        .font: UIFont.systemFont(ofSize: 16.0, weight: .semibold),
                                                        .foregroundColor: ColorManager.shared.accent])
      indexString.draw(in: indexRect)
    }
  }
}

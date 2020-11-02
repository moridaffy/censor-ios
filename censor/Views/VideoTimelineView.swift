//
//  VideoTimelineView.swift
//  censor
//
//  Created by Maxim Skryabin on 02.11.2020.
//

import UIKit

class VideoTimelineView: UIView {
  
  private let previewImagesContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 6.0
    view.layer.borderWidth = 2.0
    view.layer.borderColor = UIColor.white.cgColor
    
    view.backgroundColor = .red
    
    return view
  }()
  
  private lazy var previewImageView1: UIImageView = getImageView(tag: 1)
  private lazy var previewImageView2: UIImageView = getImageView(tag: 2)
  private lazy var previewImageView3: UIImageView = getImageView(tag: 3)
  private lazy var previewImageView4: UIImageView = getImageView(tag: 4)
  private lazy var previewImageView5: UIImageView = getImageView(tag: 5)
  private lazy var previewImageView6: UIImageView = getImageView(tag: 6)
  private lazy var previewImageView7: UIImageView = getImageView(tag: 7)
  private lazy var previewImageView8: UIImageView = getImageView(tag: 8)
  
  private func getImageView(tag: Int) -> UIImageView {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    
    imageView.backgroundColor = .blue
    
    return imageView
  }
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayout() {
    let previewImagesStackView = UIStackView(arrangedSubviews: [
      previewImageView1,
      previewImageView2,
      previewImageView3,
      previewImageView4,
      previewImageView5,
      previewImageView6,
      previewImageView7,
      previewImageView8
    ])
    previewImagesStackView.translatesAutoresizingMaskIntoConstraints = false
    previewImagesStackView.axis = .horizontal
//    previewImagesStackView.alignment = .fill
    previewImagesStackView.distribution = .fillEqually
    
    
    addSubview(previewImagesContainerView)
    previewImagesContainerView.addSubview(previewImagesStackView)
    
    addConstraints([
      previewImagesContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 4.0),
      previewImagesContainerView.leftAnchor.constraint(equalTo: leftAnchor),
      previewImagesContainerView.rightAnchor.constraint(equalTo: rightAnchor),
      previewImagesContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.0),
      
      previewImagesStackView.topAnchor.constraint(equalTo: previewImagesContainerView.topAnchor),
      previewImagesStackView.leftAnchor.constraint(equalTo: previewImagesContainerView.leftAnchor),
      previewImagesStackView.rightAnchor.constraint(equalTo: previewImagesContainerView.rightAnchor),
      previewImagesStackView.bottomAnchor.constraint(equalTo: previewImagesContainerView.bottomAnchor)
    ])
  }
}

//
//  SettingsIconCollectionViewCell.swift
//  censor
//
//  Created by Maxim Skryabin on 26.10.2020.
//

import UIKit

class SettingsIconCollectionViewCell: UICollectionViewCell {
  
  private let iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.layer.cornerRadius = 6.0
    imageView.layer.masksToBounds = true
    
    imageView.backgroundColor = UIColor.red
    
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(icon: UIImage) {
    iconImageView.image = icon
  }
  
  private func setupLayout() {
    contentView.addSubview(iconImageView)
    
    contentView.addConstraints([
      iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      iconImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8.0),
      iconImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8.0),
      iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0)
    ])
  }
}

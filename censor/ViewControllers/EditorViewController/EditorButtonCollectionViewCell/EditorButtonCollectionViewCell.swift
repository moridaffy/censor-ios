//
//  EditorButtonCollectionViewCell.swift
//  censor
//
//  Created by Maxim Skryabin on 02.11.2020.
//

import UIKit

class EditorButtonCollectionViewCell: UICollectionViewCell {
  
  static let textFont: UIFont = UIFont.systemFont(ofSize: 15.0, weight: .regular)
  static let iconSide: CGFloat = 20.0
  
  private let containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 6.0
    view.layer.masksToBounds = true
    view.backgroundColor = ColorManager.shared.subtext25opacity
    return view
  }()
  
  private let iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.tintColor = ColorManager.shared.accent
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = ColorManager.shared.accent
    label.font = EditorButtonCollectionViewCell.textFont
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(viewModel: EditorButtonCollectionViewCellModel) {
    iconImageView.image = viewModel.type.icon
    titleLabel.text = viewModel.text
  }
  
  private func setupLayout() {
    contentView.addSubview(containerView)
    containerView.addSubview(iconImageView)
    containerView.addSubview(titleLabel)
    
    contentView.addConstraints([
      containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
      containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      
      iconImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8.0),
      iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      iconImageView.widthAnchor.constraint(equalToConstant: EditorButtonCollectionViewCell.iconSide),
      iconImageView.heightAnchor.constraint(equalToConstant: EditorButtonCollectionViewCell.iconSide),
      
      titleLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 8.0),
      titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
      titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8.0)
    ])
  }
  
}

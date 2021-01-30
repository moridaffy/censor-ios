//
//  LanguageListTableViewCell.swift
//  censor
//
//  Created by Maxim Skryabin on 30.01.2021.
//

import UIKit

class LanguageListTableViewCell: UITableViewCell {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = ColorManager.shared.accent
    label.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private let checkmarkImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate)
    imageView.tintColor = ColorManager.shared.accent
    return imageView
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    backgroundColor = ColorManager.shared.topBackground
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(title: String, isSelected: Bool) {
    titleLabel.text = title
    checkmarkImageView.isHidden = !isSelected
  }
  
  private func setupLayout() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(checkmarkImageView)
    
    contentView.addConstraints([
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16.0),
      titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
      
      checkmarkImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16.0),
      checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      checkmarkImageView.heightAnchor.constraint(equalToConstant: 16.0),
      checkmarkImageView.widthAnchor.constraint(equalToConstant: 16.0)
    ])
  }
  
}

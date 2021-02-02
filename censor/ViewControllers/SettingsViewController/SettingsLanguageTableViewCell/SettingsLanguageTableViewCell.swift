//
//  SettingsLanguageTableViewCell.swift
//  censor
//
//  Created by Maxim Skryabin on 30.01.2021.
//

import UIKit

class SettingsLanguageTableViewCell: UITableViewCell {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = ColorManager.shared.accent
    label.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
    label.textAlignment = .left
    label.numberOfLines = 0
    return label
  }()
  
  private let chevronImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(systemName: "chevron.forward")?.withRenderingMode(.alwaysTemplate)
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
  
  func update(viewModel: SettingsLanguageTableViewCellModel) {
    titleLabel.text = viewModel.currentLanguage
  }
  
  private func setupLayout() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(chevronImageView)
    
    contentView.addConstraints([
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16.0),
      titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
      
      chevronImageView.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 8.0),
      chevronImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16.0),
      chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      chevronImageView.heightAnchor.constraint(equalToConstant: 16.0),
      chevronImageView.widthAnchor.constraint(equalToConstant: 16.0)
    ])
  }
}

//
//  SettingsButtonTableViewCell.swift
//  censor
//
//  Created by Maxim Skryabin on 26.10.2020.
//

import UIKit

class SettingsButtonTableViewCell: UITableViewCell {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = ColorManager.shared.accent
    label.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    backgroundColor = ColorManager.shared.topBackground
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(viewModel: SettingsButtonTableViewCellModel) {
    titleLabel.text = viewModel.type.title
  }
  
  private func setupLayout() {
    contentView.addSubview(titleLabel)
    
    contentView.addConstraints([
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16.0),
      titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16.0),
      titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0)
    ])
  }
  
}

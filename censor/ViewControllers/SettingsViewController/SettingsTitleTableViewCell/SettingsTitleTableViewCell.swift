//
//  SettingsTitleTableViewCell.swift
//  censor
//
//  Created by Maxim Skryabin on 26.10.2020.
//

import UIKit

class SettingsTitleTableViewCell: UITableViewCell {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 22.0, weight: .semibold)
    label.numberOfLines = 0
    label.textColor = ColorManager.shared.text
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    removeSeparator()
    contentView.backgroundColor = ColorManager.shared.topBackground
    selectionStyle = .none
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(viewModel: SettingsTitleTableViewCellModel) {
    titleLabel.text = viewModel.title
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

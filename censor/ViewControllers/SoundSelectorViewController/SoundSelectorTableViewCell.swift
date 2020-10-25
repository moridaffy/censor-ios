//
//  SoundSelectorTableViewCell.swift
//  censor
//
//  Created by Maxim Skryabin on 25.10.2020.
//

import UIKit

class SoundSelectorTableViewCell: UITableViewCell {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(soundType: Sound.SoundType) {
    titleLabel.text = soundType.title
  }
  
  private func setupLayout() {
    contentView.addSubview(titleLabel)
    
    contentView.addConstraints([
      titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16.0),
      titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16.0)
    ])
  }
}

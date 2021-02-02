//
//  SettingsSwitchTableViewCell.swift
//  censor
//
//  Created by Maxim Skryabin on 02.02.2021.
//

import UIKit

protocol SettingsSwitchTableViewCellDelegate: class {
  func didChangeSwitcherValue(for type: SettingsViewModel.SwitchType, to newValue: Bool)
}

class SettingsSwitchTableViewCell: UITableViewCell {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = ColorManager.shared.text
    label.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
    label.textAlignment = .left
    label.numberOfLines = 0
    return label
  }()
  
  private let switcher: UISwitch = {
    let switcher = UISwitch()
    switcher.translatesAutoresizingMaskIntoConstraints = false
    switcher.onTintColor = ColorManager.shared.accent
    return switcher
  }()
  
  private var viewModel: SettingsSwitchTableViewCellModel!
  private weak var delegate: SettingsSwitchTableViewCellDelegate?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    selectionStyle = .none
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(viewModel: SettingsSwitchTableViewCellModel, delegate: SettingsSwitchTableViewCellDelegate) {
    self.viewModel = viewModel
    self.delegate = delegate
    
    titleLabel.text = viewModel.type.title
    switcher.isOn = viewModel.value
    
    switcher.removeTarget(nil, action: nil, for: .allEvents)
    switcher.addTarget(self, action: #selector(switcherValueChanged), for: .valueChanged)
  }
  
  private func setupLayout() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(switcher)
    
    contentView.addConstraints([
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16.0),
      titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
      
      switcher.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 8.0),
      switcher.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16.0),
      switcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      switcher.widthAnchor.constraint(equalToConstant: 51.0)
    ])
  }
  
  @objc private func switcherValueChanged() {
    delegate?.didChangeSwitcherValue(for: viewModel.type, to: switcher.isOn)
  }
}

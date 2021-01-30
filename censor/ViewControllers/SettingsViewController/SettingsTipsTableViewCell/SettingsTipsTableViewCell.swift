//
//  SettingsTipsTableViewCell.swift
//  censor
//
//  Created by Maxim Skryabin on 26.10.2020.
//

import UIKit

protocol SettingsTipsTableViewCellDelegate: class {
  func didTapTipButton(ofType type: SettingsTipsTableViewCellModel.TipType)
}

class SettingsTipsTableViewCell: UITableViewCell {
  
  private struct Config {
    static let titleLabelTag: Int = 1
    static let priceLabelTag: Int = 2
  }
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .left
    label.numberOfLines = 0
    label.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
    label.textColor = ColorManager.shared.subtext
    return label
  }()
  
  private lazy var smallTipButton = getTipButtonView(forType: .small)
  private lazy var middleTipButton = getTipButtonView(forType: .middle)
  private lazy var largeTipButton = getTipButtonView(forType: .large)
  
  private var viewModel: SettingsTipsTableViewCellModel = SettingsTipsTableViewCellModel(iapPrices: [:])
  private weak var delegate: SettingsTipsTableViewCellDelegate?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    contentView.backgroundColor = ColorManager.shared.topBackground
    selectionStyle = .none
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(viewModel: SettingsTipsTableViewCellModel, delegate: SettingsTipsTableViewCellDelegate) {
    self.viewModel = viewModel
    self.delegate = delegate
    
    updateTexts()
  }
  
  private func setupLayout() {
    contentView.addSubview(descriptionLabel)
    contentView.addSubview(smallTipButton)
    contentView.addSubview(middleTipButton)
    contentView.addSubview(largeTipButton)
    
    contentView.addConstraints([
      descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      descriptionLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16.0),
      descriptionLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16.0),
      
      smallTipButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16.0),
      smallTipButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16.0),
      smallTipButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0),
      
      middleTipButton.topAnchor.constraint(equalTo: smallTipButton.topAnchor),
      middleTipButton.bottomAnchor.constraint(equalTo: smallTipButton.bottomAnchor),
      middleTipButton.leftAnchor.constraint(equalTo: smallTipButton.rightAnchor, constant: 8.0),
      middleTipButton.widthAnchor.constraint(equalTo: smallTipButton.widthAnchor),
      
      largeTipButton.topAnchor.constraint(equalTo: smallTipButton.topAnchor),
      largeTipButton.bottomAnchor.constraint(equalTo: smallTipButton.bottomAnchor),
      largeTipButton.leftAnchor.constraint(equalTo: middleTipButton.rightAnchor, constant: 8.0),
      largeTipButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16.0),
      largeTipButton.widthAnchor.constraint(equalTo: smallTipButton.widthAnchor)
    ])
  }
  
  private func updateTexts() {
    descriptionLabel.text = LocalizeSystem.shared.settings(.tipDescription)
    
    
    let buttons: [UIView] = [smallTipButton, middleTipButton, largeTipButton]
    let tips: [SettingsTipsTableViewCellModel.TipType] = [.small, .middle, .large]
    for i in 0..<buttons.count {
      let button = buttons[i]
      let tip = tips[i]
      
      for label in button.subviews.compactMap({ $0 as? UILabel }) {
        if label.tag == Config.titleLabelTag {
          label.text = tip.iapType.title
        } else if label.tag == Config.priceLabelTag {
          label.text = viewModel.iapPrices[tip.iapType]
        }
      }
    }
  }
  
  private func getTipButtonView(forType type: SettingsTipsTableViewCellModel.TipType) -> UIView {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = ColorManager.shared.subtext25opacity
    containerView.layer.cornerRadius = 6.0
    containerView.layer.masksToBounds = true
    
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.isUserInteractionEnabled = false
    titleLabel.text = type.iapType.title
    titleLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    titleLabel.textColor = ColorManager.shared.accent
    titleLabel.tag = Config.titleLabelTag
    
    let iconImageView = UIImageView()
    iconImageView.translatesAutoresizingMaskIntoConstraints = false
    iconImageView.isUserInteractionEnabled = false
    iconImageView.image = UIImage(named: type.iconName)?.withRenderingMode(.alwaysTemplate)
    iconImageView.tintColor = ColorManager.shared.text
    iconImageView.contentMode = .scaleAspectFit
    
    let priceLabel = UILabel()
    priceLabel.translatesAutoresizingMaskIntoConstraints = false
    priceLabel.isUserInteractionEnabled = false
    priceLabel.font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
    priceLabel.textAlignment = .center
    priceLabel.textColor = ColorManager.shared.subtext
    priceLabel.tag = Config.priceLabelTag
    
    let tapRecognizer: UITapGestureRecognizer = {
      switch type {
      case .small:
        return UITapGestureRecognizer(target: self, action: #selector(smallTipButtonTapped))
      case .middle:
        return UITapGestureRecognizer(target: self, action: #selector(middleTipButtonTapped))
      case .large:
        return UITapGestureRecognizer(target: self, action: #selector(largeTipButtonTapped))
      }
    }()
    containerView.addGestureRecognizer(tapRecognizer)
    
    containerView.addSubview(titleLabel)
    containerView.addSubview(iconImageView)
    containerView.addSubview(priceLabel)
    
    containerView.addConstraints([
      titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.0),
      titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8.0),
      titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8.0),
      
      iconImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0),
      iconImageView.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
      iconImageView.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
      iconImageView.heightAnchor.constraint(equalToConstant: 50.0),
      
      priceLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8.0),
      priceLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
      priceLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
      priceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8.0)
    ])
    
    return containerView
  }
  
  @objc private func smallTipButtonTapped() {
    delegate?.didTapTipButton(ofType: .small)
  }
  
  @objc private func middleTipButtonTapped() {
    delegate?.didTapTipButton(ofType: .middle)
  }
  
  @objc private func largeTipButtonTapped() {
    delegate?.didTapTipButton(ofType: .large)
  }
  
}

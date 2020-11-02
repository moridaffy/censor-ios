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
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .left
    label.numberOfLines = 0
    label.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
    label.text = """
    Developing and supporting mobile apps tike a lot of time and effort. I decided to make this app free so everyone can try it out and decide whether to keep it on his phone or delete it. If you enjoy using this app, you can say thanks and motivate me to work even harder on it by simply leaving a tip. You can even choose the amount of tip you want to give and give it as many times as you wish :) By leaving any tip, you support me and get access to some new features:
    • all ads magically will dissapear, as well as watermark on your exported videos
    • additional sounds will become unlocked
    • some new features may also appear
    """
    return label
  }()
  
  private lazy var smallTipButton = getTipButtonView(forType: .small)
  private lazy var middleTipButton = getTipButtonView(forType: .middle)
  private lazy var largeTipButton = getTipButtonView(forType: .large)
  
  private weak var delegate: SettingsTipsTableViewCellDelegate?
  
  private let viewModel = SettingsTipsTableViewCellModel()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    selectionStyle = .none
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(viewModel: SettingsTipsTableViewCellModel, delegate: SettingsTipsTableViewCellDelegate) {
    self.delegate = delegate
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
  
  private func getTipButtonView(forType type: SettingsTipsTableViewCellModel.TipType) -> UIView {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
    containerView.layer.cornerRadius = 6.0
    containerView.layer.masksToBounds = true
    
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.isUserInteractionEnabled = false
    titleLabel.text = String(type.rawValue) + " cups of coffee"
    titleLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    
    let iconImageView = UIImageView()
    iconImageView.translatesAutoresizingMaskIntoConstraints = false
    iconImageView.isUserInteractionEnabled = false
    iconImageView.image = UIImage(named: type.iconName)?.withRenderingMode(.alwaysTemplate)
    iconImageView.tintColor = UIColor.black
    iconImageView.contentMode = .scaleAspectFit
    
    let priceLabel = UILabel()
    priceLabel.translatesAutoresizingMaskIntoConstraints = false
    priceLabel.isUserInteractionEnabled = false
    priceLabel.text = String(type.rawValue * 100) + "₽"
    priceLabel.font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
    priceLabel.textAlignment = .center
    
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
    
  }
  
  @objc private func middleTipButtonTapped() {
    
  }
  
  @objc private func largeTipButtonTapped() {
    
  }
  
}
//
//  RootButtonView.swift
//  censor
//
//  Created by Maxim Skryabin on 06.11.2020.
//

import UIKit

class RootButtonView: UIView {
  
  private let containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.clear
    view.layer.cornerRadius = 6.0
    view.layer.borderColor = ColorManager.shared.accent.cgColor
    view.layer.borderWidth = 2.0
    return view
  }()
  
  private let iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = ColorManager.shared.accent
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = ColorManager.shared.subtext
    label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  init(type: ButtonType) {
    super.init(frame: .zero)
    
    translatesAutoresizingMaskIntoConstraints = false
    
    setupLayout()
    updateButton(for: type)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayout() {
    addSubview(containerView)
    containerView.addSubview(iconImageView)
    containerView.addSubview(titleLabel)
    
    addConstraints([
      containerView.topAnchor.constraint(equalTo: topAnchor),
      containerView.leftAnchor.constraint(equalTo: leftAnchor),
      containerView.rightAnchor.constraint(equalTo: rightAnchor),
      containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
      containerView.widthAnchor.constraint(equalToConstant: 128.0),
      
      iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
      iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16.0),
      iconImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16.0),
      iconImageView.heightAnchor.constraint(equalToConstant: 50.0),
      
      titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8.0),
      titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16.0),
      titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16.0),
      titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16.0)
    ])
  }
  
  func updateButton(for type: ButtonType) {
    iconImageView.image = type.icon?.withRenderingMode(.alwaysTemplate)
    titleLabel.text = type.title
  }
  
  func addTarget(_ target: Any?, action: Selector) {
    let tapRecognizer = UITapGestureRecognizer(target: target, action: action)
    addGestureRecognizer(tapRecognizer)
  }
}

extension RootButtonView {
  enum ButtonType {
    case newProject
    case existingProjects
    
    var title: String {
      switch self {
      case .newProject:
        return "Create new project"
      case .existingProjects:
        return "Browse existing projects"
      }
    }
    
    var icon: UIImage? {
      switch self {
      case .newProject:
        return UIImage(systemName: "plus.circle")
      case .existingProjects:
        return UIImage(systemName: "square.stack.3d.up")
      }
    }
  }
}

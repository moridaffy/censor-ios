//
//  RootButtonView.swift
//  censor
//
//  Created by Maxim Skryabin on 06.11.2020.
//

import UIKit

class RootButtonView: UIView {
  
  private let iconContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = ColorManager.shared.accent
    view.layer.cornerRadius = 25.0
    view.layer.masksToBounds = true
    return view
  }()
  
  private let iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = ColorManager.shared.bottomBackground
    return imageView
  }()
  
  private let loadingActivityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.color = ColorManager.shared.bottomBackground
    activityIndicator.startAnimating()
    activityIndicator.isHidden = true
    return activityIndicator
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
    addSubview(iconContainerView)
    iconContainerView.addSubview(iconImageView)
    iconContainerView.addSubview(loadingActivityIndicator)
    addSubview(titleLabel)
    
    addConstraints([
      iconContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
      iconContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 16.0),
      iconContainerView.heightAnchor.constraint(equalToConstant: 50.0),
      iconContainerView.widthAnchor.constraint(equalToConstant: 50.0),
      
      iconImageView.topAnchor.constraint(equalTo: iconContainerView.topAnchor, constant: 8.0),
      iconImageView.leftAnchor.constraint(equalTo: iconContainerView.leftAnchor, constant: 8.0),
      iconImageView.rightAnchor.constraint(equalTo: iconContainerView.rightAnchor, constant: -8.0),
      iconImageView.bottomAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: -8.0),
      
      loadingActivityIndicator.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
      loadingActivityIndicator.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
      
      titleLabel.topAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: 8.0),
      titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16.0),
      titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16.0),
      titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0)
    ])
  }
  
  func updateButton(for type: ButtonType) {
    iconImageView.image = type.icon?.withRenderingMode(.alwaysTemplate)
    titleLabel.text = type.title
  }
  
  func startLoading(_ start: Bool) {
    iconImageView.isHidden = start
    loadingActivityIndicator.isHidden = !start
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
        return NSLocalizedString("Create new project", comment: "")
      case .existingProjects:
        return NSLocalizedString("Browse existing projects", comment: "")
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

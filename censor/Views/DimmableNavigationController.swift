//
//  DimmableNavigationController.swift
//  censor
//
//  Created by Maxim Skryabin on 05.11.2020.
//

import UIKit

class DimmableNavigationController: UINavigationController {
  
  private let dimView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
    view.alpha = 0.0
    return view
  }()
  
  private let loadingIndicatorContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 6.0
    view.layer.masksToBounds = true
    view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
    view.alpha = 0.0
    return view
  }()
  
  private let loadingIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView(style: .large)
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.startAnimating()
    return activityIndicator
  }()
  
  private let loadingProgressLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .center
    label.textColor = UIColor.white
    label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    label.isHidden = true
    return label
  }()
  
  private var loadingIndicatorBottomConstraint: NSLayoutConstraint?
  
  override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)
    
    navigationBar.isTranslucent = false
    navigationBar.barTintColor = ColorManager.shared.topBackground
    navigationBar.tintColor = ColorManager.shared.accent
    
    setupLayout()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayout() {
    view.addSubview(dimView)
    view.addSubview(loadingIndicatorContainerView)
    loadingIndicatorContainerView.addSubview(loadingIndicator)
    loadingIndicatorContainerView.addSubview(loadingProgressLabel)
    
    let loadingIndicatorBottomConstraint = loadingIndicator.bottomAnchor.constraint(equalTo: loadingIndicatorContainerView.bottomAnchor, constant: -30.0)
    self.loadingIndicatorBottomConstraint = loadingIndicatorBottomConstraint
    
    view.addConstraints([
      dimView.topAnchor.constraint(equalTo: view.topAnchor),
      dimView.leftAnchor.constraint(equalTo: view.leftAnchor),
      dimView.rightAnchor.constraint(equalTo: view.rightAnchor),
      dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      loadingIndicatorContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      loadingIndicatorContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      loadingIndicatorContainerView.widthAnchor.constraint(equalToConstant: 100.0),
      
      loadingIndicator.centerXAnchor.constraint(equalTo: loadingIndicatorContainerView.centerXAnchor),
      loadingIndicator.heightAnchor.constraint(equalToConstant: 40.0),
      loadingIndicator.widthAnchor.constraint(equalToConstant: 40.0),
      loadingIndicator.topAnchor.constraint(equalTo: loadingIndicatorContainerView.topAnchor, constant: 30.0),
      loadingIndicatorBottomConstraint,
      
      loadingProgressLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 16.0),
      loadingProgressLabel.leftAnchor.constraint(equalTo: loadingIndicatorContainerView.leftAnchor, constant: 16.0),
      loadingProgressLabel.rightAnchor.constraint(equalTo: loadingIndicatorContainerView.rightAnchor, constant: -16.0)
    ])
  }
  
  func showDimView(_ show: Bool, withLoading: Bool, animated: Bool = true) {
    UIView.animate(withDuration: animated ? 0.25 : 0.0) {
      self.dimView.alpha = show ? 1.0 : 0.0
      self.loadingIndicatorContainerView.alpha = withLoading ? (show ? 1.0 : 0.0) : 0.0
    }
  }
  
  func updateProgress(with percents: Int?) {
    if let percents = percents {
      loadingIndicatorBottomConstraint?.constant = -30.0 - 14.0 - 16.0
      loadingProgressLabel.isHidden = false
      loadingProgressLabel.text = "\(percents)%"
    } else {
      loadingIndicatorBottomConstraint?.constant = -30.0
      loadingProgressLabel.isHidden = true
    }
  }
  
}

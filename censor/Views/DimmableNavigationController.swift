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
    
    view.addConstraints([
      dimView.topAnchor.constraint(equalTo: view.topAnchor),
      dimView.leftAnchor.constraint(equalTo: view.leftAnchor),
      dimView.rightAnchor.constraint(equalTo: view.rightAnchor),
      dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      loadingIndicatorContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      loadingIndicatorContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      loadingIndicatorContainerView.heightAnchor.constraint(equalToConstant: 100.0),
      loadingIndicatorContainerView.widthAnchor.constraint(equalToConstant: 100.0),
      
      loadingIndicator.centerYAnchor.constraint(equalTo: loadingIndicatorContainerView.centerYAnchor),
      loadingIndicator.centerXAnchor.constraint(equalTo: loadingIndicatorContainerView.centerXAnchor)
    ])
  }
  
  func showDimView(_ show: Bool, withLoading: Bool, animated: Bool = true) {
    UIView.animate(withDuration: animated ? 0.25 : 0.0) {
      self.dimView.alpha = show ? 1.0 : 0.0
      self.loadingIndicatorContainerView.alpha = withLoading ? (show ? 1.0 : 0.0) : 0.0
    }
  }
  
}

//
//  AudioModeSelectorViewController.swift
//  censor
//
//  Created by Maxim Skryabin on 27.01.2021.
//

import UIKit

protocol AudioModeSelectorViewControllerDelegate: class {
  func didSelectAudioMode(_ audioMode: VideoRenderer.AudioMode)
}

class AudioModeSelectorViewController: UIViewController {
  
  private lazy var keepModeButton = getModeButtonView(forType: .keepOriginal)
  private lazy var silenceModeButton = getModeButtonView(forType: .silenceOriginal)
  private lazy var muteModeButton = getModeButtonView(forType: .muteOriginal)
  
  private let descriptionContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = ColorManager.shared.topBackground
    view.layer.cornerRadius = 6.0
    return view
  }()
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = ColorManager.shared.subtext
    label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private let saveButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.layer.cornerRadius = 6.0
    button.layer.masksToBounds = true
    button.backgroundColor = ColorManager.shared.topBackground
    button.setTitle(LocalizeSystem.shared.common(.save), for: .normal)
    button.setTitleColor(ColorManager.shared.accent, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
    return button
  }()
  
  private let viewModel: AudioModeSelectorViewModel
  private weak var delegate: AudioModeSelectorViewControllerDelegate?
  
  init(viewModel: AudioModeSelectorViewModel, delegate: AudioModeSelectorViewControllerDelegate) {
    self.viewModel = viewModel
    self.delegate = delegate
    
    super.init(nibName: nil, bundle: nil)
    
    view.backgroundColor = UIColor.systemBackground
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    updateSelectedModeButton()
    
    saveButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
  }
  
  private func setupLayout() {
    view.addSubview(keepModeButton)
    view.addSubview(silenceModeButton)
    view.addSubview(muteModeButton)
    view.addSubview(descriptionContainerView)
    descriptionContainerView.addSubview(descriptionLabel)
    view.addSubview(saveButton)
    
    view.addConstraints([
      keepModeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
      keepModeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16.0),
      keepModeButton.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 6.0),
      
      silenceModeButton.topAnchor.constraint(equalTo: keepModeButton.topAnchor),
      silenceModeButton.leftAnchor.constraint(equalTo: keepModeButton.rightAnchor, constant: 16.0),
      
      muteModeButton.topAnchor.constraint(equalTo: silenceModeButton.topAnchor),
      muteModeButton.leftAnchor.constraint(equalTo: silenceModeButton.rightAnchor, constant: 16.0),
      muteModeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16.0),
      muteModeButton.widthAnchor.constraint(equalTo: keepModeButton.widthAnchor),
      muteModeButton.widthAnchor.constraint(equalTo: silenceModeButton.widthAnchor),
      muteModeButton.heightAnchor.constraint(equalTo: keepModeButton.heightAnchor),
      muteModeButton.heightAnchor.constraint(equalTo: silenceModeButton.heightAnchor),
      
      descriptionContainerView.topAnchor.constraint(equalTo: keepModeButton.bottomAnchor, constant: 32.0),
      descriptionContainerView.leftAnchor.constraint(equalTo: keepModeButton.leftAnchor),
      descriptionContainerView.rightAnchor.constraint(equalTo: muteModeButton.rightAnchor),
      
      descriptionLabel.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: 8.0),
      descriptionLabel.leftAnchor.constraint(equalTo: descriptionContainerView.leftAnchor, constant: 8.0),
      descriptionLabel.rightAnchor.constraint(equalTo: descriptionContainerView.rightAnchor, constant: -8.0),
      descriptionLabel.bottomAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor, constant: -8.0),
      
      saveButton.topAnchor.constraint(greaterThanOrEqualTo: descriptionContainerView.bottomAnchor, constant: 32.0),
      saveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16.0),
      saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16.0),
      saveButton.heightAnchor.constraint(equalToConstant: 50.0),
      saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16.0)
    ])
  }
  
  private func setupNavigationBar() {
    title = LocalizeSystem.shared.editor(.selectAudioMode)
    
    let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonTapped))
    navigationItem.rightBarButtonItem = closeButton
  }
  
  private func getModeButtonView(forType type: VideoRenderer.AudioMode) -> UIView {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = ColorManager.shared.subtext25opacity
    containerView.layer.cornerRadius = 6.0
    containerView.layer.masksToBounds = true
    containerView.layer.borderColor = ColorManager.shared.accent.cgColor
    
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.isUserInteractionEnabled = false
    titleLabel.text = type.title
    titleLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    titleLabel.textColor = ColorManager.shared.accent
    
    let iconImageView = UIImageView()
    iconImageView.translatesAutoresizingMaskIntoConstraints = false
    iconImageView.isUserInteractionEnabled = false
    iconImageView.image = UIImage(systemName: type.iconSystemName)?.withRenderingMode(.alwaysTemplate)
    iconImageView.tintColor = ColorManager.shared.text
    iconImageView.contentMode = .scaleAspectFit
    
    let tapRecognizer: UITapGestureRecognizer = {
      switch type {
      case .keepOriginal:
        return UITapGestureRecognizer(target: self, action: #selector(keepModeButtonTapped))
      case .silenceOriginal:
        return UITapGestureRecognizer(target: self, action: #selector(silenceModeButtonTapped))
      case .muteOriginal:
        return UITapGestureRecognizer(target: self, action: #selector(muteModeButtonTapped))
      }
    }()
    containerView.addGestureRecognizer(tapRecognizer)
    
    containerView.addSubview(titleLabel)
    containerView.addSubview(iconImageView)
    
    containerView.addConstraints([
      titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16.0),
      titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8.0),
      titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8.0),
      
      iconImageView.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: 16.0),
      iconImageView.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
      iconImageView.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
      iconImageView.heightAnchor.constraint(equalToConstant: 40.0),
      iconImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16.0)
    ])
    
    return containerView
  }
  
  private func updateSelectedModeButton() {
    switch viewModel.selectedAudioMode {
    case .keepOriginal:
      keepModeButton.layer.borderWidth = 2.0
      silenceModeButton.layer.borderWidth = 0.0
      muteModeButton.layer.borderWidth = 0.0
    case .silenceOriginal:
      keepModeButton.layer.borderWidth = 0.0
      silenceModeButton.layer.borderWidth = 2.0
      muteModeButton.layer.borderWidth = 0.0
    case .muteOriginal:
      keepModeButton.layer.borderWidth = 0.0
      silenceModeButton.layer.borderWidth = 0.0
      muteModeButton.layer.borderWidth = 2.0
    }
    
    descriptionLabel.text = viewModel.selectedAudioMode.description
  }
  
  @objc private func closeButtonTapped() {
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
  @objc private func keepModeButtonTapped() {
    delegate?.didSelectAudioMode(.keepOriginal)
    viewModel.selectedAudioMode = .keepOriginal
    updateSelectedModeButton()
  }
  
  @objc private func silenceModeButtonTapped() {
    delegate?.didSelectAudioMode(.silenceOriginal)
    viewModel.selectedAudioMode = .silenceOriginal
    updateSelectedModeButton()
  }
  
  @objc private func muteModeButtonTapped() {
    delegate?.didSelectAudioMode(.muteOriginal)
    viewModel.selectedAudioMode = .muteOriginal
    updateSelectedModeButton()
  }
}

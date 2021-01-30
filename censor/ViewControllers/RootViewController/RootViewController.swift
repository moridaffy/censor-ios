//
//  RootViewController.swift
//  censor
//
//  Created by Maxim Skryabin on 20.10.2020.
//

import UIKit

class RootViewController: UIViewController {
  
  static private(set) var shared: RootViewController!
  
  private let logoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let welcomeLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private let buttonsContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = ColorManager.shared.topBackground
    view.layer.cornerRadius = 6.0
    return view
  }()

  private lazy var newProjectButton = RootButtonView(type: .newProject)
  private lazy var existingProjectsButton = RootButtonView(type: .existingProjects)
  
  private let viewModel: RootViewModel = RootViewModel()
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    RootViewController.shared = self
    
    view.backgroundColor = ColorManager.shared.bottomBackground
    logoImageView.image = ColorManager.shared.logoImage
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    setupButtons()
    
    NotificationCenter.default.addObserver(self, selector: #selector(updateTexts), name: .languageChanged, object: nil)
    updateTexts()
    
    // TODO: fixme
    DispatchQueue.main.async {
      self.buttonsContainerView.addDashedBorder(ofColor: ColorManager.shared.subtext,
                                                borderWidth: 2.0,
                                                cornerRadius: self.buttonsContainerView.layer.cornerRadius)
    }
  }
  
  private func setupLayout() {
    let logoImageViewTop: CGFloat = SettingsManager.shared.isIpad ? UIScreen.main.bounds.height / 4 : 64.0
    let logoImageViewWidth: CGFloat = min(UIScreen.main.bounds.width - 128.0, 300.0)
    
    let buttonsStackView = UIStackView(arrangedSubviews: [newProjectButton, existingProjectsButton])
    buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
    buttonsStackView.axis = .horizontal
    buttonsStackView.alignment = .center
    buttonsStackView.spacing = 16.0
    
    view.addSubview(logoImageView)
    view.addSubview(welcomeLabel)
    view.addSubview(buttonsContainerView)
    buttonsContainerView.addSubview(buttonsStackView)
    
    view.addConstraints([
      logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: logoImageViewTop),
      logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      logoImageView.heightAnchor.constraint(equalToConstant: logoImageViewWidth),
      logoImageView.widthAnchor.constraint(equalToConstant: logoImageViewWidth),
      
      welcomeLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 32.0),
      welcomeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32.0),
      welcomeLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32.0),
      welcomeLabel.bottomAnchor.constraint(lessThanOrEqualTo: buttonsContainerView.topAnchor, constant: -16.0),
      
      buttonsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      buttonsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32.0),
      buttonsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32.0),
      buttonsContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32.0),
      buttonsContainerView.heightAnchor.constraint(equalToConstant: 176.0),
      
      buttonsStackView.topAnchor.constraint(equalTo: buttonsContainerView.topAnchor, constant: 16.0),
      buttonsStackView.leftAnchor.constraint(equalTo: buttonsContainerView.leftAnchor, constant: 16.0),
      buttonsStackView.rightAnchor.constraint(equalTo: buttonsContainerView.rightAnchor, constant: -16.0),
      buttonsStackView.bottomAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor, constant: -16.0),
      
      newProjectButton.heightAnchor.constraint(equalTo: existingProjectsButton.heightAnchor),
      newProjectButton.widthAnchor.constraint(equalTo: existingProjectsButton.widthAnchor)
    ])
  }
  
  private func setupNavigationBar() {
    title = "CenStory"
    
    let settingsBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear")?.withRenderingMode(.alwaysTemplate),
                                                style: .plain,
                                                target: self,
                                                action: #selector(settingsButtonTapped))
    settingsBarButtonItem.tintColor = ColorManager.shared.accent
    navigationItem.leftBarButtonItem = settingsBarButtonItem
    
    let helpBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "questionmark.circle")?.withRenderingMode(.alwaysTemplate),
                                            style: .plain,
                                            target: self,
                                            action: #selector(helpButtonTapped))
    helpBarButtonItem.tintColor = ColorManager.shared.accent
    navigationItem.rightBarButtonItem = helpBarButtonItem
  }
  
  private func setupButtons() {
    newProjectButton.addTarget(self, action: #selector(createProjectButtonTapped))
    existingProjectsButton.addTarget(self, action: #selector(openProjectListButtonTapped))
  }
  
  private func presentProjectListViewController(createNewProject: Bool) {
    // TODO: fixme
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      let projectListViewModel = ProjectListViewModel()
      let projectListViewController = ProjectListViewController(viewModel: projectListViewModel)
      self.navigationController?.pushViewController(projectListViewController, animated: true, completion: {
        guard createNewProject else { return }
        projectListViewController.addProjectButtonTapped()
      })
    }
  }
  
  @objc private func settingsButtonTapped() {
    let settingsViewController = SettingsViewController().embedInNavigationController()
    present(settingsViewController, animated: true, completion: nil)
  }
  
  @objc private func helpButtonTapped() {
    // TODO
  }
  
  @objc private func createProjectButtonTapped() {
    guard !viewModel.buttonTapped else { return }
    viewModel.buttonTapped = true
    newProjectButton.startLoading(true)
    presentProjectListViewController(createNewProject: true)
  }
  
  @objc private func openProjectListButtonTapped() {
    guard !viewModel.buttonTapped else { return }
    viewModel.buttonTapped = true
    existingProjectsButton.startLoading(true)
    presentProjectListViewController(createNewProject: false)
  }
  
  @objc private func updateTexts() {
    let welcomeText = NSMutableAttributedString()
    welcomeText.append(NSAttributedString(string: LocalizeSystem.shared.root(.welcomeTitle) + "!",
                                   attributes: [.font: UIFont.systemFont(ofSize: 30.0, weight: .semibold),
                                                .foregroundColor: ColorManager.shared.text]))
    welcomeText.append(NSAttributedString(string: "\n" + LocalizeSystem.shared.root(.welcomeDescription),
                                   attributes: [.font: UIFont.systemFont(ofSize: 16.0, weight: .regular),
                                                .foregroundColor: ColorManager.shared.subtext]))
    welcomeLabel.attributedText = welcomeText
    
    newProjectButton.updateTexts()
    existingProjectsButton.updateTexts()
  }
}

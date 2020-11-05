//
//  RootViewController.swift
//  censor
//
//  Created by Maxim Skryabin on 20.10.2020.
//

import UIKit

class RootViewController: UIViewController {
  
  static private(set) var shared: RootViewController!

  private lazy var newProjectButton = RootButtonView(type: .newProject)
  private lazy var existingProjectsButton = RootButtonView(type: .existingProjects)
  
  private let viewModel: RootViewModel = RootViewModel()
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    RootViewController.shared = self
    
    view.backgroundColor = ColorManager.shared.bottomBackground
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupButtons()
  }
  
  private func setupLayout() {
    let buttonsStackView = UIStackView(arrangedSubviews: [newProjectButton, existingProjectsButton])
    buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
    buttonsStackView.axis = .horizontal
    buttonsStackView.alignment = .center
    buttonsStackView.spacing = 16.0
    
    view.addSubview(buttonsStackView)
    
    view.addConstraints([
      buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32.0),
      buttonsStackView.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: 32.0),
      newProjectButton.heightAnchor.constraint(equalTo: existingProjectsButton.heightAnchor)
    ])
  }
  
  private func setupButtons() {
    newProjectButton.addTarget(self, action: #selector(createProjectButtonTapped))
    existingProjectsButton.addTarget(self, action: #selector(openProjectListButtonTapped))
  }
  
  private func presentProjectListViewController(createNewProject: Bool) {
    let projectListViewModel = ProjectListViewModel()
    let projectListViewController = ProjectListViewController(viewModel: projectListViewModel)
    navigationController?.pushViewController(projectListViewController, animated: true, completion: {
      guard createNewProject else { return }
      projectListViewController.addProjectButtonTapped()
    })
  }
  
  @objc private func createProjectButtonTapped() {
    presentProjectListViewController(createNewProject: true)
  }
  
  @objc private func openProjectListButtonTapped() {
    presentProjectListViewController(createNewProject: false)
  }
}

//
//  RootViewController.swift
//  censor
//
//  Created by Maxim Skryabin on 20.10.2020.
//

import UIKit

class RootViewController: UIViewController {
  
  static private(set) var shared: RootViewController!
  
  private let createProjectButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("New project", for: .normal)
    button.setTitleColor(UIColor.white, for: .normal)
    button.layer.cornerRadius = 6.0
    button.layer.masksToBounds = true
    button.backgroundColor = UIColor.systemBlue
    return button
  }()
  
  private let openProjectsListButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Existing projects", for: .normal)
    button.setTitleColor(UIColor.white, for: .normal)
    button.layer.cornerRadius = 6.0
    button.layer.masksToBounds = true
    button.backgroundColor = UIColor.systemBlue
    return button
  }()
  
  private let viewModel: RootViewModel = RootViewModel()
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    RootViewController.shared = self
    
    view.backgroundColor = .white
    
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
    view.addSubview(createProjectButton)
    view.addSubview(openProjectsListButton)
    
    view.addConstraints([
      createProjectButton.heightAnchor.constraint(equalTo: openProjectsListButton.heightAnchor),
      createProjectButton.leftAnchor.constraint(equalTo: openProjectsListButton.leftAnchor),
      createProjectButton.rightAnchor.constraint(equalTo: openProjectsListButton.rightAnchor),
      createProjectButton.bottomAnchor.constraint(equalTo: openProjectsListButton.topAnchor, constant: -16.0),
      
      openProjectsListButton.heightAnchor.constraint(equalToConstant: 50.0),
      openProjectsListButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32.0),
      openProjectsListButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32.0),
      openProjectsListButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32.0)
    ])
  }
  
  private func setupButtons() {
    createProjectButton.addTarget(self, action: #selector(createProjectButtonTapped), for: .touchUpInside)
    openProjectsListButton.addTarget(self, action: #selector(openProjectListButtonTapped), for: .touchUpInside)
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

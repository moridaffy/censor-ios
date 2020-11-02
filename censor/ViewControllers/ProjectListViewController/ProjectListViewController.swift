//
//  ProjectListViewController.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import UIKit

class ProjectListViewController: UIViewController {
  
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.tableFooterView = UIView()
    
    tableView.register(ProjectListTableViewCell.self, forCellReuseIdentifier: String(describing: ProjectListTableViewCell.self))
    return tableView
  }()
  
  private let viewModel: ProjectListViewModel
  
  private let imagePickerController = UIImagePickerController()
  
  init(viewModel: ProjectListViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
    
    view.backgroundColor = UIColor.systemBackground
    
    setupLayout()
    setupImagePicker()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    setupTableView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    viewModel.view = self
    
    viewModel.reloadProjects()
  }
  
  private func setupLayout() {
    view.addSubview(tableView)
    
    view.addConstraints([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
      tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func setupImagePicker() {
    imagePickerController.delegate = self
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.mediaTypes = [viewModel.mediaType]
  }
  
  private func setupNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsButtonTapped))
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .plain, target: self, action: #selector(addProjectButtonTapped))
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  private func createNewProject(with name: String?) {
    guard let name = name, !name.isEmpty else {
      showAlertError(error: nil,
                     desc: "Enter project's name",
                     critical: false)
      return
    }
    guard let originalUrl = viewModel.selectedFileUrl else {
      showAlertError(error: nil,
                     desc: "File's url is empty for some reason :/",
                     critical: false)
      return
    }
    
    viewModel.createNewProject(name: name, originalUrl: originalUrl) { [weak self] (project) in
      self?.presentEditorViewController(for: project)
    }
  }
  
  private func presentNewProjectAlert() {
    let alert = UIAlertController(title: "New project",
                                  message: "Enter new project's name",
                                  preferredStyle: .alert)
    alert.addTextField { (textField) in
      textField.placeholder = "My cool movie"
      textField.autocapitalizationType = .sentences
      textField.autocorrectionType = .yes
      
      #if DEBUG
      textField.text = "My cool movie"
      #endif
    }
    alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (_) in
      self.createNewProject(with: alert.textFields?.first?.text)
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
      alert.dismiss(animated: true, completion: nil)
    }))
    present(alert, animated: true, completion: nil)
  }
  
  private func presentEditorViewController(for project: Project) {
    let editorViewModel = EditorViewModel(project: project)
    let editorViewController = EditorViewController(viewModel: editorViewModel)
    navigationController?.pushViewController(editorViewController, animated: true)
  }
  
  @objc private func settingsButtonTapped() {
    let settingsViewController = SettingsViewController().embedInNavigationController()
    present(settingsViewController, animated: true, completion: nil)
  }
  
  @objc func addProjectButtonTapped() {
    present(imagePickerController, animated: true, completion: nil)
  }
  
  func reloadTableView() {
    tableView.reloadData()
  }
}

extension ProjectListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    presentEditorViewController(for: viewModel.projects[indexPath.row])
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80.0
  }
  
//  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//    let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
//      self.viewModel.deleteProject(at: indexPath.row)
//    }
//    deleteAction.backgroundColor = UIColor.systemRed
//    return [deleteAction]
//  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
      self.viewModel.deleteProject(at: indexPath.row)
    }
    deleteAction.backgroundColor = UIColor.systemRed
    return UISwipeActionsConfiguration(actions: [deleteAction])
  }
}

extension ProjectListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.projects.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProjectListTableViewCell.self)) as? ProjectListTableViewCell else { fatalError() }
    cell.update(project: viewModel.projects[indexPath.row])
    return cell
  }
}

extension ProjectListViewController: (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard info[UIImagePickerController.InfoKey.mediaType] as? String == viewModel.mediaType,
          let mediaUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { fatalError() }
    viewModel.selectedFileUrl = mediaUrl
    imagePickerController.dismiss(animated: true, completion: {
      self.presentNewProjectAlert()
    })
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    imagePickerController.dismiss(animated: true, completion: nil)
  }
}

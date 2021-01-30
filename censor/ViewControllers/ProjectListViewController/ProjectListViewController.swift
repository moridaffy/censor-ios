//
//  ProjectListViewController.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import UIKit
import GoogleMobileAds

class ProjectListViewController: UIViewController {
  
  private let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.tableFooterView = UIView()
    tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    tableView.backgroundColor = ColorManager.shared.bottomBackground
    
    tableView.register(ProjectListTableViewCell.self, forCellReuseIdentifier: String(describing: ProjectListTableViewCell.self))
    
    return tableView
  }()
  
  private let newProjectButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitleColor(ColorManager.shared.subtext, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
    button.layer.cornerRadius = 6.0
    button.layer.masksToBounds = true
    button.layer.borderWidth = 0.5
    button.layer.borderColor = ColorManager.shared.subtext.cgColor
    button.isHidden = true
    return button
  }()
  
  private let bottomBanner: GADBannerView = {
    let banner = GADBannerView(adSize: kGADAdSizeBanner)
    banner.translatesAutoresizingMaskIntoConstraints = false
    banner.layer.cornerRadius = 6.0
    banner.layer.masksToBounds = true
    return banner
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
    
    NotificationCenter.default.addObserver(self, selector: #selector(updateTexts), name: .languageChanged, object: nil)
    updateTexts()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    viewModel.view = self
    
    viewModel.reloadProjects()
    
    setupBanner()
  }
  
  private func setupLayout() {
    view.addSubview(tableView)
    view.addSubview(newProjectButton)
    
    view.addConstraints([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
      tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      newProjectButton.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
      newProjectButton.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
      newProjectButton.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: 32.0)
    ])
  }
  
  private func setupImagePicker() {
    imagePickerController.delegate = self
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.mediaTypes = [viewModel.mediaType]
  }
  
  private func setupNavigationBar() {
    let settingsBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear")?.withRenderingMode(.alwaysTemplate),
                                                style: .plain,
                                                target: self,
                                                action: #selector(settingsButtonTapped))
    settingsBarButtonItem.tintColor = ColorManager.shared.accent
    navigationItem.leftBarButtonItem = settingsBarButtonItem
    
    let addProjectBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.circle")?.withRenderingMode(.alwaysTemplate),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(addProjectButtonTapped))
    addProjectBarButtonItem.tintColor = ColorManager.shared.accent
    navigationItem.rightBarButtonItem = addProjectBarButtonItem
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    
    newProjectButton.addTarget(self, action: #selector(addProjectButtonTapped), for: .touchUpInside)
  }
  
  private func setupBanner() {
    guard !viewModel.adBannerConfigured else { return }
    viewModel.adBannerConfigured = true
    
    guard !SettingsManager.shared.isPremiumFeaturesUnlocked else { return }
    
    view.addSubview(bottomBanner)
    view.addConstraints([
      bottomBanner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      bottomBanner.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
    tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kGADAdSizeBanner.size.height, right: 0.0)
    
    #if DEBUG
    bottomBanner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
    #else
    bottomBanner.adUnitID = "ca-app-pub-1533648811509508/1526702457"
    #endif
    bottomBanner.rootViewController = self
    bottomBanner.load(GADRequest())
    
    NotificationCenter.default.addObserver(self, selector: #selector(purchasedTipNotificationReceived), name: .purchasedTip, object: nil)
  }
  
  private func createNewProject(with name: String) {
    guard let originalUrl = viewModel.selectedFileUrl else {
      showAlertError(error: nil,
                     desc: LocalizeSystem.shared.error(.emptyFileUrl) + " :/",
                     critical: false)
      return
    }
    
    viewModel.createNewProject(name: name, originalUrl: originalUrl) { [weak self] (project) in
      self?.presentEditorViewController(for: project)
    }
  }
  
  private func presentNewProjectAlert() {
    let projectDefaultName: String = [LocalizeSystem.shared.projects(.project), "#\(viewModel.projects.count + 1)"].joined(separator: " ")
    let alert = UIAlertController(title: LocalizeSystem.shared.projects(.newProject),
                                  message: LocalizeSystem.shared.projects(.newProjectName),
                                  preferredStyle: .alert)
    alert.addTextField { (textField) in
      textField.placeholder = projectDefaultName
      textField.autocapitalizationType = .sentences
      textField.autocorrectionType = .yes
    }
    alert.addAction(UIAlertAction(title: LocalizeSystem.shared.common(.create), style: .default, handler: { (_) in
      let projectName: String = {
        if let textFieldText = alert.textFields?.first?.text, !textFieldText.isEmpty {
          return textFieldText
        } else {
          return projectDefaultName
        }
      }()
      self.createNewProject(with: projectName)
    }))
    alert.addAction(UIAlertAction(title: LocalizeSystem.shared.common(.cancel), style: .cancel, handler: { (_) in
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
  
  @objc private func purchasedTipNotificationReceived() {
    bottomBanner.constraints.forEach({ bottomBanner.removeConstraint($0) })
    bottomBanner.removeFromSuperview()
    
    NotificationCenter.default.removeObserver(self, name: .purchasedTip, object: nil)
  }
  
  @objc func addProjectButtonTapped() {
    present(imagePickerController, animated: true, completion: nil)
  }
  
  @objc private func updateTexts() {
    title = LocalizeSystem.shared.projects(.title)
    newProjectButton.setTitle("  " + LocalizeSystem.shared.root(.createButton) + "  ", for: .normal)
  }
  
  func reloadTableView() {
    tableView.reloadData()
    newProjectButton.isHidden = !viewModel.projects.isEmpty
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
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(style: .destructive, title: LocalizeSystem.shared.common(.delete)) { (_, _, _) in
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

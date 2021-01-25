//
//  SettingsViewController.swift
//  censor
//
//  Created by Maxim Skryabin on 26.10.2020.
//

import UIKit

class SettingsViewController: UIViewController {
  
  private let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.tableFooterView = UIView()
    tableView.backgroundColor = ColorManager.shared.bottomBackground
    
    tableView.register(SettingsTitleTableViewCell.self, forCellReuseIdentifier: String(describing: SettingsTitleTableViewCell.self))
    tableView.register(SettingsIconsTableViewCell.self, forCellReuseIdentifier: String(describing: SettingsIconsTableViewCell.self))
    tableView.register(SettingsTipsTableViewCell.self, forCellReuseIdentifier: String(describing: SettingsTipsTableViewCell.self))
    tableView.register(SettingsButtonTableViewCell.self, forCellReuseIdentifier: String(describing: SettingsButtonTableViewCell.self))
    
    return tableView
  }()
  
  private var dimmableNavigationController: DimmableNavigationController? {
    return navigationController as? DimmableNavigationController
  }
  
  private let viewModel = SettingsViewModel()
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    view.backgroundColor = UIColor.systemBackground
    
    setupLayout()
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
  
  private func setupNavigationBar() {
    title = NSLocalizedString("Settings", comment: "")
    
    let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonTapped))
    closeButton.tintColor = ColorManager.shared.accent
    navigationItem.rightBarButtonItem = closeButton
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  private func updateDimView(display: Bool) {
    if display {
      dimmableNavigationController?.showDimView(true, withLoading: true)
    } else {
      dimmableNavigationController?.showDimView(false, withLoading: true)
    }
  }
  
  private func restorePurchasesButtonTapped() {
    updateDimView(display: true)
    viewModel.restoreTip { [weak self] (error, success) in
      self?.updateDimView(display: false)
      if success {
        // TODO: success alert & activate features
      } else {
        self?.showAlertError(error: error,
                             desc: NSLocalizedString("Unable to restore in-app purchase", comment: ""),
                             critical: false,
                             onDismiss: nil)
      }
    }
  }
  
  @objc private func closeButtonTapped() {
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
  func reloadTableView() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.tableView.reloadData()
    }
  }
}

extension SettingsViewController: SettingsIconsTableViewCellDelegate {
  func didSelectIcon(_ iconType: SettingsManager.AppIconType) {
    SettingsManager.shared.setCustomIcon(iconType)
  }
}

extension SettingsViewController: SettingsTipsTableViewCellDelegate {
  func didTapTipButton(ofType type: SettingsTipsTableViewCellModel.TipType) {
    updateDimView(display: true)
    viewModel.purchaseTip(type) { [weak self] (error, success) in
      self?.updateDimView(display: false)
      if success {
        // TODO: success alert & activate features
      } else {
        self?.showAlertError(error: error,
                             desc: NSLocalizedString("Unable to create in-app purchase", comment: ""),
                             critical: false,
                             onDismiss: nil)
      }
    }
  }
}

extension SettingsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    guard let cellModel = viewModel.getCellModel(at: indexPath) else { return UITableView.automaticDimension }
    if cellModel is SettingsTitleTableViewCellModel {
      return 38.0
    } else if cellModel is SettingsIconsTableViewCellModel {
      return 96.0
    } else if cellModel is SettingsTipsTableViewCellModel {
      return 182.0
    } else if cellModel is SettingsButtonTableViewCellModel {
      return 44.0
    } else {
      fatalError()
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard let cellModel = viewModel.getCellModel(at: indexPath) else { return UITableView.automaticDimension }
    if cellModel is SettingsTitleTableViewCellModel {
      return UITableView.automaticDimension
    } else if cellModel is SettingsIconsTableViewCellModel {
      return 96.0
    } else if cellModel is SettingsTipsTableViewCellModel {
      return UITableView.automaticDimension
    } else if cellModel is SettingsButtonTableViewCellModel {
      return 44.0
    } else {
      fatalError()
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard let cellModel = viewModel.getCellModel(at: indexPath) else { return }
    if cellModel is SettingsButtonTableViewCellModel {
      restorePurchasesButtonTapped()
    }
  }
}

extension SettingsViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.sections[section].numberOfRows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cellModel = viewModel.getCellModel(at: indexPath) else { return UITableViewCell() }
    if let cellModel = cellModel as? SettingsTitleTableViewCellModel {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsTitleTableViewCell.self))
              as? SettingsTitleTableViewCell else { fatalError() }
      cell.update(viewModel: cellModel)
      return cell
    } else if let cellModel = cellModel as? SettingsIconsTableViewCellModel {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsIconsTableViewCell.self))
              as? SettingsIconsTableViewCell else { fatalError() }
      cell.update(viewModel: cellModel, delegate: self)
      return cell
    } else if let cellModel = cellModel as? SettingsTipsTableViewCellModel {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsTipsTableViewCell.self))
              as? SettingsTipsTableViewCell else { fatalError() }
      cell.update(viewModel: cellModel, delegate: self)
      return cell
    } else if let cellModel = cellModel as? SettingsButtonTableViewCellModel {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsButtonTableViewCell.self))
              as? SettingsButtonTableViewCell else { fatalError() }
      cell.update(viewModel: cellModel)
      return cell
    } else {
      fatalError()
    }
  }
}

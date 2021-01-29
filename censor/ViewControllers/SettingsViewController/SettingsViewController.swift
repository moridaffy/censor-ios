//
//  SettingsViewController.swift
//  censor
//
//  Created by Maxim Skryabin on 26.10.2020.
//

import UIKit

class SettingsViewController: UIViewController {
  
  // MARK: - UI elements
  
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
  
  // MARK: - Properties
  
  private let viewModel = SettingsViewModel()
  
  // MARK: - Lifecycle
  
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
  
  // MARK: - Configuring
  
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
    title = LocalizeSystem.shared.settings(.title)
    
    let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonTapped))
    closeButton.tintColor = ColorManager.shared.accent
    navigationItem.rightBarButtonItem = closeButton
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  // MARK: - Private methods
  
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
        self?.viewModel.activatePremiumFeatures()
        self?.showAlert(title: LocalizeSystem.shared.common(.done),
                        body: LocalizeSystem.shared.settings(.purchaseRestored),
                        button: LocalizeSystem.shared.common(.ok),
                        actions: nil)
      } else {
        self?.showAlertError(error: error,
                             desc: LocalizeSystem.shared.error(.cantRestorePurchase),
                             critical: false,
                             onDismiss: nil)
      }
    }
  }
  
  // MARK: - Debug methods
  
  private func activateFeaturesButtonTapped() {
    if SettingsManager.shared.isPremiumFeaturesUnlocked {
      showAlertError(error: nil,
                     desc: LocalizeSystem.shared.settings(.premiumAlreadyUnlocked),
                     critical: false)
    } else {
      SettingsManager.shared.setValue(for: .anyTipPurchased, value: true)
      showAlert(title: LocalizeSystem.shared.common(.done),
                body: LocalizeSystem.shared.settings(.premiumUnlocked),
                button: nil,
                actions: nil)
    }
  }
  
  private func deactivateFeaturesButtonTapped() {
    if SettingsManager.shared.isPremiumFeaturesUnlocked {
      SettingsManager.shared.setValue(for: .anyTipPurchased, value: false)
      showAlert(title: LocalizeSystem.shared.common(.done),
                body: LocalizeSystem.shared.settings(.premiumLocked),
                button: nil,
                actions: nil)
    } else {
      showAlertError(error: nil,
                     desc: LocalizeSystem.shared.settings(.premiumAlreadyLocked),
                     critical: false)
    }
  }
  
  private func wipeDataButtonTapped() {
    viewModel.wipeProjectsData()
    showAlert(title: LocalizeSystem.shared.common(.done),
              body: LocalizeSystem.shared.settings(.projectsDeleted),
              button: nil,
              actions: nil)
  }
  
  // MARK: - Actions
  
  @objc private func closeButtonTapped() {
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Public methods
  
  func reloadTableView() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.tableView.reloadData()
    }
  }
}

// MARK: - SettingsIconsTableViewCellDelegate

extension SettingsViewController: SettingsIconsTableViewCellDelegate {
  func didSelectIcon(_ iconType: SettingsManager.AppIconType) {
    SettingsManager.shared.setCustomIcon(iconType)
  }
}

// MARK: - SettingsTipsTableViewCellDelegate

extension SettingsViewController: SettingsTipsTableViewCellDelegate {
  func didTapTipButton(ofType type: SettingsTipsTableViewCellModel.TipType) {
    updateDimView(display: true)
    viewModel.purchaseTip(type) { [weak self] (error, success) in
      self?.updateDimView(display: false)
      if success {
        self?.viewModel.activatePremiumFeatures()
        self?.showAlert(title: LocalizeSystem.shared.settings(.purchaseCompletedTitle) + "!",
                        body: LocalizeSystem.shared.settings(.purchaseCompletedDescription),
                        button: LocalizeSystem.shared.common(.ok),
                        actions: nil)
      } else {
        self?.showAlertError(error: error,
                             desc: LocalizeSystem.shared.error(.cantPurchase),
                             critical: false,
                             onDismiss: nil)
      }
    }
  }
}

// MARK: - UITableViewDelegate

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
    if let cellModel = cellModel as? SettingsButtonTableViewCellModel {
      switch cellModel.type {
      case .restorePurchases:
        restorePurchasesButtonTapped()
      case .activateFeatures:
        activateFeaturesButtonTapped()
      case .deactivateFeatures:
        deactivateFeaturesButtonTapped()
      case .wipeData:
        wipeDataButtonTapped()
      }
    }
  }
}

// MARK: - UITableViewDataSource

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

//
//  SoundSelectorViewController.swift
//  censor
//
//  Created by Maxim Skryabin on 25.10.2020.
//

import UIKit

protocol SoundSelectorViewControllerDelegate: class {
  func didSelectSoundType(_ type: SoundManager.SoundType)
}

class SoundSelectorViewController: UIViewController {
  
  private let searchTextFieldContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.tertiarySystemBackground
    view.layer.cornerRadius = 4.0
    view.layer.masksToBounds = true
    return view
  }()
  
  private let searchIconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.image = UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate)
    imageView.tintColor = UIColor.placeholderText
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let searchTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = LocalizeSystem.shared.common(.search) + "..."
    textField.borderStyle = .none
    textField.clearButtonMode = .never
    return textField
  }()
  
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.tableFooterView = UIView()
    tableView.keyboardDismissMode = .onDrag
    
    tableView.register(SoundSelectorTableViewCell.self, forCellReuseIdentifier: String(describing: SoundSelectorTableViewCell.self))
    
    return tableView
  }()
  
  private let viewModel = SoundSelectorViewModel()
  
  private weak var delegate: SoundSelectorViewControllerDelegate?
  
  init(delegate: SoundSelectorViewControllerDelegate) {
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
    setupTableView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    viewModel.view = self
  }
  
  private func setupLayout() {
    view.addSubview(searchTextFieldContainerView)
    searchTextFieldContainerView.addSubview(searchIconImageView)
    searchTextFieldContainerView.addSubview(searchTextField)
    view.addSubview(tableView)
    
    view.addConstraints([
      searchTextFieldContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0),
      searchTextFieldContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16.0),
      searchTextFieldContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16.0),
      searchTextFieldContainerView.heightAnchor.constraint(equalToConstant: 40.0),
      
      searchIconImageView.leftAnchor.constraint(equalTo: searchTextFieldContainerView.leftAnchor, constant: 8.0),
      searchIconImageView.centerYAnchor.constraint(equalTo: searchTextFieldContainerView.centerYAnchor),
      searchIconImageView.heightAnchor.constraint(equalToConstant: 24.0),
      searchIconImageView.widthAnchor.constraint(equalToConstant: 24.0),
      
      searchTextField.leftAnchor.constraint(equalTo: searchIconImageView.rightAnchor, constant: 8.0),
      searchTextField.rightAnchor.constraint(equalTo: searchTextFieldContainerView.rightAnchor, constant: -16.0),
      searchTextField.centerYAnchor.constraint(equalTo: searchTextFieldContainerView.centerYAnchor),
      searchTextField.heightAnchor.constraint(equalToConstant: 32.0),
      
      tableView.topAnchor.constraint(equalTo: searchTextFieldContainerView.bottomAnchor, constant: 8.0),
      tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
      tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func setupNavigationBar() {
    title = LocalizeSystem.shared.editor(.selectSound)
    
    let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonTapped))
    navigationItem.rightBarButtonItem = closeButton
    
    searchTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  @objc private func closeButtonTapped() {
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
  @objc private func textFieldEditingChanged() {
    viewModel.searchText = searchTextField.text ?? ""
    viewModel.updateDisplayedSoundTypes()
  }
  
  func reloadTableView() {
    tableView.reloadData()
  }
}

extension SoundSelectorViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    delegate?.didSelectSoundType(viewModel.displayedSoundTypes[indexPath.row])
    closeButtonTapped()
  }
}

extension SoundSelectorViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.displayedSoundTypes.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SoundSelectorTableViewCell.self)) as? SoundSelectorTableViewCell else { fatalError() }
    let soundType = viewModel.displayedSoundTypes[indexPath.row]
    cell.update(soundType: soundType,
                isPlaying: viewModel.currentlyPlayingSound == soundType,
                delegate: self)
    return cell
  }
}

extension SoundSelectorViewController: SoundSelectorTableViewCellDelegate {
  func didTapPlayButton(for soundType: SoundManager.SoundType) -> Bool {
    if let currentlyPlayingSound = viewModel.currentlyPlayingSound {
      didFinishPlaying(soundType: currentlyPlayingSound)
      SoundManager.shared.finishedPlaying()
    }
    
    viewModel.currentlyPlayingSound = soundType
    SoundManager.shared.playSound(soundType)
    return true
  }
  
  func didFinishPlaying(soundType: SoundManager.SoundType) {
    viewModel.currentlyPlayingSound = nil
  }
}

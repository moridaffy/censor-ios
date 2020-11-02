//
//  SoundSelectorViewController.swift
//  censor
//
//  Created by Maxim Skryabin on 25.10.2020.
//

import UIKit

protocol SoundSelectorViewControllerDelegate: class {
  func didSelectSoundType(_ type: Sound.SoundType)
}

class SoundSelectorViewController: UIViewController {
  
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.tableFooterView = UIView()
    
    tableView.register(SoundSelectorTableViewCell.self, forCellReuseIdentifier: String(describing: SoundSelectorTableViewCell.self))
    
    return tableView
  }()
  
  private let viewModel = SoundSelectorViewModel()
  
  private weak var delegate: SoundSelectorViewControllerDelegate?
  
  init(delegate: SoundSelectorViewControllerDelegate) {
    self.delegate = delegate
    
    super.init(nibName: nil, bundle: nil)
    
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
    title = "Select sound"
    
    let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonTapped))
    navigationItem.rightBarButtonItem = closeButton
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  @objc private func closeButtonTapped() {
    navigationController?.dismiss(animated: true, completion: nil)
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
  func didTapPlayButton(for soundType: Sound.SoundType) -> Bool {
    guard viewModel.currentlyPlayingSound == nil else { return false }
    viewModel.currentlyPlayingSound = soundType
    SoundManager.shared.playSound(soundType)
    return true
  }
  
  func didFinishPlaying(soundType: Sound.SoundType) {
    viewModel.currentlyPlayingSound = nil
  }
}

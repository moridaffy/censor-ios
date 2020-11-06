//
//  EditorViewController.swift
//  censor
//
//  Created by Maxim Skryabin on 20.10.2020.
//

import AVFoundation
import UIKit

class EditorViewController: UIViewController {
  
  private let helpButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(nil, for: .normal)
    button.setImage(UIImage(systemName: "questionmark.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.contentHorizontalAlignment = .fill
    button.contentVerticalAlignment = .fill
    button.tintColor = ColorManager.shared.accent
    
    button.addConstraints([
      button.heightAnchor.constraint(equalToConstant: 24.0),
      button.widthAnchor.constraint(equalToConstant: 24.0)
    ])
    
    return button
  }()
  
  private let exportButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(nil, for: .normal)
    button.setImage(UIImage(systemName: "square.and.arrow.up")?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.contentHorizontalAlignment = .fill
    button.contentVerticalAlignment = .fill
    button.tintColor = ColorManager.shared.accent
    
    button.addConstraints([
      button.heightAnchor.constraint(equalToConstant: 24.0),
      button.widthAnchor.constraint(equalToConstant: 24.0)
    ])
    
    return button
  }()
  
  private let playerContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = ColorManager.shared.bottomBackground
    return view
  }()
  
  private let recordButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(nil, for: .normal)
    button.setImage(UIImage(systemName: "plus.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.contentHorizontalAlignment = .fill
    button.contentVerticalAlignment = .fill
    button.layer.cornerRadius = 25.0
    button.layer.masksToBounds = true
    button.layer.borderWidth = 2.0
    button.layer.borderColor = ColorManager.shared.accent.cgColor
    button.backgroundColor = ColorManager.shared.accent
    button.tintColor = ColorManager.shared.topBackground
    return button
  }()
  
  private let controlsContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = ColorManager.shared.topBackground
    return view
  }()
  
  private let videoTimelineView: VideoTimelineView = {
    let videoTimelineView = VideoTimelineView()
    videoTimelineView.translatesAutoresizingMaskIntoConstraints = false
    return videoTimelineView
  }()
  
  private let playButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(nil, for: .normal)
    button.layer.cornerRadius = 6.0
    button.layer.masksToBounds = true
    button.backgroundColor = ColorManager.shared.subtext25opacity
    button.tintColor = ColorManager.shared.accent
    return button
  }()
  
  private let controlsCollectionView: UICollectionView = {
    let collectionViewLayout = UICollectionViewFlowLayout()
    collectionViewLayout.scrollDirection = .horizontal
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = UIColor.clear
    collectionView.showsHorizontalScrollIndicator = false
    
    collectionView.register(EditorButtonCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: EditorButtonCollectionViewCell.self))
    
    return collectionView
  }()
  
  private var soundViews: [UIView] = []
  
  private let viewModel: EditorViewModel
  
  private var playerLayer: AVPlayerLayer?
  private var playerPeriodicNotificationToken: Any?
  private var playerBoundaryNotificationToken: Any?
  
  init(viewModel: EditorViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
    
    view.backgroundColor = ColorManager.shared.topBackground
    
    setupLayout()
    
    setupPlayer()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    setupButtons()
    setupCollectionView()
    
    videoTimelineView.update(project: viewModel.project, delegate: self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    viewModel.view = self
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    if viewModel.projectNeedsSaving {
      viewModel.saveProject {
        super.viewWillDisappear(animated)
      }
    } else {
      super.viewWillDisappear(animated)
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    playerLayer?.frame = playerContainerView.bounds
  }
  
  private func setupLayout() {
    view.addSubview(playerContainerView)
    view.addSubview(controlsContainerView)
    controlsContainerView.addSubview(videoTimelineView)
    controlsContainerView.addSubview(playButton)
    controlsContainerView.addSubview(controlsCollectionView)
    view.addSubview(recordButton)
    
    view.addConstraints([
      playerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      playerContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
      playerContainerView.rightAnchor.constraint(equalTo: view.rightAnchor),
      playerContainerView.bottomAnchor.constraint(equalTo: controlsContainerView.topAnchor),
      
      controlsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
      controlsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor),
      controlsContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      
      videoTimelineView.topAnchor.constraint(equalTo: controlsContainerView.topAnchor, constant: 12.0),
      videoTimelineView.leftAnchor.constraint(equalTo: controlsContainerView.leftAnchor, constant: 16.0),
      videoTimelineView.rightAnchor.constraint(equalTo: controlsContainerView.rightAnchor, constant: -16.0),
      videoTimelineView.heightAnchor.constraint(equalToConstant: VideoTimelineView.height),
      
      playButton.topAnchor.constraint(equalTo: videoTimelineView.bottomAnchor, constant: 8.0 + 22.0),
      playButton.leftAnchor.constraint(equalTo: videoTimelineView.leftAnchor),
      playButton.heightAnchor.constraint(equalToConstant: 40.0),
      playButton.widthAnchor.constraint(equalToConstant: 40.0),
      
      controlsCollectionView.topAnchor.constraint(equalTo: playButton.topAnchor),
      controlsCollectionView.bottomAnchor.constraint(equalTo: playButton.bottomAnchor),
      controlsCollectionView.leftAnchor.constraint(equalTo: playButton.rightAnchor, constant: 8.0),
      controlsCollectionView.rightAnchor.constraint(equalTo: videoTimelineView.rightAnchor),
      controlsCollectionView.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -16.0),
      
      recordButton.heightAnchor.constraint(equalToConstant: 50.0),
      recordButton.widthAnchor.constraint(equalToConstant: 50.0),
      recordButton.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor, constant: -16.0),
      recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
    
    addedSoundsUpdated()
  }
  
  private func setupNavigationBar() {
    title = viewModel.project.name
    
    let rightBarButtonView = UIStackView(arrangedSubviews: [helpButton, exportButton])
    rightBarButtonView.translatesAutoresizingMaskIntoConstraints = false
    rightBarButtonView.axis = .horizontal
    rightBarButtonView.distribution = .equalSpacing
    rightBarButtonView.spacing = 16.0
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButtonView)
  }
  
  private func setupButtons() {
    helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
    exportButton.addTarget(self, action: #selector(exportButtonTapped), for: .touchUpInside)
    recordButton.addTarget(self, action: #selector(recordButtonPressed), for: .touchDown)
    playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
    
    updatePlayButton()
  }
  
  private func setupCollectionView() {
    controlsCollectionView.delegate = self
    controlsCollectionView.dataSource = self
  }
  
  private func setupPlayer() {
    let inputUrlResponse = StorageManager.shared.getInputUrl(forProject: viewModel.project)
    guard let inputUrl = inputUrlResponse.0 else {
      showAlertError(error: inputUrlResponse.1,
                     desc: "Unable to play video",
                     critical: false)
      return
    }
    
    let player = AVPlayer(url: inputUrl)
    let playerLayer = AVPlayerLayer(player: player)
    playerContainerView.layer.addSublayer(playerLayer)
    self.playerLayer = playerLayer
    playerLayer.player?.play()
    
    setupPeriodicTimeObserver()
    setupBoundaryTimeObserver()
  }
  
  private func setupPeriodicTimeObserver() {
    let notificationTime = CMTime(seconds: VideoTimelineView.refreshInterval, preferredTimescale: viewModel.preferredTimescale)
    playerPeriodicNotificationToken = playerLayer?.player?.addPeriodicTimeObserver(forInterval: notificationTime, queue: .main, using: { [weak self] (time) in
      guard let self = self else { return }
      self.updateVideoProgress(with: time.seconds)
      if time.seconds == self.viewModel.project.duration {
        self.viewModel.isPlayingVideo = false
      }
    })
  }
  
  private func setupBoundaryTimeObserver() {
    if let playerBoundaryNotificationToken = playerBoundaryNotificationToken {
      playerLayer?.player?.removeTimeObserver(playerBoundaryNotificationToken)
      self.playerBoundaryNotificationToken = nil
    }
    
    guard !viewModel.addedSounds.isEmpty else { return }
    let boundaryTimes: [NSValue] = viewModel.addedSounds
      .compactMap({ NSValue(time: CMTime(seconds: $0.timestamp, preferredTimescale: viewModel.preferredTimescale)) })
    playerBoundaryNotificationToken = playerLayer?.player?.addBoundaryTimeObserver(forTimes: boundaryTimes, queue: .main, using: { [weak self] in
      self?.playAddedSound()
    })
  }
  
  private func updateVideoProgress(with time: Double) {
    videoTimelineView.updateProgress(withValue: Float(time / viewModel.project.duration))
  }
  
  private func playAddedSound() {
    let sound = viewModel.addedSounds[viewModel.currentSoundIndex]
    SoundManager.shared.playSound(sound.type)
    viewModel.currentSoundIndex += 1
  }
  
  private func getSoundView(for sound: Sound, at index: Int) -> UIView {
    let completionPercent = CGFloat(sound.timestamp / viewModel.project.duration)
    let soundViewLeftConstant = (UIScreen.main.bounds.width - 16.0 - 16.0) * completionPercent - VideoTimelineSoundView.width / 2.0
    
    let soundView = VideoTimelineSoundView(index: index + 1)
    soundView.translatesAutoresizingMaskIntoConstraints = false
    soundView.isUserInteractionEnabled = true
    
    controlsContainerView.addSubview(soundView)
    controlsContainerView.addConstraints([
      soundView.widthAnchor.constraint(equalToConstant: VideoTimelineSoundView.width),
      soundView.heightAnchor.constraint(equalToConstant: VideoTimelineSoundView.height),
      soundView.leftAnchor.constraint(equalTo: videoTimelineView.leftAnchor, constant: soundViewLeftConstant),
      soundView.topAnchor.constraint(equalTo: videoTimelineView.bottomAnchor, constant: -1.0 * VideoTimelineView.height / 4.0)
    ])
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(soundViewTapped))
    soundView.addGestureRecognizer(tapGestureRecognizer)
    
    return soundView
  }
  
  private func resetPlayer() {
    viewModel.currentSoundIndex = 0
    playerLayer?.player?.pause()
    playerLayer?.player?.seek(to: CMTime.zero)
    viewModel.isPlayingVideo = false
  }
  
  @objc private func helpButtonTapped() {
    // TODO
  }
  
  @objc private func exportButtonTapped() {
    // TODO: show rendering progress
    // https://stackoverflow.com/questions/11090760/progress-bar-for-avassetexportsession
    
    resetPlayer()
    (navigationController as? DimmableNavigationController)?.showDimView(true, withLoading: true)
    
    viewModel.renderProject { (error) in
      DispatchQueue.main.async { [weak self] in
        (self?.navigationController as? DimmableNavigationController)?.showDimView(false, withLoading: true)
        if let error = error {
          self?.showAlertError(error: error,
                               desc: "Failed to render video",
                               critical: false)
        } else {
          let popAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self?.navigationController?.popViewController(animated: true)
          }
          self?.showAlert(title: "Done",
                          body: "Video has been successfully rendered and saved to photo library",
                          button: nil,
                          actions: [popAction])
        }
      }
    }
  }
  
  @objc private func playButtonTapped() {
    if viewModel.isPlayingVideo {
      playerLayer?.player?.pause()
    } else {
      if playerLayer?.player?.currentTime().seconds == viewModel.project.duration {
        resetPlayer()
      }
      playerLayer?.player?.play()
    }
    viewModel.isPlayingVideo = !viewModel.isPlayingVideo
  }
  
  @objc private func audioModeButtonTapped() {
    viewModel.selectedAudioMode = viewModel.selectedAudioMode.anotherMode
//    audioModeButton.setImage(UIImage(systemName: viewModel.selectedAudioMode.iconSystemName), for: .normal)
  }
  
  private func soundSelectorButtonTapped() {
    let soundSelectorViewController = SoundSelectorViewController(delegate: self)
    present(soundSelectorViewController.embedInNavigationController(), animated: true, completion: nil)
  }
  
  @objc private func recordButtonPressed() {
    guard let timestamp = playerLayer?.player?.currentTime().seconds else { fatalError() }
    viewModel.addSound(at: timestamp)
  }
  
  @objc private func soundViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
    guard let soundIndex = gestureRecognizer.view?.tag else { fatalError() }
    viewModel.addedSounds.remove(at: soundIndex - 1)
    resetPlayer()
  }
  
  func addedSoundsUpdated() {
    for oldView in soundViews {
      controlsContainerView.willRemoveSubview(oldView)
      oldView.removeFromSuperview()
    }
    soundViews.removeAll()
    
    for i in 0..<viewModel.addedSounds.count {
      let soundView = getSoundView(for: viewModel.addedSounds[i], at: i)
      soundViews.append(soundView)
    }
    
    setupBoundaryTimeObserver()
  }
  
  func updatePlayButton() {
    playButton.setImage(UIImage(systemName: viewModel.isPlayingVideo ? "pause.fill" : "play.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
  }
}

extension EditorViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cellModel = viewModel.controlCellModels[indexPath.row]
    switch cellModel.type {
    case .soundSelection:
      soundSelectorButtonTapped()
    case .export:
      exportButtonTapped()
    }
  }
}

extension EditorViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellModel = viewModel.controlCellModels[indexPath.row]
    let cellHeight: CGFloat = 40.0
    let textWidth = cellModel.text.width(height: cellHeight, attributes: [.font: EditorButtonCollectionViewCell.textFont])
    return CGSize(width: 8.0 + EditorButtonCollectionViewCell.iconSide + 8.0 + textWidth + 8.0, height: cellHeight)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 8.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 8.0
  }
}

extension EditorViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.controlCellModels.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: EditorButtonCollectionViewCell.self), for: indexPath)
            as? EditorButtonCollectionViewCell else { fatalError() }
    cell.update(viewModel: viewModel.controlCellModels[indexPath.row])
    return cell
  }
}

extension EditorViewController: VideoTimelineViewDelegate {
  func didChangeProgress(toValue value: Float) {
    if viewModel.isPlayingVideo {
      viewModel.isPlayingVideo = false
      playerLayer?.player?.pause()
    }
    
    let newTime = Double(value) * viewModel.project.duration
    playerLayer?.player?.seek(to: CMTime(seconds: newTime, preferredTimescale: viewModel.preferredTimescale))
  }
}

extension EditorViewController: SoundSelectorViewControllerDelegate {
  func didSelectSoundType(_ type: Sound.SoundType) {
    viewModel.selectedSoundType = type
    if let soundSelectionButtonIndex = viewModel.controlCellModels.firstIndex(where: { $0.type == .soundSelection }) {
      viewModel.controlCellModels[soundSelectionButtonIndex].text = type.title
      controlsCollectionView.reloadItems(at: [IndexPath(row: soundSelectionButtonIndex, section: 0)])
    }
  }
}

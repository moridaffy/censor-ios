//
//  EditorViewController.swift
//  censor
//
//  Created by Maxim Skryabin on 20.10.2020.
//

import AVFoundation
import UIKit

class EditorViewController: UIViewController {
  
  private let playerContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.black
    return view
  }()
  
  private let controlsContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.systemGray6
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
    button.backgroundColor = UIColor.tertiarySystemBackground
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
  
  private let recordButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("-", for: .normal)
    button.setTitle("+", for: .highlighted)
    button.setTitleColor(UIColor.white, for: .normal)
    button.setTitleColor(UIColor.white, for: .highlighted)
    button.layer.cornerRadius = 25.0
    button.layer.masksToBounds = true
    button.layer.borderColor = UIColor.white.cgColor
    button.layer.borderWidth = 1.0
    button.backgroundColor = UIColor.red
    return button
  }()
  
  private var soundViews: [UIView] = []
  
  private let viewModel: EditorViewModel
  
  private var playerLayer: AVPlayerLayer?
  private var playerPeriodicNotificationToken: Any?
  private var playerBoundaryNotificationToken: Any?
  
  init(viewModel: EditorViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
    
    view.backgroundColor = .systemGray6
    
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
      
      playButton.topAnchor.constraint(equalTo: videoTimelineView.bottomAnchor, constant: 8.0),
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
      recordButton.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor, constant: -32.0),
      recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
    
    addedSoundsUpdated()
  }
  
  private func setupNavigationBar() {
    title = viewModel.project.name
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(exportButtonTapped))
  }
  
  private func setupButtons() {
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
    // TODO: Create new sound views for new VideoTimelineView
    let viewSize = CGSize(width: 20.0, height: 20.0)
    let completionPercent = CGFloat(sound.timestamp / viewModel.project.duration)
    let soundViewLeftConstant = (UIScreen.main.bounds.width - 16.0 - 16.0) * completionPercent - viewSize.width / 2.0
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(soundViewTapped))
    
    let label = UILabel(frame: .zero)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.backgroundColor = UIColor.red
    label.text = String(index + 1)
    label.textAlignment = .center
    label.textColor = UIColor.white
    label.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
    label.layer.cornerRadius = viewSize.width / 2.0
    label.layer.masksToBounds = true
    label.tag = index + 1
    label.isUserInteractionEnabled = true
    label.addGestureRecognizer(tapGestureRecognizer)

    controlsContainerView.addSubview(label)
    controlsContainerView.addConstraints([
      label.widthAnchor.constraint(equalToConstant: viewSize.width),
      label.heightAnchor.constraint(equalToConstant: viewSize.height),
      label.centerYAnchor.constraint(equalTo: videoTimelineView.centerYAnchor),
      label.leftAnchor.constraint(equalTo: videoTimelineView.leftAnchor, constant: soundViewLeftConstant)
    ])
    
    return label
  }
  
  private func resetPlayer() {
    viewModel.currentSoundIndex = 0
    playerLayer?.player?.pause()
    playerLayer?.player?.seek(to: CMTime.zero)
    viewModel.isPlayingVideo = false
  }
  
  @objc private func exportButtonTapped() {
    resetPlayer()
    // TODO: block UI while rendering video
    // TODO: show rendering progress
    
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

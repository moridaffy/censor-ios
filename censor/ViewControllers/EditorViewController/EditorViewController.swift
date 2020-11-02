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
    button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
    return button
  }()
  
  private let audioModeButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(nil, for: .normal)
    return button
  }()
  
  private let soundSelectorButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(nil, for: .normal)
    button.setImage(UIImage(systemName: "music.note"), for: .normal)
    return button
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
  
  private let saveButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(nil, for: .normal)
    button.setImage(UIImage(systemName: "archivebox"), for: .normal)
    return button
  }()
  
  private let exportButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(nil, for: .normal)
    button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
    return button
  }()
  
  private let rightBarButtonItemView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    return view
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
    
    videoTimelineView.update(project: viewModel.project, delegate: self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    viewModel.view = self
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    playerLayer?.frame = playerContainerView.bounds
  }
  
  private func setupLayout() {
    let controlButtonSide: CGFloat = 40.0
    let controlButtonsStackView = UIStackView(arrangedSubviews: [playButton, audioModeButton, soundSelectorButton])
    controlButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
    controlButtonsStackView.spacing = 16.0
    controlButtonsStackView.distribution = .equalSpacing
    
    view.addSubview(playerContainerView)
    view.addSubview(controlsContainerView)
    controlsContainerView.addSubview(videoTimelineView)
    controlsContainerView.addSubview(controlButtonsStackView)
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
      
      controlButtonsStackView.topAnchor.constraint(equalTo: videoTimelineView.bottomAnchor, constant: 12.0),
      controlButtonsStackView.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
      controlButtonsStackView.heightAnchor.constraint(equalToConstant: controlButtonSide),
      controlButtonsStackView.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -16.0),
      
      recordButton.heightAnchor.constraint(equalToConstant: 50.0),
      recordButton.widthAnchor.constraint(equalToConstant: 50.0),
      recordButton.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor, constant: -32.0),
      recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
    
    addedSoundsUpdated()
  }
  
  private func setupNavigationBar() {
    title = viewModel.project.name
    
    rightBarButtonItemView.addSubview(saveButton)
    rightBarButtonItemView.addSubview(exportButton)
    
    rightBarButtonItemView.addConstraints([
      saveButton.topAnchor.constraint(equalTo: rightBarButtonItemView.topAnchor),
      saveButton.leftAnchor.constraint(equalTo: rightBarButtonItemView.leftAnchor),
      saveButton.bottomAnchor.constraint(equalTo: rightBarButtonItemView.bottomAnchor),
      saveButton.widthAnchor.constraint(equalToConstant: 24.0),
      saveButton.heightAnchor.constraint(equalToConstant: 24.0),
      
      exportButton.leftAnchor.constraint(equalTo: saveButton.rightAnchor, constant: 16.0),
      exportButton.topAnchor.constraint(equalTo: rightBarButtonItemView.topAnchor),
      exportButton.rightAnchor.constraint(equalTo: rightBarButtonItemView.rightAnchor),
      exportButton.bottomAnchor.constraint(equalTo: rightBarButtonItemView.bottomAnchor),
      exportButton.heightAnchor.constraint(equalTo: saveButton.heightAnchor),
      exportButton.widthAnchor.constraint(equalTo: saveButton.widthAnchor)
    ])
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButtonItemView)
    
    saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    exportButton.addTarget(self, action: #selector(exportButtonTapped), for: .touchUpInside)
  }
  
  private func setupButtons() {
    recordButton.addTarget(self, action: #selector(recordButtonPressed), for: .touchDown)
    playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
    audioModeButton.addTarget(self, action: #selector(audioModeButtonTapped), for: .touchUpInside)
    soundSelectorButton.addTarget(self, action: #selector(soundSelectorButtonTapped), for: .touchUpInside)
    
    audioModeButton.setImage(UIImage(systemName: viewModel.selectedAudioMode.iconSystemName), for: .normal)
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
  
  @objc private func saveButtonTapped() {
    let project = viewModel.project
    project.sounds = viewModel.addedSounds
    StorageManager.shared.saveProject(project, completionHandler: nil)
  }
  
  @objc private func exportButtonTapped() {
    // TODO: block UI while rendering video
    // TODO: show rendering progress
    viewModel.renderProject { (error) in
      DispatchQueue.main.async { [weak self] in
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
        viewModel.currentSoundIndex = 0
        playerLayer?.player?.seek(to: CMTime.zero)
      }
      playerLayer?.player?.play()
    }
    viewModel.isPlayingVideo = !viewModel.isPlayingVideo
  }
  
  @objc private func audioModeButtonTapped() {
    viewModel.selectedAudioMode = viewModel.selectedAudioMode.anotherMode
    audioModeButton.setImage(UIImage(systemName: viewModel.selectedAudioMode.iconSystemName), for: .normal)
  }
  
  @objc private func soundSelectorButtonTapped() {
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
    viewModel.currentSoundIndex -= 1
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
  }
}

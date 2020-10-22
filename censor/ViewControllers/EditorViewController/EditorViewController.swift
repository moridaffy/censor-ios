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
  
  private let videoProgressLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor.white
    label.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
    return label
  }()
  
  private let videoProgressView: UIProgressView = {
    let progressView = UIProgressView()
    progressView.translatesAutoresizingMaskIntoConstraints = false
    return progressView
  }()
  
  private let controlButtonsContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.clear
    return view
  }()
  
  private let restartButton: UIButton = {
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
  
  private var soundViews: [UIView] = []
  
  private let viewModel: EditorViewModel
  
  private var playerLayer: AVPlayerLayer?
  private var playerNotificationToken: Any?
  
  init(viewModel: EditorViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
    
    view.backgroundColor = .systemGray6
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    setupButtons()
    setupPlayer()
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
    
    view.addSubview(playerContainerView)
    view.addSubview(controlsContainerView)
    controlsContainerView.addSubview(videoProgressLabel)
    controlsContainerView.addSubview(videoProgressView)
    controlsContainerView.addSubview(controlButtonsContainerView)
    controlButtonsContainerView.addSubview(restartButton)
    controlButtonsContainerView.addSubview(audioModeButton)
    controlButtonsContainerView.addSubview(soundSelectorButton)
    view.addSubview(recordButton)
    
    view.addConstraints([
      playerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      playerContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
      playerContainerView.rightAnchor.constraint(equalTo: view.rightAnchor),
      playerContainerView.bottomAnchor.constraint(equalTo: controlsContainerView.topAnchor),
      
      controlsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
      controlsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor),
      controlsContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      controlsContainerView.heightAnchor.constraint(equalToConstant: 100.0),
      
      videoProgressLabel.topAnchor.constraint(equalTo: controlsContainerView.topAnchor, constant: 16.0),
      videoProgressLabel.leftAnchor.constraint(equalTo: controlsContainerView.leftAnchor, constant: 16.0),
      videoProgressLabel.widthAnchor.constraint(equalToConstant: 60.0),
      videoProgressLabel.heightAnchor.constraint(equalToConstant: 15.0),
      
      videoProgressView.centerYAnchor.constraint(equalTo: videoProgressLabel.centerYAnchor),
      videoProgressView.leftAnchor.constraint(equalTo: videoProgressLabel.rightAnchor),
      videoProgressView.rightAnchor.constraint(equalTo: controlsContainerView.rightAnchor, constant: -16.0),
      
      controlButtonsContainerView.topAnchor.constraint(equalTo: videoProgressView.bottomAnchor, constant: 16.0),
      controlButtonsContainerView.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
      controlButtonsContainerView.heightAnchor.constraint(equalToConstant: controlButtonSide),
      
      audioModeButton.centerXAnchor.constraint(equalTo: controlButtonsContainerView.centerXAnchor),
      audioModeButton.centerYAnchor.constraint(equalTo: controlButtonsContainerView.centerYAnchor),
      audioModeButton.heightAnchor.constraint(equalToConstant: controlButtonSide),
      audioModeButton.widthAnchor.constraint(equalToConstant: controlButtonSide),
      
      restartButton.centerYAnchor.constraint(equalTo: audioModeButton.centerYAnchor),
      restartButton.leftAnchor.constraint(equalTo: controlButtonsContainerView.leftAnchor),
      restartButton.rightAnchor.constraint(equalTo: audioModeButton.leftAnchor, constant: -8.0),
      restartButton.heightAnchor.constraint(equalToConstant: controlButtonSide),
      restartButton.widthAnchor.constraint(equalToConstant: controlButtonSide),
      
      soundSelectorButton.centerYAnchor.constraint(equalTo: audioModeButton.centerYAnchor),
      soundSelectorButton.leftAnchor.constraint(equalTo: restartButton.rightAnchor, constant: 8.0),
      soundSelectorButton.rightAnchor.constraint(equalTo: controlButtonsContainerView.rightAnchor),
      soundSelectorButton.heightAnchor.constraint(equalToConstant: controlButtonSide),
      soundSelectorButton.widthAnchor.constraint(equalToConstant: controlButtonSide),
      
      recordButton.heightAnchor.constraint(equalToConstant: 50.0),
      recordButton.widthAnchor.constraint(equalToConstant: 50.0),
      recordButton.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor, constant: -32.0),
      recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
  }
  
  private func setupNavigationBar() {
    title = viewModel.project.name
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                                                        style: .done,
                                                        target: self,
                                                        action: #selector(exportButtonTapped))
  }
  
  private func setupButtons() {
    recordButton.addTarget(self, action: #selector(recordButtonPressed), for: .touchDown)
    restartButton.addTarget(self, action: #selector(restartButtonTapped), for: .touchUpInside)
    audioModeButton.addTarget(self, action: #selector(audioModeButtonTapped), for: .touchUpInside)
    soundSelectorButton.addTarget(self, action: #selector(soundSelectorButtonTapped), for: .touchUpInside)
    
    audioModeButton.setImage(UIImage(systemName: viewModel.selectedAudioMode.iconSystemName), for: .normal)
  }
  
  private func setupPlayer() {
    let player = AVPlayer(url: viewModel.project.originalUrl)
    let playerLayer = AVPlayerLayer(player: player)
    playerContainerView.layer.addSublayer(playerLayer)
    self.playerLayer = playerLayer
    playerLayer.player?.play()
    
    setupPeriodicTimeObserver()
  }
  
  private func setupPeriodicTimeObserver() {
    let notificationTime = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    playerNotificationToken = playerLayer?.player?.addPeriodicTimeObserver(forInterval: notificationTime, queue: .main, using: { [weak self] (time) in
      guard let self = self else { return }
      self.updateVideoProgress(with: time.seconds)
    })
  }
  
  private func setupBoundaryTimeObserver() {
    // TODO: setup playing previously added sounds on video playback
  }
  
  private func updateVideoProgress(with time: Double) {
    videoProgressLabel.text = viewModel.getProgressTimeString(for: time)
    videoProgressView.progress = Float(time / viewModel.project.duration)
  }
  
  private func getSoundView(for sound: Sound, at index: Int) -> UIView {
    let completionPercent = CGFloat(sound.timestamp / viewModel.project.duration)
    
    let viewSize = CGSize(width: 20.0, height: 20.0)
    let xOffset: CGFloat = viewSize.width / 2.0
    let yOffest = viewSize.height / 2.0
    let viewOrigin = CGPoint(x: videoProgressView.frame.minX + videoProgressView.frame.size.width * completionPercent - xOffset,
                             y: videoProgressView.frame.midY - yOffest)
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(soundViewTapped))
    
    let label = UILabel(frame: CGRect(origin: viewOrigin, size: viewSize))
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
    return label
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
  
  @objc private func restartButtonTapped() {
    playerLayer?.player?.seek(to: CMTime.zero)
    playerLayer?.player?.play()
  }
  
  @objc private func audioModeButtonTapped() {
    viewModel.selectedAudioMode = viewModel.selectedAudioMode.anotherMode
    audioModeButton.setImage(UIImage(systemName: viewModel.selectedAudioMode.iconSystemName), for: .normal)
  }
  
  @objc private func soundSelectorButtonTapped() {
    // TODO: display sound selection screen
  }
  
  @objc private func recordButtonPressed() {
    guard let timestamp = playerLayer?.player?.currentTime().seconds else { fatalError() }
    viewModel.addSound(at: timestamp)
  }
  
  @objc private func soundViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
    guard let soundIndex = gestureRecognizer.view?.tag else { fatalError() }
    viewModel.addedSounds.remove(at: soundIndex - 1)
  }
  
  func addedSoundsUpdated() {
    for oldView in soundViews {
      controlsContainerView.willRemoveSubview(oldView)
      oldView.removeFromSuperview()
    }
    soundViews.removeAll()
    
    for i in 0..<viewModel.addedSounds.count {
      let soundView = getSoundView(for: viewModel.addedSounds[i], at: i)
      soundView.willMove(toSuperview: controlsContainerView)
      controlsContainerView.addSubview(soundView)
      soundViews.append(soundView)
    }
  }
}

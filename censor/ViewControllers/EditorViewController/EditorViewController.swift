//
//  EditorViewController.swift
//  censor
//
//  Created by Maxim Skryabin on 20.10.2020.
//

import Instructions
import AVFoundation
import UIKit

class EditorViewController: UIViewController {
  
  // MARK: - UI Elements
  
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
  
  private let controlsCollectionContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.clear
    return view
  }()
  
  private let controlsCollectionView: UICollectionView = {
    let collectionViewLayout = UICollectionViewFlowLayout()
    collectionViewLayout.scrollDirection = .horizontal
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = UIColor.clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 16.0)
    
    collectionView.register(EditorButtonCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: EditorButtonCollectionViewCell.self))
    
    return collectionView
  }()
  
  // MARK: - Properties
  
  private let viewModel: EditorViewModel
  private let coachMarksController = CoachMarksController()
  
  private var soundViews: [UIView] = []
  
  private var controlsFadeLayer: CAGradientLayer?
  private var playerLayer: AVPlayerLayer?
  private var playerPeriodicNotificationToken: Any?
  private var playerBoundaryNotificationToken: Any?
  
  private var dimmableNavigationController: DimmableNavigationController? {
    return navigationController as? DimmableNavigationController
  }
  
  // MARK: - Lifecycle
  
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
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    setupCollectionViewFading()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    viewModel.view = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    setupCoachMarkers()
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
  
  // MARK: - Configuring
  
  private func setupLayout() {
    view.addSubview(playerContainerView)
    view.addSubview(controlsContainerView)
    controlsContainerView.addSubview(videoTimelineView)
    controlsContainerView.addSubview(playButton)
    controlsContainerView.addSubview(controlsCollectionContainerView)
    controlsCollectionContainerView.addSubview(controlsCollectionView)
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
      
      controlsCollectionContainerView.topAnchor.constraint(equalTo: playButton.topAnchor),
      controlsCollectionContainerView.bottomAnchor.constraint(equalTo: playButton.bottomAnchor),
      controlsCollectionContainerView.leftAnchor.constraint(equalTo: playButton.rightAnchor),
      controlsCollectionContainerView.rightAnchor.constraint(equalTo: controlsContainerView.rightAnchor, constant: -8.0),
      controlsCollectionContainerView.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -16.0),
      
      controlsCollectionView.topAnchor.constraint(equalTo: controlsCollectionContainerView.topAnchor),
      controlsCollectionView.leftAnchor.constraint(equalTo: controlsCollectionContainerView.leftAnchor),
      controlsCollectionView.rightAnchor.constraint(equalTo: controlsCollectionContainerView.rightAnchor),
      controlsCollectionView.bottomAnchor.constraint(equalTo: controlsCollectionContainerView.bottomAnchor),
      
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
  
  private func setupCollectionViewFading() {
    if let controlsFadeLayer = controlsFadeLayer {
      controlsFadeLayer.frame = controlsCollectionContainerView.bounds
    } else {
      let controlsFadeLayer = CAGradientLayer()
      controlsFadeLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
      controlsFadeLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
      controlsFadeLayer.frame = controlsCollectionContainerView.bounds
      controlsFadeLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
      controlsFadeLayer.locations = [0.0, 0.025, 0.975, 1.0]
      controlsCollectionContainerView.layer.mask = controlsFadeLayer
      self.controlsFadeLayer = controlsFadeLayer
    }
  }
  
  private func setupPlayer() {
    let inputUrlResponse = StorageManager.shared.getInputUrl(forProject: viewModel.project)
    guard let inputUrl = inputUrlResponse.0 else {
      showAlertError(error: inputUrlResponse.1,
                     desc: LocalizeSystem.shared.error(.cantPlayVideo),
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
  
  private func setupCoachMarkers() {
    coachMarksController.dataSource = self
    coachMarksController.delegate = self
    coachMarksController.overlay.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    
    let coachMarkersDisplayed = SettingsManager.shared.getValue(of: Bool.self, for: .coachMarkersDisplayed) ?? false
    if !coachMarkersDisplayed {
      showTutorialAlert()
    }
  }
  
  // MARK: - Private methods
  
  private func showTutorialAlert() {
    let yesAction = UIAlertAction(title: LocalizeSystem.shared.editor(.hintsAlertYes), style: .default) { (_) in
      self.helpButtonTapped()
    }
    let noAction = UIAlertAction(title: LocalizeSystem.shared.editor(.hintsAlertNo), style: .destructive, handler: nil)
    showAlert(title: LocalizeSystem.shared.editor(.hintsAlertTitle),
              body: LocalizeSystem.shared.editor(.hintsAlertDescription),
              button: nil, actions: [yesAction, noAction])
  }
  
  private func updateVideoProgress(with time: Double) {
    videoTimelineView.updateProgress(withValue: Float(time / viewModel.project.duration))
  }
  
  private func playAddedSound() {
    guard let sound = viewModel.getSound(at: viewModel.currentSoundIndex) else { return }
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
  
  private func updateDimView(display: Bool) {
    if display {
      dimmableNavigationController?.showDimView(true, withLoading: true)
      updateRenderingProgressNotifications(subscribe: true)
    } else {
      dimmableNavigationController?.showDimView(false, withLoading: true)
      updateRenderingProgressNotifications(subscribe: false)
    }
  }
  
  private func updateRenderingProgressNotifications(subscribe: Bool) {
    if subscribe {
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(renderingProgressUpdatedNotificationReceived(_:)),
                                             name: .renderingProgressUpdated,
                                             object: nil)
    } else {
      NotificationCenter.default.removeObserver(self,
                                                name: .renderingProgressUpdated,
                                                object: nil)
    }
  }
  
  private func openSoundSelectorViewController() {
    let soundSelectorViewController = SoundSelectorViewController(delegate: self)
    present(soundSelectorViewController.embedInNavigationController(), animated: true, completion: nil)
  }
  
  private func openAudioModeSelectorViewController() {
    let audioModeSelectorViewModel = AudioModeSelectorViewModel(audioMode: viewModel.selectedAudioMode)
    let audioModeSelectorViewController = AudioModeSelectorViewController(viewModel: audioModeSelectorViewModel, delegate: self)
    present(audioModeSelectorViewController.embedInNavigationController(), animated: true, completion: nil)
  }
  
  private func updateSelectedAudioMode(to newValue: VideoRenderer.AudioMode) {
    viewModel.selectedAudioMode = newValue
    if let modeSelectionButtonIndex = viewModel.controlCellModels.firstIndex(where: { $0.type == .audioMode(selectedMode: newValue) }) {
      controlsCollectionView.reloadItems(at: [IndexPath(row: modeSelectionButtonIndex, section: 0)])
    }
  }
  
  private func showShareOptions(_ outputUrl: URL) {
    let activityItems: [Any] = [outputUrl, LocalizeSystem.shared.editor(.videoRendered)]
    let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    
    activityController.completionWithItemsHandler = { [weak self] _, success, _, error in
      guard !success else { return }
      self?.showAlertError(error: error,
                           desc: LocalizeSystem.shared.error(.cantRenderVideo),
                           critical: false)
    }
    
    activityController.popoverPresentationController?.sourceView = view
    activityController.popoverPresentationController?.sourceRect = view.frame
    
    self.present(activityController, animated: true, completion: nil)
  }
  
  // MARK: - Actions
  
  @objc private func helpButtonTapped() {
    generateHints()
    controlsCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
    coachMarksController.start(in: .window(over: self))
  }
  
  @objc private func exportButtonTapped() {
    resetPlayer()
    updateDimView(display: true)
    
    viewModel.renderProject { (error, outputUrl) in
      DispatchQueue.main.async { [weak self] in
        self?.updateDimView(display: false)
        if let outputUrl = outputUrl {
          self?.showShareOptions(outputUrl)
        } else {
          self?.showAlertError(error: error,
                               desc: LocalizeSystem.shared.error(.cantRenderVideo),
                               critical: false)
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
  
  @objc private func recordButtonPressed() {
    guard let timestamp = playerLayer?.player?.currentTime().seconds else { fatalError() }
    viewModel.addSound(at: timestamp)
  }
  
  @objc private func soundViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
    guard let soundIndex = gestureRecognizer.view?.tag else { fatalError() }
    viewModel.addedSounds.remove(at: soundIndex - 1)
    resetPlayer()
  }
  
  @objc private func renderingProgressUpdatedNotificationReceived(_ notification: Notification) {
    guard let progress = notification.userInfo?["progress"] as? Double else { return }
    let percentProgress = Int(progress * 100.0)
    dimmableNavigationController?.updateProgress(with: percentProgress)
  }
  
  // MARK: - Public methods
  
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

// MARK: - UICollectionViewDelegate

extension EditorViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cellModel = viewModel.controlCellModels[indexPath.row]
    switch cellModel.type {
    case .audioMode:
      openAudioModeSelectorViewController()
    case .soundSelection:
      openSoundSelectorViewController()
    case .export:
      exportButtonTapped()
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

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

// MARK: - UICollectionViewDataSource

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

// MARK: - VideoTimelineViewDelegate

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

// MARK: - AudioModeSelectorViewControllerDelegate

extension EditorViewController: AudioModeSelectorViewControllerDelegate {
  func didSelectAudioMode(_ audioMode: VideoRenderer.AudioMode) {
    viewModel.selectedAudioMode = audioMode
    if let modeSelectionButtonIndex = viewModel.controlCellModels.firstIndex(where: { $0.type == .audioMode(selectedMode: audioMode) }) {
      controlsCollectionView.reloadItems(at: [IndexPath(row: modeSelectionButtonIndex, section: 0)])
    }
  }
}

// MARK: - SoundSelectorViewControllerDelegate

extension EditorViewController: SoundSelectorViewControllerDelegate {
  func didSelectSoundType(_ type: SoundManager.SoundType) {
    viewModel.selectedSoundType = type
    if let soundSelectionButtonIndex = viewModel.controlCellModels.firstIndex(where: { $0.type == .soundSelection }) {
      controlsCollectionView.reloadItems(at: [IndexPath(row: soundSelectionButtonIndex, section: 0)])
    }
  }
}

// MARK: - CoachMarksControllerDataSource

extension EditorViewController: CoachMarksControllerDataSource {
  func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
    return viewModel.displayedHints.count
  }
  
  func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
    return coachMarksController.helper.makeCoachMark(for: getCoachMarkerView(at: index))
  }
  
  func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
    let coachViews = coachMarksController.helper.makeDefaultCoachViews(
      withArrow: false,
      arrowOrientation: coachMark.arrowOrientation
    )
    
    coachViews.bodyView.hintLabel.text = getCoachMarkerString(at: index)
    coachViews.bodyView.nextLabel.text = LocalizeSystem.shared.common(.ok)
    
    return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
  }
  
  private func getCoachMarkerView(at index: Int) -> UIView? {
    return viewModel.displayedHints[index].view
  }
  
  private func getCoachMarkerString(at index: Int) -> String {
    return viewModel.displayedHints[index].text
  }
}

// MARK: - CoachMarksControllerDelegate

extension EditorViewController: CoachMarksControllerDelegate {
  func coachMarksController(_ coachMarksController: CoachMarksController, willHide coachMark: CoachMark, at index: Int) {
    if index == numberOfCoachMarks(for: coachMarksController) - 1 {
      SettingsManager.shared.setValue(for: .coachMarkersDisplayed, value: true)
      coachMarksController.stop(immediately: true)
      viewModel.displayedHints.removeAll()
    }
  }
}

// MARK: - EditorHint structure

extension EditorViewController {
  struct EditorHint {
    let text: String
    let view: UIView?
  }
  
  func generateHints() {
    var hints: [EditorHint] = []
    hints.append(EditorHint(text: LocalizeSystem.shared.hint(.editorPreview), view: playerContainerView))
    hints.append(EditorHint(text: LocalizeSystem.shared.hint(.editorAddSound), view: recordButton))
    hints.append(EditorHint(text: LocalizeSystem.shared.hint(.editorTimeline), view: videoTimelineView))
    if let soundView = soundViews.first, !viewModel.addedSounds.isEmpty {
      hints.append(EditorHint(text: LocalizeSystem.shared.hint(.editorAddedSound), view: soundView))
    }
    hints.append(EditorHint(text: LocalizeSystem.shared.hint(.editorPlayPause), view: playButton))
    hints.append(EditorHint(text: LocalizeSystem.shared.hint(.editorAudioMode), view: controlsCollectionView.cellForItem(at: IndexPath(row: 0, section: 0))?.contentView))
    hints.append(EditorHint(text: LocalizeSystem.shared.hint(.editorAllSounds), view: controlsCollectionView.cellForItem(at: IndexPath(row: 1, section: 0))?.contentView))
    hints.append(EditorHint(text: LocalizeSystem.shared.hint(.editorExport), view: exportButton))
    hints.append(EditorHint(text: LocalizeSystem.shared.hint(.editorHelp), view: helpButton))
    viewModel.displayedHints = hints
  }
}

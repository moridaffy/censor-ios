//
//  SoundSelectorTableViewCell.swift
//  censor
//
//  Created by Maxim Skryabin on 25.10.2020.
//

import UIKit

protocol SoundSelectorTableViewCellDelegate: class {
  func didTapPlayButton(for soundType: SoundManager.SoundType) -> Bool
  func didFinishPlaying(soundType: SoundManager.SoundType)
}

class SoundSelectorTableViewCell: UITableViewCell {
  
  private let playButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(nil, for: .normal)
    button.setImage(UIImage(systemName: "play.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.tintColor = ColorManager.shared.accent
    return button
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
    label.textColor = ColorManager.shared.text
    return label
  }()
  
  private let durationLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    label.textColor = ColorManager.shared.subtext
    return label
  }()
  
  private var soundType: SoundManager.SoundType!
  weak var delegate: SoundSelectorTableViewCellDelegate?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(soundType: SoundManager.SoundType, isPlaying: Bool, delegate: SoundSelectorTableViewCellDelegate) {
    self.soundType = soundType
    self.delegate = delegate
    
    titleLabel.text = soundType.name
    durationLabel.text = soundType.duration.timeString(withMs: true)
    playButton.setImage(UIImage(systemName: isPlaying ? "play.circle.fill" : "play.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
    
    setupButtons()
  }
  
  private func setupLayout() {
    contentView.addSubview(playButton)
    contentView.addSubview(titleLabel)
    contentView.addSubview(durationLabel)
    
    contentView.addConstraints([
      playButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16.0),
      playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      playButton.heightAnchor.constraint(equalToConstant: 48.0),
      playButton.widthAnchor.constraint(equalToConstant: 48.0),
      
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      titleLabel.leftAnchor.constraint(equalTo: playButton.rightAnchor, constant: 8.0),
      titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16.0),
      
      durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.0),
      durationLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
      durationLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
      durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0)
    ])
  }
  
  private func setupButtons() {
    playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
  }
  
  @objc private func playButtonTapped() {
    guard let delegate = delegate else { return }
    if delegate.didTapPlayButton(for: soundType) {
      NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlayingSound), name: .soundPlayerFinishedPlaying, object: nil)
      playButton.setImage(UIImage(systemName: "play.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
  }
  
  @objc private func didFinishPlayingSound() {
    delegate?.didFinishPlaying(soundType: soundType)
    playButton.setImage(UIImage(systemName: "play.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
  }
}

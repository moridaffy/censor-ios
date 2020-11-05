//
//  VideoTimelineView.swift
//  censor
//
//  Created by Maxim Skryabin on 02.11.2020.
//

import UIKit

protocol VideoTimelineViewDelegate: class {
  func didChangeProgress(toValue value: Float)
}

class VideoTimelineView: UIView {
  
  static let height: CGFloat = 60.0
  static let refreshInterval: Double = 0.1
  
  private let previewImagesContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 6.0
    view.layer.masksToBounds = true
    view.layer.borderWidth = 2.0
    view.layer.borderColor = ColorManager.shared.subtext50opacity.cgColor
    return view
  }()
  
  private var previewImagesViews: [UIImageView] = []
  
  private let progressSlider: UISlider = {
    let thumbView = UIView(frame: CGRect(origin: .zero,
                                         size: CGSize(width: 10.0 , height: VideoTimelineView.height)))
    thumbView.layer.cornerRadius = thumbView.frame.width / 3.0
    thumbView.layer.masksToBounds = true
    thumbView.backgroundColor = ColorManager.shared.accent
    
    let slider = UISlider()
    slider.translatesAutoresizingMaskIntoConstraints = false
    slider.setThumbImage(thumbView.toImage(), for: .normal)
    slider.minimumTrackTintColor = UIColor.clear
    slider.maximumTrackTintColor = UIColor.clear
    return slider
  }()
  
  private func getImageView(tag: Int) -> UIImageView {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.layer.masksToBounds = true
    return imageView
  }
  
  private weak var delegate: VideoTimelineViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    setupLayout()
    setupActions()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(project: Project, delegate: VideoTimelineViewDelegate?) {
    self.delegate = delegate
    
    StorageManager.shared.getPreviewImages(forProject: project, completionHandler: { [weak self] (images) in
      guard images.count == Project.previewImagesCount else { return }
      for i in 0..<images.count {
        self?.previewImagesViews[i].image = images[i]
      }
    })
  }
  
  func updateProgress(withValue value: Float) {
    UIView.animate(withDuration: VideoTimelineView.refreshInterval) {
      self.progressSlider.setValue(value, animated: true)
    }
  }
  
  private func setupLayout() {
    for i in 0..<Project.previewImagesCount {
      previewImagesViews.append(getImageView(tag: i + 1))
    }
    
    let previewImagesStackView = UIStackView(arrangedSubviews: previewImagesViews)
    previewImagesStackView.translatesAutoresizingMaskIntoConstraints = false
    previewImagesStackView.axis = .horizontal
    //    previewImagesStackView.alignment = .fill
    previewImagesStackView.distribution = .fillEqually
    
    
    addSubview(previewImagesContainerView)
    previewImagesContainerView.addSubview(previewImagesStackView)
    addSubview(progressSlider)
    
    addConstraints([
      previewImagesContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 4.0),
      previewImagesContainerView.leftAnchor.constraint(equalTo: leftAnchor),
      previewImagesContainerView.rightAnchor.constraint(equalTo: rightAnchor),
      previewImagesContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.0),
      
      previewImagesStackView.topAnchor.constraint(equalTo: previewImagesContainerView.topAnchor),
      previewImagesStackView.leftAnchor.constraint(equalTo: previewImagesContainerView.leftAnchor),
      previewImagesStackView.rightAnchor.constraint(equalTo: previewImagesContainerView.rightAnchor),
      previewImagesStackView.bottomAnchor.constraint(equalTo: previewImagesContainerView.bottomAnchor),
      
      progressSlider.centerYAnchor.constraint(equalTo: previewImagesContainerView.centerYAnchor),
      progressSlider.leftAnchor.constraint(equalTo: previewImagesContainerView.leftAnchor),
      progressSlider.rightAnchor.constraint(equalTo: previewImagesContainerView.rightAnchor)
    ])
  }
  
  private func setupActions() {
    progressSlider.addTarget(self, action: #selector(progressSliderValueChanged), for: .valueChanged)
  }
  
  @objc private func progressSliderValueChanged() {
    delegate?.didChangeProgress(toValue: progressSlider.value)
  }
}

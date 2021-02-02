//
//  ProjectListTableViewCell.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import UIKit

class ProjectListTableViewCell: UITableViewCell {
  
  private let previewImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.layer.masksToBounds = true
    imageView.layer.cornerRadius = 6.0
    imageView.alpha = 0.0
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = ColorManager.shared.text
    label.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
    label.numberOfLines = 0
    return label
  }()
  
  private let durationLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = ColorManager.shared.subtext
    label.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
    label.textAlignment = .right
    return label
  }()
  
  private let creationDateLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = ColorManager.shared.subtext
    label.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    contentView.backgroundColor = ColorManager.shared.topBackground
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(project: Project) {
    titleLabel.text = project.name
    durationLabel.text = project.duration.timeString()
    creationDateLabel.text = DateHelper.shared.getString(from: project.creationDate, of: .humanTimeDate)
    
    StorageManager.shared.getPreviewImages(forProject: project) { [weak self] (images) in
      if let previewImage = images.first {
        self?.updatePreviewImage(with: previewImage)
      }
    }
  }
  
  private func setupLayout() {
    contentView.addSubview(previewImageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(durationLabel)
    contentView.addSubview(creationDateLabel)
    
    contentView.addConstraints([
      previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      previewImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8.0),
      previewImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
      previewImageView.widthAnchor.constraint(equalToConstant: 80.0),
      
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      titleLabel.leftAnchor.constraint(equalTo: previewImageView.rightAnchor, constant: 8.0),
      titleLabel.rightAnchor.constraint(equalTo: durationLabel.leftAnchor, constant: 4.0),
      
      durationLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
      durationLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8.0),
      durationLabel.widthAnchor.constraint(equalToConstant: 60.0),
      
      creationDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.0),
      creationDateLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
      creationDateLabel.rightAnchor.constraint(equalTo: durationLabel.rightAnchor),
      creationDateLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8.0),
      creationDateLabel.heightAnchor.constraint(equalToConstant: 15.0)
    ])
  }
  
  private func updatePreviewImage(with image: UIImage?) {
    guard let image = image else { return }
    previewImageView.alpha = 0.0
    previewImageView.image = image
    UIView.animate(withDuration: 0.5) {
      self.previewImageView.alpha = 1.0
    }
  }
  
}

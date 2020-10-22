//
//  ProjectListTableViewCell.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import UIKit

class ProjectListTableViewCell: UITableViewCell {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor.black
    label.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
    return label
  }()
  
  private let creationDateLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor.systemGray2
    label.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(project: Project) {
    titleLabel.text = project.name
    creationDateLabel.text = project.creationDate.description
  }
  
  private func setupLayout() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(creationDateLabel)
    
    contentView.addConstraints([
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16.0),
      titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16.0),
      titleLabel.heightAnchor.constraint(equalToConstant: 17.0),
      
      creationDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.0),
      creationDateLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
      creationDateLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
      creationDateLabel.heightAnchor.constraint(equalToConstant: 15.0),
      creationDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0)
    ])
  }
  
}

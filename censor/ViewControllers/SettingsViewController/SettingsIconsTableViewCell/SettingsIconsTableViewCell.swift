//
//  SettingsIconsTableViewCell.swift
//  censor
//
//  Created by Maxim Skryabin on 26.10.2020.
//

import UIKit

protocol SettingsIconsTableViewCellDelegate: class {
  func didSelectIcon()
}

class SettingsIconsTableViewCell: UITableViewCell {
  
  private let collectionView: UICollectionView = {
    let collectionViewLayout = UICollectionViewFlowLayout()
    collectionViewLayout.scrollDirection = .horizontal
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = UIColor.clear
    collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    collectionView.showsHorizontalScrollIndicator = false
    
    collectionView.register(SettingsIconCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: SettingsIconCollectionViewCell.self))
    
    return collectionView
  }()
  
  private weak var delegate: SettingsIconsTableViewCellDelegate?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(viewModel: SettingsIconsTableViewCellModel, delegate: SettingsIconsTableViewCellDelegate) {
    self.delegate = delegate
    
    setupCollectionView()
  }
  
  private func setupLayout() {
    contentView.addSubview(collectionView)
    
    contentView.addConstraints([
      collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      collectionView.heightAnchor.constraint(equalToConstant: 80.0),
      collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0)
    ])
  }
  
  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
  }
  
}

extension SettingsIconsTableViewCell: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 80.0, height: 80.0)
  }
}

extension SettingsIconsTableViewCell: UICollectionViewDelegate {
  
}

extension SettingsIconsTableViewCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 5
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SettingsIconCollectionViewCell.self), for: indexPath)
            as? SettingsIconCollectionViewCell else { fatalError() }
//    cell.update(icon: UIImage(named: "AppIcon")!)
    return cell
  }
}

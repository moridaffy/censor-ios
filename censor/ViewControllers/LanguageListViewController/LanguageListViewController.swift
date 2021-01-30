//
//  LanguageListViewController.swift
//  censor
//
//  Created by Maxim Skryabin on 30.01.2021.
//

import UIKit

class LanguageListViewController: UIViewController {
  
  private let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.tableFooterView = UIView()
    
    tableView.register(LanguageListTableViewCell.self, forCellReuseIdentifier: String(describing: LanguageListTableViewCell.self))
    
    return tableView
  }()
  
  private let viewModel = LanguageListViewModel()
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    view.backgroundColor = UIColor.systemBackground
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    setupTableView()
  }
  
  private func setupLayout() {
    view.addSubview(tableView)
    
    view.addConstraints([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
      tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
  
  private func setupNavigationBar() {
    title = LocalizeSystem.shared.settings(.selectLanguage)
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: view.safeAreaInsets.bottom, right: 0.0)
  }
}

extension LanguageListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    viewModel.languageSelected(at: indexPath.row)
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44.0
  }
}

extension LanguageListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.languages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LanguageListTableViewCell.self))
            as? LanguageListTableViewCell else { fatalError() }
    let language = viewModel.languages[indexPath.row]
    cell.update(title: language.title, isSelected: viewModel.currentLanguage == language)
    return cell
  }
}

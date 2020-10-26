//
//  ProjectListViewModel.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import AVFoundation

class ProjectListViewModel {
  
  let mediaType: String = "public.movie"
  
  var selectedFileUrl: URL?
  
  weak var view: ProjectListViewController?
  private(set) var projects: [Project] = [] {
    didSet {
      view?.reloadTableView()
    }
  }
  
  init() {
    reloadProjects()
  }
  
  func reloadProjects() {
    projects = StorageManager.shared.getProjects()
  }
  
  func createNewProject(name: String, originalUrl: URL) -> Project {
    let videoDuration = AVAsset(url: originalUrl).duration.seconds
    let project = Project(name: name, duration: videoDuration, originalUrl: originalUrl)
    
    // Copies input video from PhotoLibrary to project's folder
    _ = StorageManager.shared.getInputUrl(forProject: project)
    
    projects.append(project)
    selectedFileUrl = nil
    
    StorageManager.shared.saveProject(project)
    
    return project
  }
  
  func deleteProject(at row: Int) {
    StorageManager.shared.deleteProject(projects[row])
    projects.remove(at: row)
  }
}

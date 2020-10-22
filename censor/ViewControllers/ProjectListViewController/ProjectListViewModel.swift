//
//  ProjectListViewModel.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import AVFoundation

class ProjectListViewModel {
  
  let mediaType: String = "public.movie"
  
  private(set) var projects: [Project] = []
  
  var selectedFileUrl: URL?
  
  func createNewProject(name: String, originalUrl: URL) -> Project {
    let videoDuration = AVAsset(url: originalUrl).duration.seconds
    let project = Project(name: name, duration: videoDuration, originalUrl: originalUrl)
    
    projects.append(project)
    selectedFileUrl = nil
    
    // TODO: сохранение проекта локально
    
    return project
  }
}

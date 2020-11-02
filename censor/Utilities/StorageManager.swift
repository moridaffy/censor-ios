//
//  StorageManager.swift
//  censor
//
//  Created by Maxim Skryabin on 23.10.2020.
//

import Foundation
import class UIKit.UIImage

class StorageManager {
  
  static let shared = StorageManager()
  
  private let filemanager = FileManager.default
  private lazy var projectListUrl: URL = {
    return URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
      .appendingPathComponent("Documents", isDirectory: true)
      .appendingPathComponent("project_list.json", isDirectory: false)
  }()
  
  /// Create a folder for storing input and output videos of project
  /// - Parameter project: folder will be created for this project
  /// - Returns: returns output.mov file's URL if folder was successfully created or already existed. Returns error if folder creation failed
  func getOutputUrl(forProject project: Project) -> (URL?, Error?) {
    let outputFolderUrl = project.outputFolderUrl
    let outputUrl = outputFolderUrl
      .appendingPathComponent("output.mov", isDirectory: false)
    
    if let folderCreationError = createFolderIfNeeded(atPath: outputFolderUrl.path) {
      return (nil, folderCreationError)
    } else {
      if filemanager.fileExists(atPath: outputUrl.path) {
        do {
          try filemanager.removeItem(at: outputUrl)
        } catch let error {
          return (nil, error)
        }
      }
      return (outputUrl, nil)
    }
  }
  
  
  /// Copy input video from PhotoLibrary to Documents folder
  /// - Parameter project: input video will be written to this project's folder
  /// - Returns: returns input.mov file's URL if file was successfully copied. Returns error if copying failed
  func getInputUrl(forProject project: Project) -> (URL?, Error?) {
    let outputFolderUrl = project.outputFolderUrl
    let inputUrl = outputFolderUrl
      .appendingPathComponent("input.mov", isDirectory: false)
    
    if filemanager.fileExists(atPath: inputUrl.path) {
      // File exists at project's folder, all good
      return (inputUrl, nil)
    } else if filemanager.fileExists(atPath: project.originalUrl.path) {
      // File exists in PhotoLibrary, but doesn't exist in project's folder
      
      if let folderCreationError = createFolderIfNeeded(atPath: outputFolderUrl.path) {
        return (nil, folderCreationError)
      } else {
        do {
          try filemanager.copyItem(at: project.originalUrl, to: inputUrl)
          return (inputUrl, nil)
        } catch let error {
          return (nil, error)
        }
      }
    } else {
      // File doesn't exist in PhotoLibrary and project's folder
      fatalError()
    }
  }
  
  func savePreviewImages(forProject project: Project, images: [UIImage]) {
    for i in 0..<images.count {
      if let previewImageData = images[i].pngData() {
        let previewImageUrl = project.outputFolderUrl
          .appendingPathComponent("preview_\(i + 1).png", isDirectory: false)
        try? previewImageData.write(to: previewImageUrl)
      }
    }
  }
  
  func getPreviewImages(forProject project: Project, completionHandler: ([UIImage]) -> Void) {
    var images: [UIImage] = []
    var pendingImages = Project.previewImagesCount {
      didSet {
        if pendingImages == 0 {
          completionHandler(images)
        }
      }
    }
    for i in 0..<Project.previewImagesCount {
      let previewImageUrl = project.outputFolderUrl
        .appendingPathComponent("preview_\(i + 1).png", isDirectory: false)
      if filemanager.fileExists(atPath: previewImageUrl.path),
         let previewImage = UIImage(contentsOfFile: previewImageUrl.path) {
        images.append(previewImage)
      }
      pendingImages -= 1
    }
  }
  
  func saveProject(_ project: Project, newProject: Bool = false, completionHandler: (() -> Void)?) {
    var existingProjects = getProjects()
    if let projectIndex = existingProjects.firstIndex(where: { $0.id == project.id }) {
      existingProjects[projectIndex] = project
    } else {
      existingProjects.append(project)
    }
    writeProjectsToDisk(existingProjects)
    
    if newProject {
      generateImagesForProject(project, completionHandler: completionHandler)
    } else {
      completionHandler?()
    }
  }
  
  func deleteProject(_ project: Project) {
    try? filemanager.removeItem(atPath: project.outputFolderUrl.path)
    
    var existingProjects = getProjects()
    guard let projectIndex = existingProjects.firstIndex(where: { $0.id == project.id }) else { return }
    existingProjects.remove(at: projectIndex)
    writeProjectsToDisk(existingProjects)
  }
  
  func getProjects() -> [Project] {
    guard filemanager.fileExists(atPath: projectListUrl.path),
          let projectsData = try? String(contentsOf: projectListUrl).data(using: .utf8),
          let projects = try? JSONDecoder().decode([Project].self, from: projectsData) else { return [] }
    return projects
  }
  
  private func writeProjectsToDisk(_ projects: [Project]) {
    let projectsData = try? JSONEncoder().encode(projects)
    try? projectsData?.write(to: projectListUrl)
  }
  
  private func createFolderIfNeeded(atPath path: String) -> Error? {
    var isDirectory: ObjCBool = false
    guard !filemanager.fileExists(atPath: path, isDirectory: &isDirectory) else { return nil }
    do {
      try filemanager.createDirectory(at: URL(fileURLWithPath: path, isDirectory: true), withIntermediateDirectories: true, attributes: nil)
      return nil
    } catch let error {
      return error
    }
  }
  
  private func generateImagesForProject(_ project: Project, completionHandler: (() -> Void)?) {
    var pendingImages: Int = Project.previewImagesCount
    var previewImages: [UIImage] = [] {
      didSet {
        pendingImages -= 1
        if pendingImages == 0 {
          savePreviewImages(forProject: project, images: previewImages)
          completionHandler?()
        }
      }
    }
    
    for i in 0..<pendingImages {
      let time = project.duration / Double(Project.previewImagesCount) * Double(i)
      VideoRenderer.shared.getPreviewImage(for: project, atTime: time) { (image) in
        if let image = image {
          previewImages.append(image)
        } else {
          print("🔥 Failed to create preview image for project \(project.id) at \(time)")
        }
      }
    }
  }
}

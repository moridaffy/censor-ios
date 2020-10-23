//
//  StorageManager.swift
//  censor
//
//  Created by Maxim Skryabin on 23.10.2020.
//

import Foundation

class StorageManager {
  
  static let shared = StorageManager()
  
  private let filemanager = FileManager.default
  
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
}

extension StorageManager {
  enum StorageError: Error {
    
  }
}

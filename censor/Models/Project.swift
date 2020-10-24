//
//  Project.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import Foundation

class Project: Codable {
  let id: String
  let name: String
  let duration: Double
  
  private let originalUrlValue: String
  private let creationDateValue: String
  
  var sounds: [Sound] = []
  
  var originalUrl: URL {
    return URL(string: originalUrlValue)!
  }
  var creationDate: Date {
    return DateHelper.shared.getDate(from: creationDateValue, of: .full) ?? Date()
  }
  var outputFolderUrl: URL {
    return URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
      .appendingPathComponent("Documents", isDirectory: true)
      .appendingPathComponent("Projects", isDirectory: true)
      .appendingPathComponent(id, isDirectory: true)
  }
  
  init(name: String, duration: Double, originalUrl: URL) {
    self.id = UUID().uuidString
    self.name = name
    self.duration = duration
    self.originalUrlValue = originalUrl.absoluteString
    self.creationDateValue = DateHelper.shared.getString(from: Date(), of: .full)
  }
  
}

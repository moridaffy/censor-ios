//
//  Project.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import Foundation

class Project {
  let id: String
  let name: String
  let duration: Double
  let originalUrl: URL
  let creationDate: Date
  
  var sounds: [Sound] = []
  
  init(name: String, duration: Double, originalUrl: URL) {
    self.id = UUID().uuidString
    self.name = name
    self.duration = duration
    self.originalUrl = originalUrl
    self.creationDate = Date()
  }
  
}

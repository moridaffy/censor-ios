//
//  EditorViewModel.swift
//  censor
//
//  Created by Maxim Skryabin on 20.10.2020.
//

import Foundation
import Photos

class EditorViewModel {
  
  let preferredTimescale = CMTimeScale(NSEC_PER_SEC)
  
  let project: Project
  
  var isPlayingVideo: Bool = true
  var currentSoundIndex: Int = 0
  
  var selectedAudioMode: VideoRenderer.AudioMode = .overlayOriginal
  var selectedSoundType: Sound.SoundType = .horn1
  var addedSounds: [Sound] {
    get {
      return project.sounds
    }
    set {
      project.sounds = newValue
      view?.addedSoundsUpdated()
    }
  }
  
  weak var view: EditorViewController?
  
  init(project: Project) {
    self.project = project
  }
  
  func addSound(at timestamp: Double) {
    let sound = Sound(timestamp: timestamp, type: selectedSoundType)
    addedSounds = (addedSounds + [sound])
      .sorted(by: { $0.timestamp < $1.timestamp })
    
    SoundManager.shared.playSound(sound)
  }
  
  func getProgressTimeString(for timestamp: Double) -> String {
    let minutes = (timestamp / 60.0).rounded()
    let seconds = (timestamp - minutes * 60.0).rounded()
    
    return [minutes, seconds]
      .compactMap({ $0.roundedString(symbolsAfter: 0, symbolsBefore: 2) })
      .joined(separator: ":")
  }
  
  func renderProject(completionHandler: @escaping (Error?) -> Void) {
    VideoRenderer.shared.renderVideo(project: project, addWatermark: true) { (result) in
      switch result {
      case .success(let outputUrl):
        
        PHPhotoLibrary.shared().performChanges {
          PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputUrl)
        } completionHandler: { (saved, error) in
          if saved {
            completionHandler(nil)
          } else {
            completionHandler(error ?? VideoRenderer.RenderingError.savingFailed)
          }
        }
      
        completionHandler(nil)
      case .failure(let error):
        completionHandler(error)
      }
    }
  }
}

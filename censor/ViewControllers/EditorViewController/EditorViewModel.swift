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
  
  var currentSoundIndex: Int = 0
  var projectNeedsSaving: Bool = false
  var controlCellModels: [EditorButtonCollectionViewCellModel] = []
  var displayedHints: [EditorViewController.EditorHint] = []
  
  var selectedSoundType: SoundManager.SoundType = SoundManager.shared.allSoundTypes.first! {
    didSet {
      generateCells()
    }
  }
  var selectedAudioMode: VideoRenderer.AudioMode = .keepOriginal {
    didSet {
      generateCells()
    }
  }
  
  var isPlayingVideo: Bool = true {
    didSet {
      print("🔥 isPlayingVideo = \(isPlayingVideo)")
      view?.updatePlayButton()
    }
  }
  var addedSounds: [Sound] {
    get {
      return project.sounds
    }
    set {
      projectNeedsSaving = true
      project.sounds = newValue
      view?.addedSoundsUpdated()
    }
  }
  
  weak var view: EditorViewController?
  
  init(project: Project) {
    self.project = project
    
    generateCells()
  }
  
  private func generateCells() {
    self.controlCellModels = [
      EditorButtonCollectionViewCellModel(type: .audioMode(selectedMode: selectedAudioMode), text: selectedAudioMode.shortTitle),
      EditorButtonCollectionViewCellModel(type: .soundSelection, text: selectedSoundType.name),
      EditorButtonCollectionViewCellModel(type: .export, text: LocalizeSystem.shared.editor(.export))
    ]
  }
  
  func addSound(at timestamp: Double) {
    let sound = Sound(timestamp: timestamp, type: selectedSoundType)
    addedSounds = (addedSounds + [sound])
      .sorted(by: { $0.timestamp < $1.timestamp })
    
    SoundManager.shared.playSound(sound.type)
  }
  
  func renderProject(completionHandler: @escaping (Error?) -> Void) {
    VideoRenderer.shared.renderVideo(project: project, audioMode: selectedAudioMode, addWatermark: !SettingsManager.shared.isPremiumFeaturesUnlocked) { (result) in
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
  
  func saveProject(completionHandler: @escaping () -> Void) {
    StorageManager.shared.saveProject(project, completionHandler: completionHandler)
  }
}

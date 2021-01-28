//
//  VideoRenderer.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import AVFoundation
import UIKit

class VideoRenderer {
  
  private struct Config {
    static let volumeRampDuration = 0.1
  }
  
  static let shared = VideoRenderer()
  
  private let filemanager = FileManager.default
  
  private var renderingSession: AVAssetExportSession?
  private var renderingProgressTimer: Timer?
  
  private func renderingFinished() {
    renderingProgressTimer?.invalidate()
    renderingProgressTimer = nil
    renderingSession = nil
  }
  
  @objc private func renderingProgressTimerFired() {
    guard let renderingSession = renderingSession else {
      renderingFinished()
      return
    }
    
    let renderingProgress = Double(renderingSession.progress)
    if renderingProgress > 0.99 {
      renderingFinished()
    } else {
      NotificationCenter.default.post(name: .renderingProgressUpdated, object: nil, userInfo: ["progress": renderingProgress])
    }
  }
  
  func renderVideo(project: Project, audioMode: AudioMode, addWatermark: Bool, completionHandler: @escaping (Result<URL, Error>) -> Void) {
    // Verifying input and output URLs are valid
    let inputUrlResponse = StorageManager.shared.getInputUrl(forProject: project)
    guard let inputUrl = inputUrlResponse.0 else {
      completionHandler(.failure(inputUrlResponse.1 ?? RenderingError.fileProbablyGotDeleted))
      return
    }
    
    let outputUrlResponse = StorageManager.shared.getOutputUrl(forProject: project)
    guard let outputUrl = outputUrlResponse.0 else {
      completionHandler(.failure(outputUrlResponse.1 ?? RenderingError.folderCreationFailed))
      return
    }
    
    // Creating tracks
    let inputAsset = AVAsset(url: inputUrl)
    let originalVideoTrack = inputAsset.tracks(withMediaType: .video)[0]
    let originalAudioTrack = inputAsset.tracks(withMediaType: .audio)[0]
    let originalAudioTrackId = CMPersistentTrackID(999)
    
    let mixedComposition = AVMutableComposition()
    let audioMixedComposition = AVMutableAudioMix()
    let originalVideoComposition = mixedComposition
      .addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID(0))!
    let originalAudioComposition = mixedComposition
      .addMutableTrack(withMediaType: .audio, preferredTrackID: originalAudioTrackId)!
    
    let timescale = originalVideoTrack.naturalTimeScale
    originalVideoComposition.preferredTransform = originalVideoTrack.preferredTransform
    
    let originalAudioParameters = AVMutableAudioMixInputParameters()
    originalAudioParameters.trackID = originalAudioTrackId
    
    do {
      try originalVideoComposition.insertTimeRange(CMTimeRange(start: .zero,
                                                               duration: originalVideoTrack.timeRange.duration),
                                                   of: originalVideoTrack,
                                                   at: .zero)
      try originalAudioComposition.insertTimeRange(CMTimeRange(start: .zero,
                                                               duration: originalVideoTrack.timeRange.duration),
                                                   of: originalAudioTrack,
                                                   at: .zero)
      
      // Adding sounds
      for sound in project.sounds {
        let soundAsset = AVAsset(url: sound.type.fileUrl)
        let soundTrack = soundAsset.tracks(withMediaType: .audio)[0]
        let soundComposition = mixedComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let soundCompositionStartTime = CMTime(seconds: sound.timestamp, preferredTimescale: timescale)
        try soundComposition.insertTimeRange(CMTimeRange(start: .zero,
                                                         duration: soundTrack.timeRange.duration),
                                             of: soundTrack,
                                             at: soundCompositionStartTime)
        
        // Changing original track volume if needed
        switch audioMode {
        case .keepOriginal:
          break
        case .muteOriginal:
          let rampDuration = CMTime(seconds: Config.volumeRampDuration, preferredTimescale: timescale)
          let removeVolumeTimeRange = CMTimeRange(start: soundCompositionStartTime, duration: rampDuration)
          let returnVolumeTimeRange = CMTimeRange(start: CMTimeMakeWithSeconds(sound.timestamp + sound.type.duration, preferredTimescale: timescale),
                                                  duration: rampDuration)
          
          originalAudioParameters.setVolumeRamp(fromStartVolume: 1.0, toEndVolume: 0.0, timeRange: removeVolumeTimeRange)
          originalAudioParameters.setVolumeRamp(fromStartVolume: 0.0, toEndVolume: 1.0, timeRange: returnVolumeTimeRange)
        case .silenceOriginal:
          let rampDuration = CMTime(seconds: Config.volumeRampDuration, preferredTimescale: timescale)
          let removeVolumeTimeRange = CMTimeRange(start: soundCompositionStartTime, duration: rampDuration)
          let returnVolumeTimeRange = CMTimeRange(start: CMTimeMakeWithSeconds(sound.timestamp + sound.type.duration, preferredTimescale: timescale),
                                                  duration: rampDuration)
          
          originalAudioParameters.setVolumeRamp(fromStartVolume: 1.0, toEndVolume: 0.2, timeRange: removeVolumeTimeRange)
          originalAudioParameters.setVolumeRamp(fromStartVolume: 0.2, toEndVolume: 1.0, timeRange: returnVolumeTimeRange)
        }
      }
      audioMixedComposition.inputParameters.append(originalAudioParameters)
      
    } catch let error {
      completionHandler(.failure(error))
    }
    
    // Creating export session
    let session: AVAssetExportSession? = {
      if addWatermark {
        let watermarkFilter = CIFilter(name: "CISourceOverCompositing")!
        let watermarkImage = CIImage(image: UIImage(named: "watermark")!)!
        let watermarkVideoComposition = AVVideoComposition(asset: mixedComposition) { (filteringRequest) in
          let source = filteringRequest.sourceImage.clampedToExtent()
          let transform = CGAffineTransform(translationX: 16.0, y: 16.0)
          
          watermarkFilter.setValue(source, forKey: "inputBackgroundImage")
          watermarkFilter.setValue(watermarkImage.transformed(by: transform), forKey: "inputImage")
          filteringRequest.finish(with: watermarkFilter.outputImage!, context: nil)
        }
        
        let exportSession = AVAssetExportSession(asset: mixedComposition, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.videoComposition = watermarkVideoComposition
        return exportSession
      } else {
        let exportSession = AVAssetExportSession(asset: mixedComposition, presetName: AVAssetExportPresetHighestQuality)
        return exportSession
      }
    }()
    
    session?.audioMix = audioMixedComposition
    session?.outputURL = outputUrl
    session?.outputFileType = AVFileType.mov
    
    guard let exportSession = session else {
      completionHandler(.failure(RenderingError.noExportSession))
      return
    }
    
    // Configuring progress tracking timer
    self.renderingSession = exportSession
    let renderingProgressTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                      target: self,
                                                      selector: #selector(renderingProgressTimerFired),
                                                      userInfo: nil,
                                                      repeats: true)
    renderingProgressTimer.fire()
    self.renderingProgressTimer = renderingProgressTimer
    
    // Executing rendering export session
    exportSession.exportAsynchronously { () -> Void in
      switch exportSession.status {
      case .completed:
        completionHandler(.success(outputUrl))
      default:
        completionHandler(.failure(exportSession.error ?? RenderingError.exportSessionFailed))
      }
    }
  }
  
  func getPreviewImage(for project: Project, atTime time: Double = 0.0, completionHandler: @escaping (UIImage?) -> Void) {
    DispatchQueue.global(qos: .background).async {
      let inputUrlResponse = StorageManager.shared.getInputUrl(forProject: project)
      guard let inputUrl = inputUrlResponse.0 else {
        completionHandler(nil)
        return
      }
      
      let inputAsset = AVAsset(url: inputUrl)
      let inputAssetImageGenerator = AVAssetImageGenerator(asset: inputAsset)
      inputAssetImageGenerator.appliesPreferredTrackTransform = true
      inputAssetImageGenerator.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
      
      let previewCgImage: CGImage
      do {
        previewCgImage = try inputAssetImageGenerator.copyCGImage(at: CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), actualTime: nil)
      } catch let error {
        print("🔥 Failed to render preview image for project \(project.id):\n\(error.localizedDescription)")
        return completionHandler(nil)
      }
      
      let previewImage = UIImage(cgImage: previewCgImage)
      DispatchQueue.main.async {
        completionHandler(previewImage)
      }
    }
  }
}

extension VideoRenderer {
  enum RenderingError: Error {
    case noExportSession
    case exportSessionFailed
    case folderCreationFailed
    case savingFailed
    case fileProbablyGotDeleted
  }
  
  enum AudioMode: Equatable {
    
    static let allCases: [AudioMode] = [.muteOriginal, .silenceOriginal, .keepOriginal]
    
    case muteOriginal
    case silenceOriginal
    case keepOriginal
    
    var iconSystemName: String {
      switch self {
      case .muteOriginal:
        return "speaker.slash"
      case .silenceOriginal:
        return "speaker.wave.1"
      case .keepOriginal:
        return "speaker.wave.3"
      }
    }
    
    var title: String {
      switch self {
      case .muteOriginal:
        return NSLocalizedString("Mute original", comment: "")
      case .silenceOriginal:
        return NSLocalizedString("Silence original", comment: "")
      case .keepOriginal:
        return NSLocalizedString("Keep original", comment: "")
      }
    }
    
    var description: String {
      switch self {
      case .muteOriginal:
        return NSLocalizedString("Completely mute original audio track while overlaying it with added sound", comment: "")
      case .silenceOriginal:
        return NSLocalizedString("Keep only 20% of original track's volume while overlaying it with added sound", comment: "")
      case .keepOriginal:
        return NSLocalizedString("Don't change original audio track volume", comment: "")
      }
    }
    
    var shortTitle: String {
      guard let shortTitle = title.split(separator: " ").first else { return NSLocalizedString("Error", comment: "") }
      return String(shortTitle)
    }
  }
}

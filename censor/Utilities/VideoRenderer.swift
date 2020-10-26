//
//  VideoRenderer.swift
//  censor
//
//  Created by Maxim Skryabin on 21.10.2020.
//

import AVFoundation
import UIKit

class VideoRenderer {
  
  static let shared = VideoRenderer()
  
  private let filemanager = FileManager.default
  
  func renderVideo(project: Project, addWatermark: Bool, completionHandler: @escaping (Result<URL, Error>) -> Void) {
    
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
    
    let inputAsset = AVAsset(url: inputUrl)
    let originalVideoTrack = inputAsset.tracks(withMediaType: .video)[0]
    let originalAudioTrack = inputAsset.tracks(withMediaType: .audio)[0]
    
    let mixedComposition = AVMutableComposition()
    let originalVideoComposition = mixedComposition
      .addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
    let originalAudioComposition = mixedComposition
      .addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
    
    originalVideoComposition.preferredTransform = originalVideoTrack.preferredTransform
    
    do {
      try originalVideoComposition.insertTimeRange(CMTimeRange(start: .zero,
                                                               duration: originalVideoTrack.timeRange.duration),
                                                   of: originalVideoTrack,
                                                   at: .zero)
      try originalAudioComposition.insertTimeRange(CMTimeRange(start: .zero,
                                                               duration: originalVideoTrack.timeRange.duration),
                                                   of: originalAudioTrack,
                                                   at: .zero)
      
      for sound in project.sounds {
        let soundAsset = AVAsset(url: sound.type.fileUrl)
        let soundTrack = soundAsset.tracks(withMediaType: .audio)[0]
        let soundComposition = mixedComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        
        let soundCompositionStartTime = CMTime(seconds: sound.timestamp, preferredTimescale: originalVideoTrack.naturalTimeScale)
        try soundComposition.insertTimeRange(CMTimeRange(start: .zero,
                                                         duration: soundTrack.timeRange.duration),
                                             of: soundTrack,
                                             at: soundCompositionStartTime)
      }
    } catch let error {
      completionHandler(.failure(error))
    }
    
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
    
    guard let exportSession = session else {
      completionHandler(.failure(RenderingError.noExportSession))
      return
    }
    exportSession.outputURL = outputUrl
    exportSession.outputFileType = AVFileType.mov
    exportSession.exportAsynchronously { () -> Void in
      switch exportSession.status {
      case .completed:
        completionHandler(.success(outputUrl))
      default:
        completionHandler(.failure(exportSession.error ?? RenderingError.exportSessionFailed))
      }
    }
  }
  
  func getPreviewImage(for project: Project, completionHandler: @escaping (UIImage?) -> Void) {
    if let previewImage = StorageManager.shared.getPreviewImage(forProject: project) {
      DispatchQueue.main.async {
        completionHandler(previewImage)
      }
      return
    }
    
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
        previewCgImage = try inputAssetImageGenerator.copyCGImage(at: CMTime(seconds: 0.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), actualTime: nil)
      } catch let error {
        print("🔥 Failed to render preview image for project \(project.id):\n\(error.localizedDescription)")
        return completionHandler(nil)
      }
      
      let previewImage = UIImage(cgImage: previewCgImage)
      StorageManager.shared.savePreviewImage(forProject: project, image: previewImage)
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
  
  enum AudioMode {
    case muteOriginal
    case overlayOriginal
    
    var iconSystemName: String {
      switch self {
      case .muteOriginal:
        return "speaker.zzz"
      case .overlayOriginal:
        return "speaker.2"
      }
    }
    
    var anotherMode: AudioMode {
      switch self {
      case .muteOriginal:
        return .overlayOriginal
      case .overlayOriginal:
        return .muteOriginal
      }
    }
  }
}

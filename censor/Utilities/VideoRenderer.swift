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
    
    // TODO: optionally add watermark
    
    let inputAsset = AVAsset(url: project.originalUrl)
    let outputUrl = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
      .appendingPathComponent("Documents", isDirectory: true)
      .appendingPathComponent("Projects", isDirectory: true)
      .appendingPathComponent(project.id, isDirectory: true)
      .appendingPathComponent("output.mov", isDirectory: false)
    createOutputUrl(outputUrl)
    
    let originalVideoTrack = inputAsset.tracks(withMediaType: .video)[0]
    let originalAudioTrack = inputAsset.tracks(withMediaType: .audio)[0]
    
    let mixedComposition = AVMutableComposition()
    let originalVideoComposition = mixedComposition
      .addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
    let originalAudioComposition = mixedComposition
      .addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
    originalAudioComposition.preferredVolume = 0.75
    
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
        
        let soundCompositionStartTime = CMTime(seconds: sound.timestamp, preferredTimescale: originalVideoTrack.naturalTimeScale)//CMTime(seconds: 0.0, preferredTimescale: originalVideoTrack.naturalTimeScale) //CMTime(seconds: sound.timestamp, preferredTimescale: originalVideoTrack.naturalTimeScale)
        try soundComposition.insertTimeRange(CMTimeRange(start: .zero,
                                                         duration: soundTrack.timeRange.duration),
                                             of: soundTrack,
                                             at: soundCompositionStartTime)
      }
    } catch let error {
      completionHandler(.failure(error))
    }
    
//    // Adding watermark to video
//    let watermarkFilter = CIFilter(name: "CISourceOverCompositing")!
//    let watermarkImage = CIImage(image: UIImage(named: "watermark")!)!
//    let videoComposition = AVVideoComposition(asset: inputAsset) { (filteringRequest) in
//      let source = filteringRequest.sourceImage.clampedToExtent()
//      let transform = CGAffineTransform(translationX: 16.0, y: 16.0)
//
//      watermarkFilter.setValue(source, forKey: "inputBackgroundImage")
//      watermarkFilter.setValue(watermarkImage.transformed(by: transform), forKey: "inputImage")
//      filteringRequest.finish(with: watermarkFilter.outputImage!, context: nil)
//    }
    
    guard let exportSession = AVAssetExportSession(asset: mixedComposition, presetName: AVAssetExportPresetHighestQuality) else {
      completionHandler(.failure(RenderingError.noExportSession))
      return
    }
    
    exportSession.outputURL = outputUrl
    exportSession.outputFileType = AVFileType.mov
//    exportSession.shouldOptimizeForNetworkUse = true
//    exportSession.videoComposition = mixedComposition
    exportSession.exportAsynchronously { () -> Void in
      switch exportSession.status {
      case .completed:
        completionHandler(.success(outputUrl))
      default:
        completionHandler(.failure(exportSession.error ?? RenderingError.exportSessionFailed))
      }
    }
  }
  
  func mergeVideoAndAudio(videoUrl: URL,
                          audioUrl: URL,
                          shouldFlipHorizontally: Bool = false,
                          completion: @escaping (_ error: Error?, _ url: URL?) -> Void) {
    
    let mixComposition = AVMutableComposition()
    
    //start merge
    
    let aVideoAsset = AVAsset(url: videoUrl)
    let aAudioAsset = AVAsset(url: audioUrl)
    
    let compositionAddVideo = mixComposition.addMutableTrack(withMediaType: .video,
                                                             preferredTrackID: kCMPersistentTrackID_Invalid)!
    
    let compositionAddAudio = mixComposition.addMutableTrack(withMediaType: .audio,
                                                             preferredTrackID: kCMPersistentTrackID_Invalid)!
    
    let compositionAddAudioOfVideo = mixComposition.addMutableTrack(withMediaType: .audio,
                                                                    preferredTrackID: kCMPersistentTrackID_Invalid)!
    
    let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: .video)[0]
    let aAudioOfVideoAssetTrack: AVAssetTrack? = aVideoAsset.tracks(withMediaType: .audio).first
    let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio)[0]
    
    // Default must have tranformation
    compositionAddVideo.preferredTransform = aVideoAssetTrack.preferredTransform
    
    if shouldFlipHorizontally {
      // Flip video horizontally
      var frontalTransform: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
      frontalTransform = frontalTransform.translatedBy(x: -aVideoAssetTrack.naturalSize.width, y: 0.0)
      frontalTransform = frontalTransform.translatedBy(x: 0.0, y: -aVideoAssetTrack.naturalSize.width)
      compositionAddVideo.preferredTransform = frontalTransform
    }
    
    do {
      try compositionAddVideo.insertTimeRange(CMTimeRangeMake(start: .zero,
                                                                          duration: aVideoAssetTrack.timeRange.duration),
                                                          of: aVideoAssetTrack,
                                                          at: .zero)
      
      //In my case my audio file is longer then video file so i took videoAsset duration
      //instead of audioAsset duration
      try compositionAddAudio.insertTimeRange(CMTimeRangeMake(start: .zero,
                                                                          duration: aVideoAssetTrack.timeRange.duration),
                                                          of: aAudioAssetTrack,
                                                          at: .zero)
      
      // adding audio (of the video if exists) asset to the final composition
      if let aAudioOfVideoAssetTrack = aAudioOfVideoAssetTrack {
        try compositionAddAudioOfVideo.insertTimeRange(CMTimeRangeMake(start: .zero,
                                                                                   duration: aVideoAssetTrack.timeRange.duration),
                                                                   of: aAudioOfVideoAssetTrack,
                                                                   at: .zero)
      }
    } catch {
      print(error.localizedDescription)
    }
    
    // Exporting
    let savePathUrl: URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/newVideo.mp4")
    do { // delete old video
      try FileManager.default.removeItem(at: savePathUrl)
    } catch { print(error.localizedDescription) }
    
    let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
    assetExport.outputFileType = .mp4
    assetExport.outputURL = savePathUrl
    assetExport.shouldOptimizeForNetworkUse = true
    
    assetExport.exportAsynchronously { () -> Void in
      switch assetExport.status {
      case AVAssetExportSessionStatus.completed:
        print("success")
        completion(nil, savePathUrl)
      case AVAssetExportSessionStatus.failed:
        print("failed \(assetExport.error?.localizedDescription ?? "error nil")")
        completion(assetExport.error, nil)
      case AVAssetExportSessionStatus.cancelled:
        print("cancelled \(assetExport.error?.localizedDescription ?? "error nil")")
        completion(assetExport.error, nil)
      default:
        print("complete")
        completion(assetExport.error, nil)
      }
    }
    
  }
  
  private func createOutputUrl(_ url: URL) {
    let folderPath = url
      .path
      .split(separator: "/")
      .dropLast()
      .joined(separator: "/")
    
    if !filemanager.fileExists(atPath: folderPath, isDirectory: UnsafeMutablePointer<ObjCBool>.init(bitPattern: 1)) {
      do {
        try filemanager.createDirectory(at: URL(fileURLWithPath: folderPath, isDirectory: true), withIntermediateDirectories: true, attributes: nil)
      } catch let error {
        print(error)
        fatalError()
      }
    }
  }
}

extension VideoRenderer {
  enum RenderingError: Error {
    case noExportSession
    case exportSessionFailed
    case savingFailed
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

//
//  MKOVideoMerge.swift
//  VIDEO
//
//  Created by appsyneefo on 9/21/22.
//

import UIKit
import AVFoundation

class MKOVideoMerge {
    class func mergeVideoFiles(
        _ fileURLs: [AnyHashable]?,
        completion: @escaping (_ mergedVideoFile: URL?, _ error: Error?) -> Void
    ) {
        print("Start merging video files ...")
        
        
        let composition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        var instructions: [AVMutableVideoCompositionInstruction] = []
        
        var errorOccurred = false
        var currentTime: CMTime = .zero
        var size = CGSize.zero
        var highestFrameRate: Int32 = 0
        
        guard let fileURLs = fileURLs else {
            return
        }
        
        for (_, value) in fileURLs.enumerated() {
            
            let options = [
                AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber(value: true)
            ]
            let sourceAsset = AVURLAsset(url: value as! URL, options: options)
            let videoAsset = sourceAsset.tracks(withMediaType: .video).first
            let audioAsset = sourceAsset.tracks(withMediaType: .audio).first
            
            guard let videoAsset = videoAsset, let videoTrack = videoTrack, let audioTrack = audioTrack, let audioAsset = audioAsset else {
                return
            }
            
            if size.equalTo(.zero) {
                size = videoAsset.naturalSize
            }
            
//            print(sourceAsset.duration.seconds, "  index")
            
            let currentFrameRate = Int32(Int(roundf(videoAsset.nominalFrameRate)))
            highestFrameRate = (currentFrameRate > highestFrameRate) ? currentFrameRate : highestFrameRate

//            print(String(format: "* %@ (%dfps)", value.lastPathComponent, currentFrameRate))
            let trimmingTime = CMTimeMake(value: Int64(lround(Double(Float(videoAsset.naturalTimeScale) / videoAsset.nominalFrameRate))), timescale: videoAsset.naturalTimeScale)
            let timeRange = CMTimeRangeMake(start: trimmingTime, duration: CMTimeSubtract(videoAsset.timeRange.duration, trimmingTime))
            var videoResult = false
            var videoErrorr : NSError?
            do {
                try videoTrack.insertTimeRange(timeRange, of: videoAsset, at: currentTime)
                videoResult = true
            } catch let videoError {
                videoErrorr = videoError as NSError
            }
            var audioResult = false
            var audioErrorr : NSError?
            do {
                try audioTrack.insertTimeRange(timeRange, of: audioAsset, at: currentTime)
                audioResult = true
            } catch let audioError {
                audioErrorr = audioError as NSError
            }
            if !videoResult || !audioResult || (videoErrorr != nil) || (audioErrorr != nil) {
                
                completion(nil, videoErrorr ?? audioErrorr)
                errorOccurred = true
                break
            }else {
                let videoCompositionInstruction = AVMutableVideoCompositionInstruction()
                videoCompositionInstruction.timeRange = CMTimeRangeMake(start: currentTime, duration: timeRange.duration)
                videoCompositionInstruction.layerInstructions = [
                    AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
                ]
                instructions.append(videoCompositionInstruction)
                currentTime = CMTimeAdd(currentTime, timeRange.duration)
            }
        }
        
        if !errorOccurred{
            
            let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
            let fileName = MKOVideoMerge.generateFileName()
            let filePath = MKOVideoMerge.documentsPath(withFilePath: fileName)
            
//            let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
//              .appendingPathComponent("videoName1")
//              .appendingPathExtension("mov")
            
//            MKOVideoMerge.deleteFile(exportURL)
            
            guard let exportSession = exportSession else { return }
            
            exportSession.outputURL = URL(fileURLWithPath: filePath!)
            exportSession.outputFileType = .mov
//            exportSession.outputURL = exportURL
            exportSession.shouldOptimizeForNetworkUse = true
            
            let mutableVideoComposition = AVMutableVideoComposition()
            mutableVideoComposition.instructions = instructions
            mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: highestFrameRate)
            mutableVideoComposition.renderSize = size
            
            exportSession.videoComposition = mutableVideoComposition
            
            exportSession.exportAsynchronously {
              DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    completion(exportSession.outputURL, nil)
                default:
                  print("Something went wrong during export.")
                  print(exportSession.error ?? "unknown error")
                  completion(nil, exportSession.error)
                  break
                }
              }
            }
        }
    }
    
    class func applicationDocumentsDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    }
    
    class func documentsPath(withFilePath filePath: String?) -> String? {
        return URL(fileURLWithPath: MKOVideoMerge.applicationDocumentsDirectory()!.path).appendingPathComponent(filePath ?? "").path
    }
    
    class func generateFileName() -> String? {
        return "video-\(ProcessInfo.processInfo.globallyUniqueString).mov"
    }
    
    class func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
}

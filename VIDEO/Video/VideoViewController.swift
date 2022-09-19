//
//  VideoViewController.swift
//  VIDEO
//
//  Created by appsyneefo on 9/5/22.
//

import UIKit
import AVFoundation
import AVKit
import Photos
import MKRingProgressView


class VideoViewController: UIViewController, AVPlayerViewControllerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // sticker
    @IBOutlet weak var stickerView: UIView!
    @IBOutlet weak var stickerContainerview: UIView!
    
    private var _selectedStickerView:StickerView?
    var selectedStickerView:StickerView? {
        get {
            return _selectedStickerView
        }
        set {
            // if other sticker choosed then resign the handler
            if _selectedStickerView != newValue {
                if let selectedStickerView = _selectedStickerView {
                    selectedStickerView.showEditingHandlers = false
                }
               
                _selectedStickerView = newValue
//                stickerSlider.setValue(Float((_selectedStickerView!.contentView.alpha - 0.5) / 0.5), animated: true)
            }
            // assign handler to new sticker added
            if let selectedStickerView = _selectedStickerView {
                selectedStickerView.showEditingHandlers = true
                selectedStickerView.superview?.bringSubviewToFront(selectedStickerView)
//                stickerSlider.setValue(Float((_selectedStickerView!.contentView.alpha - 0.5) / 0.5 ), animated: true)
            }
        }
    }
    
    
    // background
    var visualEffectView : UIVisualEffectView?
    var backavPlayerLayer : AVPlayerLayer!
    var compositionnn : AVMutableComposition!
    
    // canvas
    @IBOutlet weak var videoViewTrailingCon: NSLayoutConstraint!
    @IBOutlet weak var videoViewLeadingCon: NSLayoutConstraint!
    @IBOutlet weak var videoViewHeightCon: NSLayoutConstraint!
    @IBOutlet weak var videoViewTopCon: NSLayoutConstraint!
    
    // export
    var export : AVAssetExportSession?
    var exportt : AVAssetExportSession?
    var timer : Timer?
    let ringProgressView = RingProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    @IBOutlet weak var progressView: UIView!
    var composition : AVVideoComposition!
    var compositio : AVVideoComposition!
    var videoURL : URL?
    var ciVideoURL : URL?
    
    @IBOutlet weak var playIconView: UIImageView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var adjustView: UIView!
    
    @IBOutlet weak var adjustSlider: UISlider!
    enum AdjustStates {
        case brightness, contrast, saturation
    }
    
    var currentAdjust : AdjustStates = AdjustStates.brightness
    
    enum FilterStates {
        case mono, sepia, gpu, none
    }
    
    var currentFilter = FilterStates.none
    
    var phAsset : PHAsset? = nil
   
    var pickedImage : UIImage?
    @IBOutlet weak var pickedImageView: UIImageView!
    
    @IBOutlet weak var toolbarCollectionView: UICollectionView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var url : NSURL? = nil
    
    var player : AVPlayer!
    var avPlayerLayer : AVPlayerLayer!
    var myAsset : AVAsset!
    var playerItem : AVPlayerItem!
    var imagesFromVideo = [UIImage]()
    
    var totalLength : CGFloat = 0
    var totalFrame : Float = 0
    var frameRate : Float = 0
    
    var cnt = 0
    
    var directoryFolderUrl : NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stickerView.isHidden = true
        adjustView.isHidden = true
        toolbarCollectionView.delegate = self
        toolbarCollectionView.dataSource = self
        let nib = UINib(nibName: "ToolbarCollectionViewCell", bundle: nil)
        toolbarCollectionView.register(nib, forCellWithReuseIdentifier: "ToolbarCollectionViewCell")
        
        
//        myAsset = AVAsset(url: url! as URL)
        makeAvasset()
        
        adjustSlider.addTarget(self, action: #selector(onSliderValChangedAdjust(slider:event:)), for: .valueChanged)
        
        // visual effect on background video
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.light)) as UIVisualEffectView
        visualEffectView?.frame = videoView.bounds
        
        
        
        ringProgressView.startColor = .white
        ringProgressView.endColor = .gray
        ringProgressView.ringWidth = 10
        ringProgressView.progress = 0.0
        progressView.addSubview(ringProgressView)
        
       
       
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.3){
//            self.playVideo()
//        }
        
//        
//        directoryFolderUrl = getDirectoryPath()
//        
//        frameRate = getFrameRate() ?? 0
//        totalFrame = frameRate * Float(myAsset.duration.seconds)
//        
//        print(frameRate, totalFrame, myAsset.duration.seconds, "ok")
//        
//        getNumberOfFrames(url: url! as URL)
//        
//        generateVideoPreviewImage(for: myAsset, with: CGSize(width: 60, height: 60))
    }
    
    
    
    func makeAvasset(){
        PHCachingImageManager().requestAVAsset(forVideo: phAsset!, options: nil) { (avAsset, _, _) in
            
            guard let avAsset = avAsset else {
                return
            }
            
            self.myAsset = avAsset
           
            self.playVideo()
            
//            let composition = AVVideoComposition(asset: avAsset) { AVAsynchronousCIImageFilteringRequest in
//
//            }
//
//            let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
//                      .appendingPathComponent("videoName")
//                      .appendingPathExtension("mov")
//
//                    self.deleteFile(exportURL)
//
//                    //export the video to as per your requirement conversion
//            guard let exportSession = AVAssetExportSession(asset: self.myAsset, presetName: AVAssetExportPresetHighestQuality) else { return }
//                    exportSession.outputFileType = AVFileType.mov
//                    exportSession.outputURL = exportURL
//                    exportSession.videoComposition = composition
//
//                    exportSession.exportAsynchronously(completionHandler: {
//                        switch exportSession.status {
//                        case .completed:
//                            self.ciVideoURL = exportURL
////                            onComplete(exportURL)
//
//                        case .failed:
//                            print("failed")
//                            print(exportSession.error?.localizedDescription)
//            //                failure(exportSession.error?.localizedDescription)
//
//                        case .cancelled:
//                            print("cancelled")
//            //                failure(exportSession.error?.localizedDescription)
//
//                        default: print("export session failed")
//            //                failure(exportSession.error?.localizedDescription)
//                        }
//                    })
        }
    }
    
   
    
    func getFrameRate() -> Float?{
        let tracks = myAsset.tracks(withMediaType: .video)

        let fps = tracks.first?.nominalFrameRate
        
        return fps
    }
    
    private var imageGenerator: AVAssetImageGenerator?
   
    private func generateVideoPreviewImage(
        for video: AVAsset,
        with size: CGSize
    ) {
        var sourceTime = [NSValue]()
        let imageGenerator = AVAssetImageGenerator(asset: video)
        self.imageGenerator = imageGenerator
        
//        imageGenerator.maximumSize = size.applying(.init(scaleX: 1.5, y: 1.5))
        // Add tolerance.
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceAfter = .positiveInfinity
        imageGenerator.requestedTimeToleranceBefore = .positiveInfinity
                
        let step = Float(video.duration.seconds) / 10
        for index in stride(from: 0, to: 10 , by: 1){
            let cmTime = CMTime(seconds: Double( Float(index) * step), preferredTimescale: 600)
            sourceTime.append(NSValue(time: cmTime))
            
        }
        
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: sourceTime) {
            [weak self] _, image, _, _, _ in
            
            DispatchQueue.main.async {
                let image = image.flatMap(UIImage.init)
                guard let image = image else { return }
                self!.cnt += 1
                self!.imagesFromVideo.append(image)
                self!.toolbarCollectionView.reloadData()
                
                
//                print(self!.imagesFromVideo.count, " ",  self!.imagesFromVideo[self!.imagesFromVideo.count-1].size)
//                autoreleasepool {
//                    self!.saveImageDocumentDirectory(image: image,imageName: "picked\(self!.cnt).jpg" )
//
//                }

//                self?.previewImage = image ?? self?.previewImage
//                completionHandler(image)
            }
        }
    }
    
    func playVideo(){
        guard myAsset != nil else {
            return
        }
        
        playerItem = AVPlayerItem(asset: myAsset)
    
        player = AVPlayer(playerItem: playerItem)
        player.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
        avPlayerLayer = AVPlayerLayer(player: player)
        avPlayerLayer.frame = videoView.bounds
        
        backavPlayerLayer = AVPlayerLayer(player: player)
        backavPlayerLayer.frame = videoView.bounds
        backavPlayerLayer.videoGravity = .resizeAspectFill
        
        backavPlayerLayer.addSublayer(visualEffectView!.layer)
        
        DispatchQueue.main.async { [self] in
            videoView.layer.addSublayer(backavPlayerLayer)
            videoView.layer.addSublayer(avPlayerLayer)
            player.play()
            generateVideoPreviewImage(for: myAsset, with: .zero)
        }
        
        NotificationCenter.default
            .addObserver(self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        
    }
    
    var isPlaying = true
    
    @IBAction func playAction(_ sender: Any) {
        if isPlaying {
            player.pause()
            isPlaying = false
            playIconView.image = UIImage(named: "PlayIcon")
            return
        }
        
        if player.currentTime() >= CMTime(seconds: myAsset.duration.seconds, preferredTimescale: 600)  {
            player.seek(to: .zero)
        }
        player.play()
        isPlaying = true
        playIconView.image = UIImage(named: "PuaseIcon")
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        isPlaying = false
        playIconView.image = UIImage(named: "PlayIcon")
    }
    
    func applyFilterBeforeExport(onComplete : @escaping(URL?) -> Void){
        
      let composition = AVVideoComposition(asset: myAsset, applyingCIFiltersWithHandler: { [self] request in
            
            var outputImage : CIImage = request.sourceImage

            if currentFilter == .gpu {
               let outputUIImage = applyGPUImageLookupFilter(outputImage.toUIImage(), UIImage(named: "lut1"))
                outputImage = (outputUIImage?.toCIImage())!
            }else if currentFilter == .mono {
                let filterr = CIFilter(name: "CIColorMonochrome")!

                filterr.setValue(outputImage, forKey: kCIInputImageKey)
                outputImage = filterr.outputImage!
            } else if currentFilter == .sepia {
                let filterr = CIFilter(name: "CISepiaTone")!

                filterr.setValue(outputImage, forKey: kCIInputImageKey)
                outputImage = filterr.outputImage!
            }

            filter = CIFilter(name: "CIColorControls")!

            filter.setValue(outputImage, forKey: kCIInputImageKey)
            filter.setValue(brightness, forKey: kCIInputBrightnessKey)
            filter.setValue(contrast, forKey: kCIInputContrastKey)
            filter.setValue(saturation, forKey: kCIInputSaturationKey)

            let output = filter.outputImage!

            request.finish(with: output, context: nil)
      })
        
        

        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
          .appendingPathComponent("videoName")
          .appendingPathExtension("mov")

        self.deleteFile(exportURL)

        //export the video to as per your requirement conversion
       export = AVAssetExportSession(asset: myAsset, presetName: AVAssetExportPresetHighestQuality)
        
        guard let export = export else {
            return
        }
        
        export.outputFileType = AVFileType.mov
        export.outputURL = exportURL
        export.videoComposition = composition

        export.exportAsynchronously(completionHandler: {
            switch export.status {
            case .completed:
                self.timer?.invalidate()
                onComplete(exportURL)

            case .failed:
                print("failed")
//                failure(exportSession.error?.localizedDescription)

            case .cancelled:
                print("cancelled")
//                failure(exportSession.error?.localizedDescription)

            default: print("export session failed")
//                failure(exportSession.error?.localizedDescription)
            }
        })
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)

    }
    
    var filterInProgress = false
    var filterTimer : Timer?
    
    
    
    func getFilteredURL(success: @escaping (URL?) -> Void){
       
        if filterInProgress {
            while(filterInProgress){
               
            }
            success(ciVideoURL)
        }else {
            success(ciVideoURL)
        }
    }
    
    
    
    var asset : AVURLAsset?
    
    func exportVideo(onComplete: @escaping (URL?) -> Void){
        
        applyFilterBeforeExport { [self] url in
            
            DispatchQueue.main.async { [self] in
                asset = AVURLAsset.init(url: url!)
                guard let asset = asset else {
                    return
                }
                
                
                compositionnn = AVMutableComposition()
                
                guard
                  let compositionTrack = compositionnn.addMutableTrack(
                    withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                  let assetTrack = asset.tracks(withMediaType: .video).first
                  else {
                    print("Something is wrong with the asset.")
                    onComplete(nil)
                    return
                }
                
                do {
                  let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
                  try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
                  
                  if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
                    let compositionAudioTrack = compositionnn.addMutableTrack(
                      withMediaType: .audio,
                      preferredTrackID: kCMPersistentTrackID_Invalid) {
                    try compositionAudioTrack.insertTimeRange(
                      timeRange,
                      of: audioAssetTrack,
                      at: .zero)
                  }
                } catch {
                  print(error)
                  onComplete(nil)
                  return
                }
                
                compositionTrack.preferredTransform = assetTrack.preferredTransform
                let videoInfo = orientation(from: assetTrack.preferredTransform)
                
                let videoSize: CGSize
                if videoInfo.isPortrait {
                  videoSize = CGSize(
                    width: assetTrack.naturalSize.height,
                    height: assetTrack.naturalSize.width)
                } else {
                  videoSize = assetTrack.naturalSize
                }
               
                let outputLayer = CALayer()
                outputLayer.frame =  CGRect(origin: .zero, size: videoSize)
                let backgoundLayer = CALayer()
                backgoundLayer.frame = CGRect(origin: .zero, size: videoSize)
                let videoLayer = CALayer()
                videoLayer.frame = CGRect(origin: .zero, size: videoSize)
                let overlayLayer = CALayer()
                overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
                
        //        backgoundLayer.addSublayer(backavPlayerLayer)
        //        videoLayer.addSublayer(avPlayerLayer)
                
                self.selectedStickerView?.showEditingHandlers = false
                
                overlayLayer.contents = stickerContainerview.asImage().cgImage
                overlayLayer.contentsGravity = .resizeAspectFill
                
                outputLayer.addSublayer(backgoundLayer)
                outputLayer.addSublayer(videoLayer)
                outputLayer.addSublayer(overlayLayer)
                
                
                let videoComposition = AVMutableVideoComposition()
                videoComposition.renderSize = videoSize
                videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
                videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
                  postProcessingAsVideoLayer: videoLayer,
                  in: outputLayer)
                
                let instruction = AVMutableVideoCompositionInstruction()
                instruction.timeRange = CMTimeRange(
                  start: .zero,
                  duration: compositionnn.duration)
//                instruction.timeRange = CMTimeRange(start: .zero, end: CMTime(seconds: 5, preferredTimescale: 600))
                videoComposition.instructions = [instruction]
                let layerInstruction = compositionLayerInstruction(
                  for: compositionTrack,
                  assetTrack: assetTrack)
                instruction.layerInstructions = [layerInstruction]
                
                export = AVAssetExportSession(
                  asset: compositionnn,
                  presetName: AVAssetExportPresetHighestQuality)
                  
                guard let export = export else {
                  
                      print("Cannot create export session.")
                      onComplete(nil)
                      return
                 
                }
                
                self.deleteFile(url!)
                
    //            let videoName = UUID().uuidString
                let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
                  .appendingPathComponent("videoName")
                  .appendingPathExtension("mov")
                
                export.videoComposition = videoComposition
                export.outputFileType = AVFileType.mov
                export.outputURL = exportURL
                
                export.exportAsynchronously {
                  DispatchQueue.main.async {
                    switch export.status {
                    case .completed:
                        self.timer?.invalidate()
                      onComplete(exportURL)
                    default:
                      self.timer?.invalidate()
                      print("Something went wrong during export.")
                      print(export.error ?? "unknown error")
                      onComplete(nil)
                      break
                    }
                  }
                }
                
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            }
         
            }
        
    }
    
    @objc func fireTimer(){
        print("heyy", export?.progress)
        guard let export = export else {
            return
        }
       
        ringProgressView.progress = Double(export.progress)
       
    }
    
    @IBAction func pauseAction(_ sender: Any) {
    
//        let vc = ExportViewController()
//
//
//        navigationController?.pushViewController(vc, animated: true)
//
        player.pause()
        exportVideo { exportedURL in
            guard let exportedURL = exportedURL else {
              return
            }
            self.videoURL = exportedURL
           
            PHPhotoLibrary.requestAuthorization { [weak self] status in
              switch status {
              case .authorized:
                self?.saveVideoToPhotos()
              default:
                print("Photos permissions not granted.")
                return
              }
            }
        }
    }
    
    private func saveVideoToPhotos() {
      PHPhotoLibrary.shared().performChanges( {
          PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoURL!)
      }) { [weak self] (isSaved, error) in
        if isSaved {
          print("Video saved.")
        } else {
          print("Cannot save video.")
          print(error ?? "unknown error")
        }
        DispatchQueue.main.async {
          self?.navigationController?.popViewController(animated: true)
        }
      }
    }
    
    func getDirectoryPath() -> NSURL {
         let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("video")
        let url = NSURL(string: path)
        return url!
    }
    
    func saveImageDocumentDirectory(image: UIImage, imageName: String) {
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("video")
        if !fileManager.fileExists(atPath: path) {
        try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        let url = NSURL(string: path)
        let imagePath = url!.appendingPathComponent(imageName)
        let urlString: String = imagePath!.absoluteString
            let imageData = image.jpegData(compressionQuality: 0.5)
        //let imageData = UIImagePNGRepresentation(image)
        fileManager.createFile(atPath: urlString as String, contents: imageData, attributes: nil)
    }
    
    func getImageFromDocumentDirectory(_ index : Int) {
        let fileManager = FileManager.default
        
        let imagePath = (self.getDirectoryPath() as NSURL).appendingPathComponent("picked\(index).jpg")
        let urlString: String = imagePath!.absoluteString
        if fileManager.fileExists(atPath: urlString) {
          let image = UIImage(contentsOfFile: urlString)
          pickedImage = image
        } else {
        // print("No Image")
        }
       
    }

    @IBAction func getImageFromDocument(_ sender: Any) {
        getImageFromDocumentDirectory(cnt-1)
        pickedImageView.image = pickedImage
    }
    
    var frames = [UIImage]()
    func callAgain(){
        let asset = AVURLAsset(url: (url! as URL), options: nil)
            let videoDuration = asset.duration
              
            let generator = AVAssetImageGenerator(asset: asset)

            var frameForTimes = [NSValue]()
            let sampleCounts = 300
            let totalTimeLength = Int(videoDuration.seconds * Double(videoDuration.timescale))
            let step = totalTimeLength / sampleCounts
          
            for i in 0 ..< sampleCounts {
                let cmTime = CMTimeMake(value: Int64(i * step), timescale: Int32(videoDuration.timescale))
                frameForTimes.append(NSValue(time: cmTime))
            }
          
            generator.generateCGImagesAsynchronously(forTimes: frameForTimes, completionHandler: {requestedTime, image, actualTime, result, error in
                DispatchQueue.main.async {
                    if let image = image {
//                        print(requestedTime.value, requestedTime.seconds, actualTime.value)
                        self.frames.append(UIImage(cgImage: image))
                        print(self.frames.count)
                    }
                }
            })
    }
    
    func getNumberOfFrames(url: URL) -> Int {
            let asset = AVURLAsset(url: url, options: nil)
            do {
                let reader = try AVAssetReader(asset: asset)
            //AVAssetReader(asset: asset, error: nil)
                let videoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]

                let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: nil) // NB: nil, should give you raw frames
                reader.add(readerOutput)
            reader.startReading()

            var nFrames = 0

            while true {
                let sampleBuffer = readerOutput.copyNextSampleBuffer()
                if sampleBuffer == nil {
                    break
                }

                nFrames = nFrames+1
            }

            print("Num frames: \(nFrames)")
                return nFrames
            }catch {
                print("Error: \(error)")
            }
            return 0
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesFromVideo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = toolbarCollectionView.dequeueReusableCell(withReuseIdentifier: "ToolbarCollectionViewCell", for: indexPath) as! ToolbarCollectionViewCell
        
        cell.imageView.image = imagesFromVideo[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    var filter = CIFilter()
    fileprivate func applyFilter(item : AVPlayerItem, filter : CIFilter){
//        composition = AVVideoComposition(asset: item.asset, applyingCIFiltersWithHandler: { request in
//
//            filter.setValue(request.sourceImage, forKey: kCIInputImageKey)
//            let output = filter.outputImage!
//
//            request.finish(with: output, context: nil)
//        })
//        item.videoComposition = composition
        
//        videoComposition = AVMutableVideoComposition(asset: item.asset, applyingCIFiltersWithHandler: {
//            request in
//
//            filter.setValue(request.sourceImage, forKey: kCIInputImageKey)
//            let output = filter.outputImage!
//
//            request.finish(with: output, context: nil)
//        })
//        item.videoComposition = videoComposition
    }
    
    func applyMono(_ mainImage : CIImage) -> CIImage {
        
        filter = CIFilter(name: "CIColorMonochrome")!
        
        filter.setValue(mainImage, forKey: kCIInputImageKey)
        let output = filter.outputImage!
        return output
    }
    
    func applyGPUImageLookupFilter(_ mainImage : UIImage?, _ topImage : UIImage?) -> UIImage?{
        guard let inputImage = mainImage, let topImage = topImage else {
            return nil
        }
        
        let mainPicture = GPUImagePicture(image: inputImage)
        let topPicture = GPUImagePicture(image: topImage)
        let lookupFiltered = GPUImageLookupFilter()
        lookupFiltered.intensity = 1.0
    
        mainPicture?.addTarget(lookupFiltered)
        topPicture?.addTarget(lookupFiltered)
        lookupFiltered.useNextFrameForImageCapture()
        mainPicture?.processImage()
        topPicture?.processImage()
        let outputImage = lookupFiltered.imageFromCurrentFramebuffer()
        return outputImage

    }
    
    fileprivate func gpuImageFilter(){
        guard myAsset != nil else {return}
         composition = AVVideoComposition(asset: playerItem.asset) { [self] request in

             filter = CIFilter(name: "CIColorControls")!
             filter.setValue(request.sourceImage, forKey: kCIInputImageKey)
             filter.setValue(brightness, forKey: kCIInputBrightnessKey)
             filter.setValue(contrast, forKey: kCIInputContrastKey)
             filter.setValue(saturation, forKey: kCIInputSaturationKey)
             
             
            let inputImage = filter.outputImage!.toUIImage()
            let topImage = UIImage(named: "lut1")
                        
            let outputImage = applyGPUImageLookupFilter(inputImage, topImage)
            guard let img = outputImage else {return}
            
            request.finish(with: img.toCIImage()!, context: nil)
        }
        playerItem.videoComposition = composition
    }
    
  
    @IBAction func monoFilterApply(_ sender: Any) {
        guard myAsset != nil else {return}
//        filter = CIFilter(name: "CIColorMonochrome")!
//        applyFilter(item: playerItem, filter: filter)
        currentFilter = .mono
        applyAdjust()
    }
    
    @IBAction func sepiaFilterApply(_ sender: Any) {
        guard myAsset != nil else {return}
//        filter = CIFilter(name: "CISepiaTone")!
//        applyFilter(item: playerItem, filter: filter)
        currentFilter = .sepia
        applyAdjust()
    }
    
    @IBAction func distorFilterApply(_ sender: Any) {
        guard myAsset != nil else {return}
//        gpuImageFilter()
        currentFilter = .gpu
        applyAdjust()
    }
    
    @IBAction func adjustAction(_ sender: Any) {
        filterView.isHidden = true
        adjustView.isHidden = false
        
        filter = CIFilter(name: "CIColorControls")!
    }
    
    @IBAction func adjustDoneAction(_ sender: Any) {
        filterView.isHidden = false
        adjustView.isHidden = true
    }
    
    var brightness : CGFloat = 0
    var contrast : CGFloat = 1
    var saturation : CGFloat = 1
    
    var inProgress = false
    var cntt = 0;
    
    func applyAdjust(item : AVPlayerItem){
       
        composition = AVVideoComposition(asset: myAsset, applyingCIFiltersWithHandler: { [self] request in
             var outputImage : CIImage = request.sourceImage
             cntt += 1
             print(cntt)
             if currentFilter == .gpu {
                let outputUIImage = applyGPUImageLookupFilter(outputImage.toUIImage(), UIImage(named: "lut1"))
                 outputImage = (outputUIImage?.toCIImage())!
             }else if currentFilter == .mono {
                 print("mono")
                 let filterr = CIFilter(name: "CIColorMonochrome")!

                 filterr.setValue(outputImage, forKey: kCIInputImageKey)
                 outputImage = filterr.outputImage!
             } else if currentFilter == .sepia {
                 print("sepia")
                 let filterr = CIFilter(name: "CISepiaTone")!

                 filterr.setValue(outputImage, forKey: kCIInputImageKey)
                 outputImage = filterr.outputImage!
             }

             filter = CIFilter(name: "CIColorControls")!

             filter.setValue(outputImage, forKey: kCIInputImageKey)
             filter.setValue(brightness, forKey: kCIInputBrightnessKey)
             filter.setValue(contrast, forKey: kCIInputContrastKey)
             filter.setValue(saturation, forKey: kCIInputSaturationKey)

             guard let tmp = filter.outputImage else {return}
            
             let output = tmp
            
         
             request.finish(with: output, context: nil)
         })
        
        playerItem.videoComposition = composition

//         let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
//           .appendingPathComponent("videoName")
//           .appendingPathExtension("mov")
//
//         self.deleteFile(exportURL)
//
//         //export the video to as per your requirement conversion
//         export = AVAssetExportSession(asset: myAsset, presetName: AVAssetExportPresetHighestQuality)
//
//        guard let export = export else {
//            return
//        }
//
//        export.outputFileType = AVFileType.mov
//        export.outputURL = exportURL
//        export.videoComposition = composition
//
//        export.exportAsynchronously(completionHandler: {
//             print(export.status, "status")
//             switch export.status {
//             case .completed:
//                 print("ase ====================================")
//                 onComplete(exportURL)
//
//             case .failed:
//                 print("failed")
// //                failure(exportSession.error?.localizedDescription)
//
//             case .cancelled:
//                 print("cancelled")
// //                failure(exportSession.error?.localizedDescription)
//
//             default: print("export session failed")
// //                failure(exportSession.error?.localizedDescription)
//             }
//         })
        
//        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)

    }
    
    @IBAction func brightnessAction(_ sender: Any) {
        currentAdjust = .brightness
        filter = CIFilter(name: "CIColorControls")!
        let temp : CGFloat = (brightness/0.6) + 0.5
        adjustSlider.setValue(Float(temp), animated: true)
    }
    
    @IBAction func contrastAction(_ sender: Any) {
        currentAdjust = .contrast
        filter = CIFilter(name: "CIColorControls")!
        var temp : CGFloat = 0.5
        if contrast > 1 {
             temp = ((contrast - 1) / 3) + 0.5
        }else {
            temp = contrast - 0.5
        }
        adjustSlider.setValue(Float(temp), animated: true)
    }
    
    @IBAction func saturationAction(_ sender: Any) {
        currentAdjust = .saturation
        var temp : CGFloat = 0.5
        if saturation > 1 {
             temp = ((saturation - 1) / 2) + 0.5
        }else {
            temp = saturation - 0.5
        }
        adjustSlider.setValue(Float(temp), animated: true)
    }
    
    func applyAdjust(){
        filterInProgress = true
//        applyAdjust(item: playerItem) { url in
//            guard let url = url else {
//                return
//            }
//
//            self.ciVideoURL = url
//            self.filterInProgress = false
//        }
        applyAdjust(item: playerItem)
    }
    
    @objc func onSliderValChangedAdjust(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
           
            case .moved :
                switch(currentAdjust){
                    
                    case .brightness :
                    let val : CGFloat = CGFloat(0.6 * ( adjustSlider.value - 0.5 ))
                    brightness = val
//                    applyAdjust()
                    
                    case .contrast :
                        var val : CGFloat = 1
                        if (adjustSlider.value >= 0.5){
                            let a = 3
                            let b = adjustSlider.value - 0.5
                            val = CGFloat(( Double(a) * Double(b) ) + 1.0)
                        }else {
                            val = CGFloat(0.5 + adjustSlider.value)
                        }
                        contrast = val
//                        applyAdjust()
                    
                    case .saturation :
                        var val : CGFloat = 1
                        if (adjustSlider.value >= 0.5){
                            let a = 2
                            let b = adjustSlider.value - 0.5
                            val = CGFloat(( Double(a) * Double(b) ) + 1.0)
                        }else {
                            val = CGFloat(0.5 + adjustSlider.value)
                        }
                        saturation = val
//                        applyAdjust()
                    
                }
            case .ended :
                applyAdjust()
                break
                
            default:
                break
            }
        }
    }
    
    // sticker
    
    @IBAction func stikcerViewOpen(_ sender: Any) {
        videoView.bringSubviewToFront(stickerContainerview)
        
        filterView.isHidden = true
        stickerView.isHidden = false
    }
    
    @IBAction func stickerDone(_ sender: Any) {
        filterView.isHidden = false
        stickerView.isHidden = true
    }
    
    @IBAction func stickerOneApply(_ sender: Any) {
        let testImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        testImage.image = UIImage(named: "100")
        testImage.contentMode = .scaleAspectFit
        let stickerView3 = StickerView.init(contentView: testImage)
        stickerView3.center = CGPoint.init(x: 150, y: 150)
        stickerView3.delegate = self
        stickerView3.setImage(UIImage.init(named: "cancel")!, forHandler: StickerViewHandler.close)
        stickerView3.setImage(UIImage.init(named: "size")!, forHandler: StickerViewHandler.rotate)
        stickerView3.setImage(UIImage.init(named: "flip")!, forHandler: StickerViewHandler.flip)
        stickerView3.showEditingHandlers = false
        stickerView3.tag = 999
        self.stickerContainerview.addSubview(stickerView3)
        self.selectedStickerView = stickerView3
    }
    
    @IBAction func stikcerTwoApply(_ sender: Any) {
        let testImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        testImage.image = UIImage(named: "101")
        testImage.contentMode = .scaleAspectFit
        let stickerView3 = StickerView.init(contentView: testImage)
        stickerView3.center = CGPoint.init(x: 150, y: 150)
        stickerView3.delegate = self
        stickerView3.setImage(UIImage.init(named: "cancel")!, forHandler: StickerViewHandler.close)
        stickerView3.setImage(UIImage.init(named: "size")!, forHandler: StickerViewHandler.rotate)
        stickerView3.setImage(UIImage.init(named: "flip")!, forHandler: StickerViewHandler.flip)
        stickerView3.showEditingHandlers = false
        stickerView3.tag = 999
        self.stickerContainerview.addSubview(stickerView3)
        self.selectedStickerView = stickerView3
    }
    
    @IBAction func stickerthreeApply(_ sender: Any) {
        let testImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        testImage.image = UIImage(named: "102")
        testImage.contentMode = .scaleAspectFit
        let stickerView3 = StickerView.init(contentView: testImage)
        stickerView3.center = CGPoint.init(x: 150, y: 150)
        stickerView3.delegate = self
        stickerView3.setImage(UIImage.init(named: "cancel")!, forHandler: StickerViewHandler.close)
        stickerView3.setImage(UIImage.init(named: "size")!, forHandler: StickerViewHandler.rotate)
        stickerView3.setImage(UIImage.init(named: "flip")!, forHandler: StickerViewHandler.flip)
        stickerView3.showEditingHandlers = false
        stickerView3.tag = 999
        self.stickerContainerview.addSubview(stickerView3)
        self.selectedStickerView = stickerView3
    }
    // video size
    func getVideoResolution() -> CGSize? {
        guard let track = myAsset.tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
//        return abs(size.height) / abs(size.width)
        print(size, " video size")
        return size
    }

    private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
      let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
      let transform = assetTrack.preferredTransform
      
      instruction.setTransform(transform, at: .zero)
      
      return instruction
    }
    
    private func orientation(from transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
      var assetOrientation = UIImage.Orientation.up
      var isPortrait = false
      if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
        assetOrientation = .right
        isPortrait = true
      } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
        assetOrientation = .left
        isPortrait = true
      } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
        assetOrientation = .up
      } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
        assetOrientation = .down
      }
      
      return (assetOrientation, isPortrait)
    }
    
    func deleteFile(_ filePath:URL) {
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

// sticker
extension VideoViewController : StickerViewDelegate {
    func stickerViewDidBeginMoving(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
    }
    
    func stickerViewDidChangeMoving(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidEndMoving(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidBeginRotating(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidChangeRotating(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidEndRotating(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidClose(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidTap(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
    }
}


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
//import VideoToolbox


class VideoViewController: UIViewController, AVPlayerViewControllerDelegate, ICGVideoTrimmerDelegate, CALayerDelegate {
    
    var stickerNames : [String] = ["100", "101", "102"]
    var topmostImage : UIImage?
    // background
    var curHeight : CGFloat = .zero
    var curWidth : CGFloat = 375
    
    var allStickers : [StickerValueModel] = []
    
    // canvas
    var w : CGFloat = 0
    var h : CGFloat = 0
    @IBOutlet weak var canvasView: UIView!
    
    var finalHeight : CGFloat = 0
    var finalWidth : CGFloat = 0
    
    // trim advance
    
    @IBOutlet weak var trimmerView: ICGVideoTrimmerView!
    @IBOutlet weak var startEndContainer: UIView!
    
    @IBOutlet weak var startPosButton: UIButton!
    @IBOutlet weak var endPosButton: UIButton!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var indicatorView: YView!
    @IBOutlet weak var startingTime: UILabel!
    @IBOutlet weak var endingTime: UILabel!
    
    
    var trimEnabled = false
    var cutEnabled = false
    
    
    var tempVideoPath: String?
    var tempVideoPath1: String?
    var startTime: CGFloat = 0.0
    var stopTime: CGFloat = 0.0
    var restartOnPlay = false
    
    
    // trim
    var isSliderEnd = true
    var startTimestr = ""
    var endTimestr = ""
    var videoPlaybackPosition: CGFloat = 0.0
    var thumbtimeSeconds: Int!
    var rangSlider: RangeSlider! = nil
    @IBOutlet weak var trimView: UIView!
    @IBOutlet weak var trimFrameView: UIView!
    @IBOutlet weak var frameContainerView: UIView!
    
    // slider

    
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
    
//    enum FilterStates {
//        case mono, sepia, gpu, none
//    }
//
    var currentFilter = GlobalClass.FilterStates.none
    
    var phAsset : PHAsset? = nil
   
    var pickedImage : UIImage?
    @IBOutlet weak var pickedImageView: UIImageView!
    
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
        
        h = videoViewHeightCon.constant
        w = UIScreen.main.bounds.width
        
        trimView.isHidden = true
        stickerView.isHidden = true
        adjustView.isHidden = true
        
        
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
        
        
        trimFrameView.layer.cornerRadius = 5.0
        trimFrameView.layer.borderWidth  = 1.0
        trimFrameView.layer.borderColor  = UIColor.white.cgColor
        trimFrameView.layer.masksToBounds = true
        
        
//        slider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
       
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
        
//        slider.setValue(0, animated: true)
        
       
    }
    
    
    
    // trim set up
    func setupTrim(){
        
        let xx : CGFloat = (self.view.frame.midX - 20)/2
        let yy : CGFloat = ((self.view.frame.maxY - trimFrameView.frame.height - startEndContainer.frame.height) / 2 - 30) / 2
        let ww : CGFloat = 40
        let hh : CGFloat = trimFrameView.frame.height + startEndContainer.frame.height/2
        
        let view = YView(frame: CGRect(x: xx, y: yy, width: ww, height: hh))
        
        self.view.addSubview(view)
        self.view.bringSubviewToFront(view)
        
        endTimeLabel.text = Utility.second(toTimeFormat: CMTimeGetSeconds(myAsset.duration))
        endPosButton.setImage(UIImage(named: "end_here_after_press_2"), for: .normal)
        endPosButton.isEnabled = false
        
//        loadVideoView()
        segmentedControl.removeBorder()
        tempVideoPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmpMov.mov").path
        tempVideoPath1 = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmpMov1.mov").path
        
        self.videoPlaybackPosition = 0;
        trimmerView.themeColor = UIColor.lightGray
        trimmerView.asset = myAsset
        trimmerView.showsRulerView = true
        trimmerView.rulerLabelInterval = 10
        trimmerView.trackerColor = UIColor.cyan
        trimmerView.delegate = self
        // important: reset subviews
        trimmerView.resetSubviews()
    }
    
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
           
            case .moved :
                playerItem.seek(to: CMTime(seconds: Double(slider.value) * myAsset.duration.seconds, preferredTimescale: 600))

                break
            case .ended :
                playerItem.seek(to: CMTime(seconds: Double(slider.value) * myAsset.duration.seconds, preferredTimescale: 600))

                break
            default : break
                
            }
        }
    }
    
    
    var videoInitialSize : CGSize = .zero
    func makeAvasset(){
        PHCachingImageManager().requestAVAsset(forVideo: phAsset!, options: nil) { (avAsset, _, _) in
            
            guard let avAsset = avAsset else {
                return
            }
            
            self.myAsset = avAsset
            
            self.thumbtimeSeconds = Int(Double(CMTimeGetSeconds(avAsset.duration)))
           
            self.playVideo()
            
            let assetTrack = avAsset.tracks(withMediaType: .video).first
            guard let assetTrack = assetTrack else {
                return
            }

            let videoInfo = self.orientation(from: assetTrack.preferredTransform)
            let videoSize: CGSize
            if videoInfo.isPortrait {
              videoSize = CGSize(
                width: assetTrack.naturalSize.height,
                height: assetTrack.naturalSize.width)
                print("========== portait")
            } else {
              videoSize = assetTrack.naturalSize
                print("========== landscape")
            }
            
            self.videoInitialSize = videoSize
            self.finalHeight = videoSize.height
            self.finalWidth = videoSize.width
            
            let transformedVideoSize = assetTrack.naturalSize.applying(assetTrack.preferredTransform)
            let videoIsPortrait = abs(transformedVideoSize.width) < abs(transformedVideoSize.height)
            
            print(videoIsPortrait, " portait is =======================")
            
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
                
        let step = Float(video.duration.seconds) / 16
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
//            videoView.layer.addSublayer(backavPlayerLayer)
            videoView.layer.addSublayer(avPlayerLayer)
            player.play()
            generateVideoPreviewImage(for: myAsset, with: .zero)
            
            startTimestr = "\(0.0)"
            endTimestr   = "\(thumbtimeSeconds!)"
            
            createImageFrames()
            createrangSlider()
            setupTrim()
            timeObserber()
        }
        
        NotificationCenter.default
            .addObserver(self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }
    
    func timeObserber(){
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [self] (CMTime) -> Void in
                    if self.player!.currentItem?.status == .readyToPlay {
                        let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                        
                        for subview in stickerContainerview.subviews {
                            if let tmp = subview as? StickerView {
                                if Int64(tmp.startTime) == Int64(time) {
                                    subview.isHidden = false
//                                    print(Int64(tmp.startTime), Int64(time))
                                }else if Int64(tmp.endTime) == Int64(time) {
                                    subview.isHidden = true
//                                    print(Int64(tmp.endTime), Int64(time))
                                }else {
//                                   print(Int64(tmp.endTime), Int64(time))
                                }
                            }
                        }
                        
//                        if audioPlayer != nil {
//                            if time > audioPlayer.duration {print("hello");audioPlayer.pause()}
//                        }
                       
                        if let duration = player.currentItem?.duration {
                            let totalSeconds = CMTimeGetSeconds(duration)
                            let value = Float64(time) / totalSeconds
                            
                        }
    //                        self.playbackSlider!.value = Float ( time );
                    }
                }
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
    
    func imageFromLayer(layer:CALayer) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, layer.isOpaque, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
    
  
    let context = CIContext(options: nil)
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        
        return nil
    }
    
    func imageWithLayer(layer: CALayer) -> CGImage {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.isOpaque, 1.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        return img!.cgImage!
    }
    
    func applyFilterBeforeExport( onComplete : @escaping(URL?) -> Void){
        
//        asset = AVURLAsset.init(url: url)
        asset = myAsset as! AVURLAsset
        guard let asset = asset else {
            return
        }
        
        let composition = AVMutableVideoComposition(asset: asset, applyingCIFiltersWithHandler: { [self] request in
            
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
            
            let firstImage = convertCIImageToCGImage(inputImage: output)
            
            let destWidth : CGFloat = 720
            let destHeight : CGFloat = 720
            
            let size: CGSize = CGSize(width: destWidth, height: destHeight)
            
            let backgroundImage = output.toUIImage()
            let topImage = backgroundImage
//            let topmstImage = topmostImage
            
            UIGraphicsBeginImageContextWithOptions(size, false , 1)
            backgroundImage?.draw(in: CGRect(x: 0, y: 0, width: destWidth, height: destHeight), blendMode: .normal, alpha: 1)
            topImage?.draw(in: CGRect(x: 0, y: (720 - 405) / 2, width: 720, height: 405), blendMode: .normal, alpha: 1)
//            topmstImage?.draw(in: CGRect(x: 0, y: 0, width: destWidth, height: destHeight), blendMode: .normal, alpha: 1)
            let finallImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            

            let outputImagee = finallImage?.toCIImage() ?? request.sourceImage
            
//            let backUIImage = applyBlurfilter(filter.outputImage!.toUIImage())
//            let backImag1 = firstImage
//            let backImage = firstImage //convertCIImageToCGImage(inputImage: backImag1)
//
////            if(rotate){
////                //you can rotate the image however you see fit or need to
////                //you can also attach additional instruction to help you
////                //determine the necessary changes
////            }
//
//            let destWidth : CGFloat = 720
//            let destHeight : CGFloat = 720
//
//            //we will be using CALayers to make overlaying sumer simple
//            let frame = CGRect(x: 0, y: 0, width: destWidth , height: destHeight)
//            let topFrame = CGRect(x: 0, y: 0, width: request.sourceImage.extent.width, height: request.sourceImage.extent.height)
//            //this will be the background frame size
////            let innerFrame = CGRect(x: 0, y: 0,
////                                    width: 1280,
////                                    height: 720)
//            //this will be the overlayFrameSize
//            let backgroundLayer = CALayer()
//            backgroundLayer.frame = frame
//            backgroundLayer.contentsGravity = .resizeAspectFill
//            backgroundLayer.contents = backImage
////create the backgroundLayer and fill it with firstImag
//            let overLayLayer = CALayer()
//            overLayLayer.frame = topFrame
//            overLayLayer.contentsGravity = .resizeAspect
//            overLayLayer.contents = firstImage
//
////            let sticketLayer = CALayer()
////            sticketLayer.frame = frame
////            sticketLayer.contentsGravity = .resizeAspectFill
////            sticketLayer.contents = instruction.stickerImage
////create the overlay layer and fill it with secondImg
//            let finalLayer = CALayer()
//            finalLayer.frame = frame
//            finalLayer.backgroundColor = UIColor.clear.cgColor
//            finalLayer.addSublayer(backgroundLayer)
//            finalLayer.addSublayer(overLayLayer)
////            finalLayer.addSublayer(sticketLayer)
//            //add the two layers onto the final layer
//            //make sure you add the backgroundLayer first
//            //and then the overlay Layer
//             let fullImg = imageWithLayer(layer: finalLayer)
//            let outputImagee = fullImg.convertCGImageToCIImage()
            
            request.finish(with: outputImagee, context: nil)
      })
        
        composition.renderSize = CGSize(width: 720, height: 720)
        
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
          .appendingPathComponent("videoName")
          .appendingPathExtension("mov")

        self.deleteFile(exportURL)

        //export the video to as per your requirement conversion
       export = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        
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
    
    func applyTrimCut(onComplete : @escaping (URL?) -> Void){
        if cutEnabled {
            getCutedVideo1{ [self] url1 in
                getCutedVideo2 { [self] url2 in
                    MKOVideoMerge.mergeVideoFiles([url1, url2]){ url, err in
                        if (err != nil){
                            print("error in mergin videos")
                            return
                        }
                        onComplete(url)
                    }
                }
            }
        }else {
            trimmedVieo { url in
                onComplete(url)
            }
        }
    }
    
    func mergedVieo(onComplete : @escaping (URL?) -> Void){
        
    }
    
    func getCutedVideo2(onComplete : @escaping (URL?) -> Void) {
        let end = Float(endTimestr) ?? 0
        let startTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
//        let timeRange = CMTimeRange(start: startTime, end: CMTime(value: CMTimeValue(myAsset.duration.seconds), timescale: 1000))

        let timeRange = CMTimeRange(start: startTime, duration: CMTime(seconds: myAsset.duration.seconds - Double(end), preferredTimescale: 1000))
        
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
          .appendingPathComponent("videoName2")
          .appendingPathExtension("mov")

        self.deleteFile(exportURL)

        //export the video to as per your requirement conversion
       export = AVAssetExportSession(asset: myAsset, presetName: AVAssetExportPresetHighestQuality)
        
        guard let export = export else {
            return
        }
        
        export.outputFileType = AVFileType.mov
        export.outputURL = exportURL
        export.timeRange = timeRange

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
    }
    
    func getCutedVideo1(onComplete : @escaping (URL?) -> Void) {
        let start = Float(startTimestr) ?? 0
        let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: CMTime(value: 0, timescale: 1000), duration: startTime)
        
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
          .appendingPathComponent("videoName1")
          .appendingPathExtension("mov")

        self.deleteFile(exportURL)

        //export the video to as per your requirement conversion
       export = AVAssetExportSession(asset: myAsset, presetName: AVAssetExportPresetHighestQuality)
        
        guard let export = export else {
            return
        }
        
        export.outputFileType = AVFileType.mov
        export.outputURL = exportURL
        export.timeRange = timeRange

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
    }
    
    func trimmedVieo(onComplete : @escaping(URL?) -> Void){
        let start = Float(startTimestr) ?? 0
        let end   = Float(endTimestr) ?? Float(myAsset.duration.seconds)
        
        let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
        let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        
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
        export.timeRange = timeRange

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
    
    var asset : AVURLAsset?
    
    func exportVideo(onComplete: @escaping (URL?) -> Void){
        
//        applyTrimCut { [self] url in
//            guard let url = url else {
//                return
//            }
//        applyFilterBeforeExport{ [self] url in
                
//                onComplete(url)
                
                DispatchQueue.main.async { [self] in
//                    asset = AVURLAsset.init(url: url)
                    asset = myAsset as! AVURLAsset
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

                    print(videoSize, "video size")


                    let fWidth : CGFloat = 720
                    let fHeight : CGFloat = 720

                    let extendedSize = CGSize(width: fWidth, height: fHeight)

//                    print(extendedSize, "extended size")

                    let videoLayer = CALayer()
                    videoLayer.frame = CGRect(origin: .zero, size: extendedSize)
                    let overlayLayer = CALayer()
                    overlayLayer.frame = CGRect(origin: .zero, size: extendedSize)

//                    add(image: UIImage(named: "101")!, to: overlayLayer, frame: CGRect(x: 100, y: 100, width: 200, height: 200))
                    
                    addingSticker(to: overlayLayer, vSize: extendedSize)

                    let outputLayer = CALayer()
                    outputLayer.frame =  CGRect(origin: .zero, size: extendedSize)
                    outputLayer.addSublayer(videoLayer)
                    outputLayer.addSublayer(overlayLayer)

                    let passingImage = stickerContainerview.asImage().cgImage

                    let instruction1 = CustomOverlayInstruction(timerange: CMTimeRange(start: .zero, duration: asset.duration) , rotateSecondAsset:true, stickerImage: passingImage!, currentFilter: currentFilter , br: brightness, con: contrast, sat: saturation, width: finalWidth, height: finalHeight)

//                    let instruction2 = VideoFilterCompositionInstruction(timeRange: CMTimeRange(start: .zero, duration: asset.duration) ,sticker: passingImage!, dukse: true)

                    let videoComposition = AVMutableVideoComposition()
                    videoComposition.renderSize = extendedSize
                    videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
                    videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
                      postProcessingAsVideoLayer: videoLayer,
                      in: outputLayer)

                    videoComposition.customVideoCompositorClass = CustomCompositor.self


                    let instruction = AVMutableVideoCompositionInstruction()
                    instruction.timeRange = CMTimeRange(
                      start: .zero,
                      duration: compositionnn.duration)
                    videoComposition.instructions = [instruction1]
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

//                    self.deleteFile(url)

        //            let videoName = UUID().uuidString
                    let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
                      .appendingPathComponent("videoName32")
                      .appendingPathExtension("mov")
                    
                    self.deleteFile(exportURL)

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
//                }
//            }
        }
        
    }
    
    @objc func fireTimer(){
//        print("heyy", export?.progress)
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
      
        self.selectedStickerView?.showEditingHandlers = false
        player.pause()
        applyFilterBeforeExport { exportedURL in
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
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//
//        return CGSize(width: 40, height: 60)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//        return imagesFromVideo.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
////        let cell = toolbarCollectionView.dequeueReusableCell(withReuseIdentifier: "ToolbarCollectionViewCell", for: indexPath) as! ToolbarCollectionViewCell
////
////        cell.imageView.image = imagesFromVideo[indexPath.row]
////        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//
//
//
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
    
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
       
        let totalSecond = myAsset.duration.seconds
        
         composition = AVVideoComposition(asset: myAsset, applyingCIFiltersWithHandler: { [self] request in
             var outputImage : CIImage = request.sourceImage
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
        
        topmostImage = stickerContainerview.asImage()
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
        stickerView3.tag = 1
        stickerView3.startTime = 4
        stickerView3.endTime = 8
        stickerView3.isHidden = true
        self.stickerContainerview.addSubview(stickerView3)
        self.selectedStickerView = stickerView3
        registerStickerForUndoRedo(0, 0, stkview: stickerView3, startTime: 4, endTime: 8)
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
        stickerView3.tag = 2
        stickerView3.startTime = 1
        stickerView3.endTime = 6
        stickerView3.isHidden = true
        self.stickerContainerview.addSubview(stickerView3)
        self.selectedStickerView = stickerView3
        registerStickerForUndoRedo(1, 1, stkview: stickerView3, startTime: 1, endTime: 6)
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
        stickerView3.tag = 3
        stickerView3.startTime = 7
        stickerView3.endTime = 15
        stickerView3.isHidden = true
        self.stickerContainerview.addSubview(stickerView3)
        self.selectedStickerView = stickerView3
        registerStickerForUndoRedo(2, 2, stkview: stickerView3, startTime: 7, endTime: 15)
    }
    
    // trim
    
    @IBAction func trimAction(_ sender: Any) {
        trimView.isHidden = false
        filterView.isHidden = true
        canvasView.isHidden = true
    }
    
    @IBAction func trimDoneAction(_ sender: Any) {
        trimView.isHidden = true
        filterView.isHidden = false
        canvasView.isHidden = false
    }
    
    
    //MARK: CreatingFrameImages
    func createImageFrames()
    {
        //creating assets
        let assetImgGenerate : AVAssetImageGenerator    = AVAssetImageGenerator(asset: myAsset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter    = CMTime.zero;
        assetImgGenerate.requestedTimeToleranceBefore   = CMTime.zero;
        
        
        assetImgGenerate.appliesPreferredTrackTransform = true
        let thumbTime: CMTime = myAsset.duration
        let thumbtimeSeconds  = Int(CMTimeGetSeconds(thumbTime))
        let maxLength         = "\(thumbtimeSeconds)" as NSString
        
        let thumbAvg  = thumbtimeSeconds/6
        var startTime = 1
        var startXPosition:CGFloat = 0.0
        
        //loop for 6 number of frames
        for _ in 0...5
        {
            
            let imageButton = UIButton()
            let xPositionForEach = CGFloat(self.trimFrameView.frame.width)/6
            imageButton.frame = CGRect(x: CGFloat(startXPosition), y: CGFloat(0), width: xPositionForEach, height: CGFloat(self.trimFrameView.frame.height))
            do {
                let time:CMTime = CMTimeMakeWithSeconds(Float64(startTime),preferredTimescale: Int32(maxLength.length))
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: img)
                imageButton.setImage(image, for: .normal)
            }
            catch
                _ as NSError
            {
                print("Image generation failed with error (error)")
            }
            
            startXPosition = startXPosition + xPositionForEach
            startTime = startTime + thumbAvg
            imageButton.isUserInteractionEnabled = false
            trimFrameView.addSubview(imageButton)
        }
        
    }
    
    func createrangSlider()
    {
        //Remove slider if already present
        let subViews = self.frameContainerView.subviews
        for subview in subViews{
            if subview.tag == 1000 {
                subview.removeFromSuperview()
            }
        }
        
        rangSlider = RangeSlider(frame: frameContainerView.bounds)
        frameContainerView.addSubview(rangSlider)
        rangSlider.tag = 1000
        
        //Range slider action
        rangSlider.addTarget(self, action: #selector(rangSliderValueChanged(_:)), for: .valueChanged)
        
        let time = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.rangSlider.trackHighlightTintColor = UIColor.clear
            self.rangSlider.curvaceousness = 1.0
        }
        
    }
    
    @IBAction func segmentedSliderValueChanged(_ sender: Any) {
        if((self.segmentedControl.selectedSegmentIndex) != 0){
            self.rangSlider.trackHighlightTintColor = UIColor.black.withAlphaComponent(0.5)
            self.rangSlider.trimTintColor = UIColor.clear
        }else {
            self.rangSlider.trackHighlightTintColor = UIColor.clear
            self.rangSlider.trimTintColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    //MARK: rangSlider Delegate
    @objc func rangSliderValueChanged(_ rangSlider: RangeSlider) {
//        self.player.pause()
        
        if((self.segmentedControl.selectedSegmentIndex) != 0){
            self.rangSlider.trackHighlightTintColor = UIColor.black.withAlphaComponent(0.5)
            self.rangSlider.trimTintColor = UIColor.clear
        }else {
            self.rangSlider.trackHighlightTintColor = UIColor.clear
            self.rangSlider.trimTintColor = UIColor.black.withAlphaComponent(0.5)
        }
        
        if(isSliderEnd == true)
        {
            rangSlider.minimumValue = 0.0
            rangSlider.maximumValue = Double(thumbtimeSeconds)
            
            rangSlider.upperValue = Double(thumbtimeSeconds)
            isSliderEnd = !isSliderEnd
        }
        
        startTimestr = "\(rangSlider.lowerValue)"
        endTimestr   = "\(rangSlider.upperValue)"
        
        startingTime.text = String(format: "%.2f", rangSlider.lowerValue/60)
        endingTime.text = String(format: "%.2f", rangSlider.upperValue/60)
        

        if(rangSlider.lowerLayerSelected)
        {
            self.seekVideo(toPos: CGFloat(rangSlider.lowerValue))
        }
        else
        {
            self.seekVideo(toPos: CGFloat(rangSlider.upperValue))
            
        }
        
//        print(startTime)
    }
    
    // advance trim
    func disableSeekPosControl(_ infoDict: [AnyHashable : Any]?) {

//        print(infoDict?["contentOffset"], "hello")
        
        let leftOverlayOriginX = CGFloat((infoDict?["lefttOverlayViewOrigin"] as? NSString)?.doubleValue ?? 0.0 )
        let rightOverlayOriginX = CGFloat((infoDict?["rightOverlayViewOrigin"] as? NSString)?.doubleValue ?? 0.0 )
//        let contentOffsetX = CGFloat((infoDict?["contentOffset"])! as! NSNumber) ?? 0.0
        let contentOffsetX = CGFloat((infoDict?["contentOffset"] as? NSString)?.doubleValue ?? 0.0 )
        let currentPosition = CGFloat((infoDict?["currentPosition"] as? NSString)?.doubleValue ?? 0.0 )
        
        currentTimeLabel.text = Utility.second(toTimeFormat: currentPosition)
        seekVideo(toPos: currentPosition)
        
        print(contentOffsetX, currentPosition, rightOverlayOriginX)
        
        if contentOffsetX + UIScreen.main.bounds.width / 2 >= rightOverlayOriginX {
            startPosButton.setImage(UIImage(named: "end_here_after_press"), for: .normal)
            startPosButton.isEnabled = false
        }else if contentOffsetX + UIScreen.main.bounds.width / 2 <= leftOverlayOriginX {
            endPosButton.setImage(UIImage(named: "end_here_after_press_2"), for: .normal)
            endPosButton.isEnabled = false
        }else {
            startPosButton.setImage(UIImage(named: "end_here"), for: .normal)
            startPosButton.isEnabled = true
            endPosButton.setImage(UIImage(named: "end_here_2"), for: .normal)
            endPosButton.isEnabled = true
        }
    }
    
    var startTimee : CGFloat = 0.0
    var stopTimee : CGFloat = 0.0
    
    func trimmerView(_ trimmerView: ICGVideoTrimmerView?, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
       
        restartOnPlay = true
        player.pause()
        isPlaying = false
//        stopPlaybackTimeChecker()
        trimmerView?.hideTracker(true)

        if startTime != startTime {
            //then it moved the left position, we should rearrange the bar
            seekVideoo(toPos: startTime)
        } else {
            // right has changed
            seekVideoo(toPos: endTime)
        }
        self.startTimee = startTime
        self.stopTimee = endTime

        startTimeLabel.text = Utility.second(toTimeFormat: startTime)

        endTimeLabel.text = Utility.second(toTimeFormat: endTime)
    }
    
    func seekVideoo(toPos pos: CGFloat) {
        videoPlaybackPosition = pos
        let time = CMTimeMakeWithSeconds(videoPlaybackPosition, preferredTimescale: 20)
        print(String(format: "seekVideoToPos time:%.2f %.2d", CMTimeGetSeconds(time), player.currentTime().timescale))
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func deleteTempFile(_ videoFilePath: String?) {
        let url = URL(fileURLWithPath: videoFilePath ?? "")
        let fm = FileManager.default
        let exist = fm.fileExists(atPath: url.path)
        let err: Error? = nil
        
        if exist {
            do {
                try fm.removeItem(at: url)
            } catch let err {
                print(err.localizedDescription)
            }
            print("file deleted")
            if (err != nil) {
                print("file remove error, \(err?.localizedDescription)")
            }
        }else {
            print("No file with that name")
        }
    }
    
    @IBAction func endButtonAction(_ sender: Any) {
        trimmerView.setPointEnd()

    }

    @IBAction func startButtonAction(_ sender: Any) {

        trimmerView.setPointStart()

    }
    
    @IBAction func trimCutDoneAction(_ sender: Any) {
        if((segmentedControl.selectedSegmentIndex) != 0){
            cutEnabled = true
        }else {
            trimEnabled = true
        }
    }
    
    
    //Seek video when slide
    func seekVideo(toPos pos: CGFloat) {
        self.videoPlaybackPosition = pos
        let time: CMTime = CMTimeMakeWithSeconds(Float64(self.videoPlaybackPosition), preferredTimescale: self.player.currentTime().timescale)
        self.player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        if(pos == CGFloat(thumbtimeSeconds))
        {
            self.player.pause()
        }
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
    
    // canvas
    
    
    @IBAction func fitAction(_ sender: Any) {
        let vratio:CGFloat = videoInitialSize.height/videoInitialSize.width
        
        let hh = vratio * h
        
        print(vratio, hh)
        
        if hh <= h {
      
            let topS = (h - (w * vratio)) / 2
            
            videoViewHeightCon.constant = w * vratio
            videoViewLeadingCon.constant = 0
            videoViewTrailingCon.constant = 0
            videoViewTopCon.constant = topS + 20
            
            videoView.layoutIfNeeded()
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1){ [self] in
                avPlayerLayer.frame = videoView.bounds
            }
            
            finalWidth = videoInitialSize.width
            finalHeight = videoInitialSize.height
        }else {
            
            let val = h / vratio

            videoViewLeadingCon.constant = (w - val) / 2
            videoViewTrailingCon.constant = (w - val) / 2
            videoViewHeightCon.constant = h
            videoViewTopCon.constant = 20
            
            videoView.layoutIfNeeded()
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1){ [self] in
                avPlayerLayer.frame = videoView.bounds
            }
            
            finalWidth = videoInitialSize.width
            finalHeight = videoInitialSize.height
        }
        
//        let topS = ( h - val ) / 2
//
       
    }
    
    func setfinalWidtHeight(_ w : CGFloat, _ h : CGFloat){
        finalWidth = videoInitialSize.width * w
        finalHeight = videoInitialSize.height * h
    }
    
    @IBAction func onebyoneAction(_ sender: Any) {
        let hh = h
        if hh > w {
            changeHeight(1, 1)
        }else {
            changeWidth(hh)
        }
        
        if videoInitialSize.width > videoInitialSize.height {
            finalWidth = videoInitialSize.width
            finalHeight = videoInitialSize.width
        }else {
            finalHeight = videoInitialSize.height
            finalWidth = videoInitialSize.height
        }
    }
    
    @IBAction func oneByTwo(_ sender: Any) {
        let hh = h / 2 * 1
        if hh > w {
            changeHeight(1, 2)
        }else {
            changeWidth(hh)
        }
        
        if videoInitialSize.width > videoInitialSize.height {
            finalWidth = videoInitialSize.width
            finalHeight = videoInitialSize.width * 2
        }else {
            finalHeight = videoInitialSize.height
            finalWidth = videoInitialSize.height / 2
        }

    }
    
    @IBAction func twoByone(_ sender: Any) {
        let hh = h / 1 * 2
        if hh > w {
            changeHeight(2, 1)
        }else {
            changeWidth(hh)
        }
        
        if videoInitialSize.width > videoInitialSize.height {
            finalWidth = videoInitialSize.width
            finalHeight = videoInitialSize.width / 2
        }else {
            finalHeight = videoInitialSize.height
            finalWidth = videoInitialSize.height * 2
        }

    }
    
    @IBAction func sixtenbynine(_ sender: Any) {
        let hh = h / 9 * 16
        if hh > w {
            changeHeight(16, 9)
        }else {
            changeWidth(hh)
        }
        
        if videoInitialSize.width > videoInitialSize.height {
            finalWidth = videoInitialSize.width
            finalHeight = videoInitialSize.width * 9 / 16
        }else {
            finalHeight = videoInitialSize.height
            finalWidth = videoInitialSize.height * 16 / 9
        }

    }
    @IBAction func nineBysixteen(_ sender: Any) {
        let hh = h / 16 * 9
        if hh > w {
            changeHeight(9, 16)
        }else {
            changeWidth(hh)
        }
        
        if videoInitialSize.width > videoInitialSize.height {
            finalWidth = videoInitialSize.width
            finalHeight = videoInitialSize.width * 16 / 9
        }else {
            finalHeight = videoInitialSize.height
            finalWidth = videoInitialSize.height * 9 / 16
        }

    }
    
    @IBAction func foutbyfive(_ sender: Any) {
        let hh = h / 5 * 4
        if hh > w {
            changeHeight(4, 5)
        }else {
            changeWidth(hh)
        }
        
        if videoInitialSize.width > videoInitialSize.height {
            finalWidth = videoInitialSize.width
            finalHeight = videoInitialSize.width * 5 / 4
        }else {
            finalHeight = videoInitialSize.height
            finalWidth = videoInitialSize.height * 4 / 5
        }

    }
    
    @IBAction func fivebyfour(_ sender: Any) {
        let hh = h / 4 * 5
        if hh > w {
            changeHeight(5, 4)
        }else {
            changeWidth(hh)
        }
        
        if videoInitialSize.width > videoInitialSize.height {
            finalWidth = videoInitialSize.width
            finalHeight = videoInitialSize.width * 4 / 5
        }else {
            finalHeight = videoInitialSize.height
            finalWidth = videoInitialSize.height * 5 / 4
        }

    }
   
    func changeHeight(_ val1 : CGFloat, _ val2 : CGFloat){
       
        let val = w / val1 * val2
        let topS = ( h - val ) / 2
        
        videoViewHeightCon.constant = val
        videoViewLeadingCon.constant = 0
        videoViewTrailingCon.constant = 0
        videoViewTopCon.constant = topS + 20
        
        curHeight = val
        
        videoView.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1){ [self] in
            avPlayerLayer.frame = videoView.bounds
        }
        
        
        
//        videoView.transform = .identity
    }
    
    func changeWidth(_ val : CGFloat){
     
        videoViewLeadingCon.constant = (w - val) / 2
        videoViewTrailingCon.constant = (w - val) / 2
        videoViewHeightCon.constant = h
        videoViewTopCon.constant = 20
        
        videoView.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1){ [self] in
            avPlayerLayer.frame = videoView.bounds
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
        setPanRoateOfStickerForUndoRedo(stickerView)
    }
    
    func stickerViewDidBeginRotating(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidChangeRotating(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidEndRotating(_ stickerView: StickerView) {
        setPanRoateOfStickerForUndoRedo(stickerView)
    }
    
    func stickerViewDidClose(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidTap(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
    }
    
    func add(image: UIImage, to layer: CALayer, frame: CGRect) {
//        let attributedText = NSAttributedString(
//          string: "hello world",
//          attributes: [
//            .font: UIFont(name: "ArialRoundedMTBold", size: 60) as Any,
//            .foregroundColor: UIColor.green,
//            .strokeColor: UIColor.white,
//            .strokeWidth: -3])
//
//        let textLayer = CATextLayer()
//        textLayer.string = attributedText
//        textLayer.shouldRasterize = true
//        textLayer.rasterizationScale = UIScreen.main.scale
//        textLayer.backgroundColor = UIColor.clear.cgColor
//        textLayer.alignmentMode = .center
//
//        textLayer.frame = frame
//        textLayer.displayIfNeeded()
        
        let stickerLayer = CALayer()
        stickerLayer.backgroundColor = UIColor.clear.cgColor
        stickerLayer.contentsGravity = .center
        stickerLayer.contents = image.cgImage
        
        stickerLayer.frame = layer.bounds
        
        let degrees = 30.0
        let radians = CGFloat(degrees * M_PI / 180)
        stickerLayer.transform = CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0)
        
        stickerLayer.displayIfNeeded()
        

        stickerLayer.opacity = 0
        let startVisible = CABasicAnimation(keyPath: "opacity")
        startVisible.duration = 0.1 // for appearing in duration
        startVisible.repeatCount = 1
        startVisible.fromValue = 0.0
        startVisible.toValue = 1.0
        startVisible.beginTime = AVCoreAnimationBeginTimeAtZero  // overlay time range start second
        startVisible.isRemovedOnCompletion = false
        startVisible.fillMode = CAMediaTimingFillMode.forwards
        stickerLayer.add(startVisible, forKey: "startAnimation")

        let endVisible = CABasicAnimation(keyPath: "opacity")
        endVisible.duration = 0.1 // for disappearing in duration
        endVisible.repeatCount = 1
        endVisible.fromValue = 1.0
        endVisible.toValue = 0.0
        endVisible.beginTime = 2.0 // overlay time range end second
        endVisible.fillMode = CAMediaTimingFillMode.forwards
        endVisible.isRemovedOnCompletion = false
        stickerLayer.add(endVisible, forKey: "endAnimation")

        layer.addSublayer(stickerLayer)
    }
    
    func addingSticker(to layer : CALayer, vSize : CGSize){
        
        for stk in allStickers {
            
            let stickerLayer = CALayer()
            stickerLayer.shouldRasterize = true
            stickerLayer.rasterizationScale = UIScreen.main.scale
            stickerLayer.backgroundColor = UIColor.clear.cgColor
            stickerLayer.contentsGravity = .resizeAspect
            stickerLayer.contents = UIImage(named: stickerNames[stk.selectedStickerCategroy])?.cgImage

            let w = vSize.width * stk.stickerFrame.width / videoView.bounds.width
            let h = vSize.height * stk.stickerFrame.height / videoView.bounds.height
            let x = vSize.width * stk.stickerFrame.origin.x / videoView.bounds.width
            let y = vSize.height - h - (vSize.height * stk.stickerFrame.origin.y / videoView.bounds.height)
            
            print(stk.stickerFrame.origin.x, videoView.bounds.width, "only x x")
            print(x, y, w, h , "x, y, w ,h")
            stickerLayer.frame = CGRect(x: x, y: y, width: w, height: h)
            
            //            print(stk.stickerFrame, layer.frame, "framemememme")
            
            stickerLayer.transform = CATransform3DMakeRotation(stk.stickerRadian, 0.0, 0.0, 1.0)
            stickerLayer.layoutIfNeeded()
            
            
            stickerLayer.opacity = 0
            let startVisible = CABasicAnimation(keyPath: "opacity")
            startVisible.duration = 0.1 // for appearing in duration
            startVisible.repeatCount = 1
            startVisible.fromValue = 0.0
            startVisible.toValue = 1.0
            startVisible.beginTime = AVCoreAnimationBeginTimeAtZero + stk.startTime  // overlay time range start second
            startVisible.isRemovedOnCompletion = false
            startVisible.fillMode = CAMediaTimingFillMode.forwards
            stickerLayer.add(startVisible, forKey: "startAnimation")

            let endVisible = CABasicAnimation(keyPath: "opacity")
            endVisible.duration = 0.1 // for disappearing in duration
            endVisible.repeatCount = 1
            endVisible.fromValue = 1.0
            endVisible.toValue = 0.0
            endVisible.beginTime = stk.endTime // overlay time range end second
            endVisible.fillMode = CAMediaTimingFillMode.forwards
            endVisible.isRemovedOnCompletion = false
            stickerLayer.add(endVisible, forKey: "endAnimation")

            layer.addSublayer(stickerLayer)
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0){
                print(stickerLayer.frame, "frame")
            }
        }
        
        
    }
    
    func registerStickerForUndoRedo(_ category : Int, _ content : Int, stkview : StickerView, startTime : Float64, endTime : Float64){
        let newStickerObject = StickerValueModel(selectedStickerCategroy: category, selectedStickerContent: content, stickerFrame: CGRect(origin: CGPoint(x: stkview.frame.origin.x + 12, y: stkview.frame.origin.y + 12) , size: stkview.contentView.bounds.size) , stickerOrigin: stkview.center, stickerRadian: 0, stickerAlpha: 1, isFlipped: false, stickerTag: stkview.tag, startTime: startTime, endTime: endTime )
        
        allStickers.append(newStickerObject)
    }
    
    func setPanRoateOfStickerForUndoRedo(_ stickerView: StickerView){
        for indx in stride(from: 0, to: allStickers.count, by: 1){
            if allStickers[indx].stickerTag == stickerView.tag {
                print(allStickers[indx].stickerTag, "tag")
                allStickers[indx].stickerFrame = CGRect(origin: CGPoint(x: stickerView.frame.origin.x + 12, y: stickerView.frame.origin.y + 12) , size: stickerView.contentView.bounds.size)
                allStickers[indx].stickerOrigin = stickerView.center
                allStickers[indx].stickerRadian = CGFloat(stickerView.rotation)
            }
        }
    }
}






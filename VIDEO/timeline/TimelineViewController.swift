//
//  TimelineViewController.swift
//  VIDEO
//
//  Created by appsyneefo on 1/26/23.
//

import UIKit
import Photos
import AVKit
import AVFoundation

class TimelineViewController: UIViewController, UIGestureRecognizerDelegate{
   
    var thumbWidth : Double = 16
    var allStickers : [StickerValueModel] = []
    var stickerTag : Int = 1
    @IBOutlet weak var stickerContainerView: UIView!
    @IBOutlet weak var myTimelineContainerView: UIView!
    @IBOutlet weak var playPuaseButton: UIButton!
    
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
    
    var stickerContentHight : CGFloat = 35
    var imgGenerator : AVAssetImageGenerator?
    var player : AVPlayer!
    var avPlayerLayer : AVPlayerLayer!
    var playerItem : AVPlayerItem!
    
    @IBOutlet weak var videoPlayerView: UIView!
    var selectedTimeline : BoundLayer?
    var lastContentOffset : CGPoint = .zero
    var initialContentOffset : CGFloat = .zero
    
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var miliSecLabel: UILabel!
    
    
    let test = CustomView(frame: .zero)
    let test1 = CustomView(frame: .zero)
    let test2 = CustomView(frame: .zero)
    let test3 = CustomView(frame: .zero)
    let test4 = CustomView(frame: .zero)
    let test5 = CustomView(frame: .zero)
    let test6 = CustomView(frame: .zero)
    
    @IBOutlet weak var contentPuttingStack: UIStackView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var widthofContents: NSLayoutConstraint!
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var thumbCollectionView: UICollectionView!
    private var imageGenerator: AVAssetImageGenerator?
    
    var phAsset : PHAsset? = nil
    var myAsset : AVAsset!
    var thumbImgArray : [UIImage] = []
    
    var panGes : UIPanGestureRecognizer?
    var tmppanGes : UIPanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ThumbCollectionViewCell", bundle: nil)
        thumbCollectionView.register(nib, forCellWithReuseIdentifier: "ThumbCollectionViewCell")
        thumbCollectionView.dataSource = self
        thumbCollectionView.delegate = self
        
//        let nib2 = UINib(nibName: "ContentTableViewCell", bundle: nil)
//        contentTableView.register(nib2, forCellReuseIdentifier: "ContentTableViewCell")
//        contentTableView.dataSource = self
//        contentTableView.delegate = self
        
        contentScrollView.contentInset = UIEdgeInsets(top: 0, left: view.bounds.width/2 - 40, bottom: 0, right: view.bounds.width/2-40)
        thumbCollectionView.contentInset = UIEdgeInsets(top: 0, left: view.bounds.width/2-40, bottom: 0, right: view.bounds.width/2-40)
        prepareVideo()
//        test.translatesAutoresizingMaskIntoConstraints = false
//        test1.translatesAutoresizingMaskIntoConstraints = false
//        test2.translatesAutoresizingMaskIntoConstraints = false
//        test3.translatesAutoresizingMaskIntoConstraints = false
//        test4.translatesAutoresizingMaskIntoConstraints = false
//        test5.translatesAutoresizingMaskIntoConstraints = false
//        test6.translatesAutoresizingMaskIntoConstraints = false

        let uiv = UIView()
        uiv.addSubview(UIView())
        contentPuttingStack.addArrangedSubview(uiv)
        contentPuttingStack.addArrangedSubview(uiv)
//        contentPuttingStack.addArrangedSubview(test1)
//        contentPuttingStack.addArrangedSubview(test2)
//        contentPuttingStack.addArrangedSubview(test3)
//        contentPuttingStack.addArrangedSubview(test4)
//        contentPuttingStack.addArrangedSubview(test5)
//        contentPuttingStack.addArrangedSubview(test6)
//
//        test.heightAnchor.constraint(equalToConstant: 0).isActive = true
//        test1.heightAnchor.constraint(equalToConstant: 35).isActive = true
//        test2.heightAnchor.constraint(equalToConstant: 35).isActive = true
//        test3.heightAnchor.constraint(equalToConstant: 35).isActive = true
//        test4.heightAnchor.constraint(equalToConstant: 35).isActive = true
//        test5.heightAnchor.constraint(equalToConstant: 35).isActive = true
//        test6.heightAnchor.constraint(equalToConstant: 35).isActive = true
       
        
        contentScrollView.delegate = self
        initialContentOffset = thumbCollectionView.contentOffset.x
        
        addgesture(myTimelineContainerView)
//        addgesture(thumbCollectionView)
    }
    
    @objc func rangeSliderValueChanged(_ rangeSlider: BoundLayer) {
        if rangeSlider.superview is CustomView {
            let st = rangeSlider.superview?.subviews[0]
            if st is CustomView2 {
                print(rangeSlider.lowerValue, rangeSlider.upperValue, "two value")
                let width : Double = (rangeSlider.upperValue * 30) - (rangeSlider.lowerValue * 30) - thumbWidth
                st!.frame = CGRect(x: Int(ceil(rangeSlider.lowerValue * 30))+30, y: 0, width: Int(ceil(width)) , height: 35)
                st?.superview?.layoutIfNeeded()
                
                let tagg = st?.tag
                for indx in stride(from: 0, to: allStickers.count, by: 1){
                    if allStickers[indx].stickerTag == tagg {
                        allStickers[indx].startTime = rangeSlider.lowerValue
                        allStickers[indx].endTime = rangeSlider.upperValue - 1
                        break
                    }
                }
                for suv in stickerContainerView.subviews {
                    if let suvv = suv as? StickerView, suvv.tag == tagg {
                        suvv.startTime = rangeSlider.lowerValue
                        suvv.endTime = rangeSlider.upperValue - 1
                        break
                    }
                }
            }
        }
        
       videoPauseAction()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self.view)
            print(touchLocation)
        }
    }
    
    var thumbtimeSeconds : Double = .zero
    var actualVideoDuration : Double = .zero
    var reminidingMilisec : Int = .zero
    func prepareVideo(){
        PHCachingImageManager().requestAVAsset(forVideo: phAsset!, options: nil) { [self] (avAsset, _, _) in
            
            guard let avAsset = avAsset else {
                return
            }
            imgGenerator = AVAssetImageGenerator(asset: avAsset)
            imgGenerator?.appliesPreferredTrackTransform = true
            self.myAsset = avAsset
//            self.generateVideoPreviewImage(for: avAsset)
            let thumbTime: CMTime = avAsset.duration
            let tmp : Double = Double(CMTimeGetSeconds(thumbTime))
            self.actualVideoDuration = tmp
            self.reminidingMilisec = Int(tmp.truncatingRemainder(dividingBy: 1) * 100)
            self.thumbtimeSeconds = ceil(tmp)
            
            playerItem = AVPlayerItem(asset: myAsset)
            player = AVPlayer(playerItem: playerItem)
            player.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
            avPlayerLayer = AVPlayerLayer(player: player)
            avPlayerLayer.frame = videoPlayerView.bounds
            
            DispatchQueue.main.async {
                self.videoPlayerView.layer.addSublayer(self.avPlayerLayer)
                self.callPeriodicTimeObserver()
                self.widthofContents.constant = CGFloat(ceil(tmp + 2) * 30)
                self.thumbCollectionView.reloadData()
                self.videoPlayerView.bringSubviewToFront(self.stickerContainerView)
            }
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        contentScrollView.contentOffset.x = thumbtimeSeconds * 30 + initialContentOffset
        videoPauseAction()
    }

    
    func callPeriodicTimeObserver(){
//        let interval = 0.1  // 100 milliseconds
//        let queue = DispatchQueue.main
//        let observer = player.addPeriodicTimeObserver(forInterval: CMTime(value: interval, timescale: <#T##CMTimeScale#>), queue: queue) {
//          // Your code to be executed every interval
//        }
        NotificationCenter.default
            .addObserver(self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: 1000), queue: DispatchQueue.main) { [self] (CMTime) -> Void in
                    if self.player!.currentItem?.status == .readyToPlay {
                        let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                        if playPuaseButton.titleLabel?.text != "Play" {
                            contentScrollView.contentOffset.x = time * 30 + initialContentOffset
                        }
                        
                    //    print(time, "current time")
//                        self.playbackSlider!.value = Float ( time );
                        for subview in stickerContainerView.subviews {
                            if let tmp = subview as? StickerView {
                                if tmp.startTime <= time && tmp.endTime > time {
                                    subview.isHidden = false
                                } else {
                                    subview.isHidden = true
                                }
                            }
//                            if let tmp = subview as? CustomTextView {
//                                if Int64(tmp.startTime) <= Int64(time) && Int64(tmp.endTime) >= Int64(time) {
//                                    subview.isHidden = false
//                                }else {
//                                    subview.isHidden = true
//                                }
//                            }
                        }
                    }
            }
    }
    
    
    
    func videoPauseAction(){
        panGes?.isEnabled = false
        player?.pause()
        playPuaseButton.setTitle("Play", for: .normal)
    }
    
    func videoPlayAction(){
        panGes?.isEnabled = true
        player?.play()
        playPuaseButton.setTitle("Pause", for: .normal)
    }
    
    
    func addgesture(_ vw : UIView){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        vw.addGestureRecognizer(tapGesture)
        
        panGes = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGes?.delegate = self
        if panGes != nil {
            vw.addGestureRecognizer(panGes!)
        }
        
    }

    @objc func handlePan(_ recognizer : UIPanGestureRecognizer){
//        if playPuaseButton.titleLabel?.text == "Pause" {
            videoPauseAction()
//        }
    }

    @objc
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        videoPauseAction()
    }
    
    @objc
    func customview2Tapped(_ recognizer: UITapGestureRecognizer) {
        guard let vv = recognizer.view else {return}
        gotTouchEvent(mv: vv)
    }
    
    @objc
    func handleCustomLongpress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            tmppanGes?.isEnabled = true
            contentScrollView.panGestureRecognizer.isEnabled = false
        } else if recognizer.state == .ended {
            contentScrollView.panGestureRecognizer.isEnabled = true
            tmppanGes?.isEnabled = false
        }
    }
    
    @objc
    func handleCustomPan(_ recognizer: UIPanGestureRecognizer) {
        print("hello world")
    }
    
    
    func testt(){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.0){ [self] in
            
            let tmp = CustomView2(frame: CGRect(x: 0, y: 0, width: 50, height: 35))
            let tmp1 = CustomView2(frame: CGRect(x: 100, y: 0, width: 100, height: 35))
            let tmp2 = CustomView2(frame: CGRect(x: 50, y: 0, width: 70, height: 35))
            let tmp3 = CustomView2(frame: CGRect(x: 120, y: 0, width: 200, height: 35))
            let tmp4 = CustomView2(frame: CGRect(x: 120, y: 0, width: 200, height: 35))
            let tmp5 = CustomView2(frame: CGRect(x: 120, y: 0, width: 200, height: 35))
            let tmp6 = CustomView2(frame: CGRect(x: 120, y: 0, width: 200, height: 35))
            
            tmp.delegate = self
            tmp1.delegate = self
            tmp2.delegate = self
            tmp3.delegate = self
            tmp4.delegate = self
            tmp5.delegate = self
            tmp6.delegate = self
            
            tmp.clipsToBounds = true
            tmp1.clipsToBounds = true
            tmp2.clipsToBounds = true
            tmp3.clipsToBounds = true
            tmp4.clipsToBounds = true
            tmp5.clipsToBounds = true
            tmp6.clipsToBounds = true
            
            test.addSubview(tmp)
            test1.addSubview(tmp1)
            test2.addSubview(tmp2)
            test3.addSubview(tmp3)
            test4.addSubview(tmp4)
            test5.addSubview(tmp5)
            test6.addSubview(tmp6)
            
            let tm = BoundLayer(frame: test.bounds)
            let tm1 = BoundLayer(frame: test1.bounds)
            let tm2 = BoundLayer(frame: test2.bounds)
            let tm3 = BoundLayer(frame: test3.bounds)
            let tm4 = BoundLayer(frame: test3.bounds)
            let tm5 = BoundLayer(frame: test3.bounds)
            let tm6 = BoundLayer(frame: test3.bounds)
            
//            tm.delegate = self
//            tm1.delegate = self
//            tm2.delegate = self
//            tm3.delegate = self
//            tm4.delegate = self
//            tm5.delegate = self
//            tm6.delegate = self
            
            tm.initialOffset = initialContentOffset
            tm1.initialOffset = initialContentOffset
            tm2.initialOffset = initialContentOffset
            tm3.initialOffset = initialContentOffset
            tm4.initialOffset = initialContentOffset
            tm5.initialOffset = initialContentOffset
            tm6.initialOffset = initialContentOffset
            
            tm.clipsToBounds = true
            tm1.clipsToBounds = true
            tm2.clipsToBounds = true
            tm3.clipsToBounds = true
            tm4.clipsToBounds = true
            tm5.clipsToBounds = true
            tm6.clipsToBounds = true
            
            test.addSubview(tm)
            test1.addSubview(tm1)
            test2.addSubview(tm2)
            test3.addSubview(tm3)
            test4.addSubview(tm4)
            test5.addSubview(tm5)
            test6.addSubview(tm6)
            
           
            
//            let tmpTapGes = UITapGestureRecognizer(target: self, action: #selector(customview2Tapped))
//            tmpTapGes.delegate = self
//            tmp.addGestureRecognizer(tmpTapGes)
//            
//            let tmplongGes = UILongPressGestureRecognizer(target: self, action: #selector(handleCustomLongpress))
//            tmplongGes.delegate = self
//            tmp.addGestureRecognizer(tmplongGes)
//            
//            tmppanGes = UIPanGestureRecognizer(target: self, action: #selector(handleCustomPan))
//            tmppanGes!.delegate = self
//            tmppanGes?.isEnabled = false
//            tmp.addGestureRecognizer(tmppanGes!)
            
           
            
            tm.minimumValue = 0
            tm.maximumValue = thumbtimeSeconds + 1
            tm1.minimumValue = 0
            tm1.maximumValue = thumbtimeSeconds + 1
            tm2.minimumValue = 0
            tm2.maximumValue = thumbtimeSeconds + 1
            tm3.minimumValue = 0
            tm3.maximumValue = thumbtimeSeconds + 1
            tm4.minimumValue = 0
            tm4.maximumValue = thumbtimeSeconds + 1
            tm5.minimumValue = 0
            tm5.maximumValue = thumbtimeSeconds + 1
            tm6.minimumValue = 0
            tm6.maximumValue = thumbtimeSeconds + 1
            
            tm.lowerValue = thumbtimeSeconds / 20
            tm.upperValue = thumbtimeSeconds / 20 + 3
            
            let width : Double = (3 * 30) - 30
            tmp.frame = CGRect(x: Int(thumbtimeSeconds / 20 * 30) + 30, y: 0, width: Int(width) , height: 35)
            tmp.superview?.layoutIfNeeded()
            
            tm1.lowerValue = thumbtimeSeconds / 10
            tm1.upperValue = thumbtimeSeconds / 10 + 3
            
            let width1 : Double =  (3 * 30) - 30
            tmp1.frame = CGRect(x: Int(thumbtimeSeconds / 10 * 30) + 30, y: 0, width: Int(width1) , height: 35)
            tmp1.superview?.layoutIfNeeded()

            
            tm2.lowerValue = thumbtimeSeconds / 8
            tm2.upperValue = thumbtimeSeconds / 8 + 3
            
            let width2 : Double =  (3 * 30) - 30
            tmp2.frame = CGRect(x: Int(thumbtimeSeconds / 8 * 30) + 30, y: 0, width: Int(width2) , height: 35)
            tmp2.superview?.layoutIfNeeded()
            
            tm3.lowerValue = thumbtimeSeconds / 5
            tm3.upperValue = thumbtimeSeconds / 5 + 3
            
            let width3 : Double = (3 * 30) - 30
            tmp3.frame = CGRect(x: Int(thumbtimeSeconds / 5 * 30) + 30, y: 0, width: Int(width3) , height: 35)
            tmp3.superview?.layoutIfNeeded()
            
            tm4.lowerValue = thumbtimeSeconds / 5
            tm4.upperValue = thumbtimeSeconds / 5 + 3
            
            let width4 : Double = (3 * 30) - 30
            tmp4.frame = CGRect(x: Int(thumbtimeSeconds / 5 * 30) + 30, y: 0, width: Int(width4) , height: 35)
            tmp4.superview?.layoutIfNeeded()
            
            tm5.lowerValue = thumbtimeSeconds / 5
            tm5.upperValue = thumbtimeSeconds / 5 + 3
            
            let width5 : Double = (3 * 30) - 30
            tmp5.frame = CGRect(x: Int(thumbtimeSeconds / 5 * 30) + 30, y: 0, width: Int(width5) , height: 35)
            tmp5.superview?.layoutIfNeeded()
            
            tm6.lowerValue = thumbtimeSeconds / 5
            tm6.upperValue = thumbtimeSeconds / 5 + 3
            
            let width6 : Double = (3 * 30) - 30
            tmp6.frame = CGRect(x: Int(thumbtimeSeconds / 5 * 30) + 30, y: 0, width: Int(width6) , height: 35)
            tmp6.superview?.layoutIfNeeded()
            
            //Range slider action
            tm.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
            tm1.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
            tm2.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
            tm3.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
            tm4.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
            tm5.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
            tm6.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
            
            tm.isHidden = true
            tm1.isHidden = true
            tm2.isHidden = true
            tm3.isHidden = true
            tm4.isHidden = true
            tm5.isHidden = true
            tm6.isHidden = true
        }
    }
    
   
    
//    private func generateVideoPreviewImage(
//        for video: AVAsset
//    ) {
//        var sourceTime = [NSValue]()
//        let imageGenerator = AVAssetImageGenerator(asset: video)
//        self.imageGenerator = imageGenerator
//
////        imageGenerator.maximumSize = size.applying(.init(scaleX: 1.5, y: 1.5))
//        // Add tolerance.
//        imageGenerator.appliesPreferredTrackTransform = true
//        imageGenerator.requestedTimeToleranceAfter = .positiveInfinity
//        imageGenerator.requestedTimeToleranceBefore = .positiveInfinity
//
////        let step = Float(video.duration.seconds) / 16
//        let totatDuration = Float(video.duration.seconds)
//        for index in stride(from: 0, to: totatDuration , by: 1){
//            let cmTime = CMTime(seconds: Double(Float(index)), preferredTimescale: 600)
//            sourceTime.append(NSValue(time: cmTime))
//        }
//
//
//        imageGenerator.generateCGImagesAsynchronously(forTimes: sourceTime) {
//            [weak self] _, image, _, _, _ in
//
//            DispatchQueue.main.async {
//                let image = image.flatMap(UIImage.init)
//                guard let image = image else { return }
//                self!.saveImageToDocumentDirectory(image.generateThumbImage())
////                self!.thumbImgArray.append(image.generateThumbImage())
//            }
//        }
//    }
    
//    func saveImageToFileDirectory(_ image : UIImage?, forFirstTime : Bool = true){
//        let imgName = UUID().uuidString
//        let document = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        let imageUrl = document.appendingPathComponent(imgName, isDirectory: true)
//
//        if !FileManager.default.fileExists(atPath: imageUrl.path){
//            do {
//                try image?.pngData()?.write(to: imageUrl)
//            }catch {
//                print("image not added to file directory")
//            }
//        }
//    }
    
    var thumImageNames : [String] = []
    
    func saveImageToDocumentDirectory(_ image : UIImage?){
        let imgName = UUID().uuidString
        do {
            let document = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create:  true)
            let imageUrl = document.appendingPathComponent(imgName, isDirectory: true)
            if !FileManager.default.fileExists(atPath: imageUrl.path){
                do {
                    try image?.pngData()?.write(to: imageUrl)
                    thumImageNames.append(imgName)
                    self.thumbCollectionView.reloadData()
                }
                catch{
                    print("iamge not added to doc")
                }
            }
        }catch {
            print("iamge not added to doc")
        }
    }
    
    func retriveImageFromDocumentDirectory(_ ImageName : String) -> URL{
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageURL = documentsURL.appendingPathComponent(ImageName)

        return imageURL
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        if playPuaseButton.titleLabel?.text == "Play"{
           videoPlayAction()
        }else {
          videoPauseAction()
        }
    }
    
    @IBAction func takeStickerAction(_ sender: Any) {
        if player.currentTime().seconds+2 > actualVideoDuration {return}
        let test7 = CustomView(frame: .zero)
        test7.translatesAutoresizingMaskIntoConstraints = false
        contentPuttingStack.addArrangedSubview(test7)
        test7.heightAnchor.constraint(equalToConstant: stickerContentHight).isActive = true
        let tmp7 = CustomView2(frame: CGRect(x: 120, y: 0, width: 200, height: stickerContentHight))
        tmp7.delegate = self
        tmp7.clipsToBounds = true
        tmp7.tag = stickerTag
        tmp7.headerTitle.text = "Hello world"
//        tmp7.stickerImageView.image = UIImage(named: "101")
//        print((thumbtimeSeconds + 1) * 30, (thumbtimeSeconds + 2) * 30)
        test7.addSubview(tmp7)
        let tm7 = BoundLayer(frame: CGRect(x: 0, y: 0, width: (thumbtimeSeconds + 2) * 30 - 14 , height: 35))
        tm7.initialOffset = initialContentOffset
        tm7.clipsToBounds = true
        test7.addSubview(tm7)

        tm7.minimumValue = 0
        tm7.maximumValue = thumbtimeSeconds + (14 / 30)
        
        tm7.lowerValue = player.currentTime().seconds
        tm7.upperValue = player.currentTime().seconds + 3
        
        stickerAddingInUI()
        
        let width : Double = (3 * 30) - thumbWidth
        tmp7.frame = CGRect(x: Int(player.currentTime().seconds * 30) + 30, y: 0, width: Int(width) , height: 35)
        tmp7.superview?.layoutIfNeeded()
        
        tm7.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
        tm7.isHidden = true
    }
    
    func stickerAddingInUI(){
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
        stickerView3.tag = stickerTag
        stickerView3.startTime = player.currentTime().seconds
        stickerView3.endTime = player.currentTime().seconds + 2
//        stickerView3.isHidden = true
        self.stickerContainerView.addSubview(stickerView3)
        self.selectedStickerView = stickerView3
        registerStickerForUndoRedo(0, 0, stkview: stickerView3, startTime: player.currentTime().seconds, endTime: player.currentTime().seconds + 2)
        
        stickerTag += 1
    }
    
    func registerStickerForUndoRedo(_ category : Int, _ content : Int, stkview : StickerView, startTime : Float64, endTime : Float64){
        let newStickerObject = StickerValueModel(selectedStickerCategroy: category, selectedStickerContent: content, stickerFrame: CGRect(origin: CGPoint(x: stkview.frame.origin.x + 12, y: stkview.frame.origin.y + 12) , size: stkview.contentView.bounds.size) , stickerOrigin: stkview.center, stickerRadian: 0, stickerAlpha: 1, isFlipped: false, stickerTag: stkview.tag, startTime: startTime, endTime: endTime )
        
        allStickers.append(newStickerObject)
    }
    
}

extension TimelineViewController :  UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(thumbtimeSeconds + 2)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = thumbCollectionView.dequeueReusableCell(withReuseIdentifier: "ThumbCollectionViewCell", for: indexPath) as? ThumbCollectionViewCell {
            if indexPath.row == 0 || indexPath.row == Int(thumbtimeSeconds + 1) {
                cell.thumbImageView.image = UIImage(named: "101")
                return cell
            }
//            let cmTime = CMTime(seconds: Double(Float(indexPath.row-1)), preferredTimescale: 600)
            let cgImage = try! imgGenerator!.copyCGImage(at: CMTimeMake(value: Int64(indexPath.row-1), timescale: 1), actualTime: nil)
            cell.thumbImageView.image = UIImage(cgImage: cgImage).generateThumbImage()
            return cell
            
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func giveMeCurrentImage(index : Int, onComplete : @escaping(UIImage?) -> Void){
        
    }
}

extension TimelineViewController : UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = contentTableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell", for: indexPath) as? ContentTableViewCell {
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
}

extension TimelineViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
        if scrollView == thumbCollectionView {
//            if abs(scrollView.contentOffset.x - lastContentOffset.x) > abs(scrollView.contentOffset.y - lastContentOffset.y) {
                contentScrollView.contentOffset.x = scrollView.contentOffset.x
//            }else {
//                scrollView.contentOffset.x = lastContentOffset.x
//            }
        }
        else if scrollView == contentScrollView {
            thumbCollectionView.contentOffset.x = scrollView.contentOffset.x
//            contentScrollView.contentOffset.y = lastContentOffset.y
        }
//        lastContentOffset = contentScrollView.contentOffset
        callupdateLabel()
    }
    
    func callupdateLabel(){
        let updatedOffset = thumbCollectionView.contentOffset.x - initialContentOffset
        let seekingTime = updatedOffset / 30
        var seconds : CGFloat = updatedOffset / 30
        let minute : Int = Int(seconds / 60)
        seconds = seconds.truncatingRemainder(dividingBy: 60)
        let upSeconds = Int(seconds)
        var miniSec = Int(seconds.truncatingRemainder(dividingBy: 1) * 100)
        if updatedOffset / 30 > actualVideoDuration {
            miniSec = reminidingMilisec
        }
        
        minuteLabel.text = String(minute)+String(":")
        secondsLabel.text = String(upSeconds)+String(":")
        miliSecLabel.text = String(miniSec)
        
        if playPuaseButton.titleLabel?.text == "Play"{
            player?.seek(to: CMTime(seconds: seekingTime, preferredTimescale: 600))
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

extension TimelineViewController: CustomView2Protocols {
    func gotTouchEvent(mv: UIView) {
        selectedTimeline?.isHidden = true
        let supView = mv.superview
        supView?.subviews[1].isHidden = false
        selectedTimeline = supView?.subviews[1] as? BoundLayer
    }
}

extension TimelineViewController : StickerViewDelegate {
    func stickerViewDidBeginMoving(_ stickerView: StickerView) {
        
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
        for indx in stride(from: 0, to: allStickers.count, by: 1){
            if allStickers[indx].stickerTag == stickerView.tag {
                allStickers.remove(at: indx)
                break
            }
        }
        for subview in contentPuttingStack.arrangedSubviews {
            if subview.subviews[0].tag == stickerView.tag {
                subview.removeFromSuperview()
              //  contentPuttingStack.removeArrangedSubview(subview)
                break
            }
        }
        
        print(contentPuttingStack.subviews.count, "subview")
    }
    
    func stickerViewDidTap(_ stickerView: StickerView) {
        selectedStickerView = stickerView
    }
    
    
}

//extension TimelineViewController : BoundDelegate {
//    func updatedUpperValueTouchLocation(_ up: Bool) {
//        UIView.animate(withDuration: 0.1) {
//            self.contentScrollView.contentOffset.x = self.contentScrollView.contentOffset.x + 10
//        }
//    }
//    
//    func didendTracking(){
//        
//    }
//}

extension UIScrollView {
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
        print("touchesBegan")
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UIImage {
    func generateThumbImage() -> UIImage{
        let size: CGSize
        let ratio = (self.size.width / self.size.height)
        let fixLength: CGFloat = 100
        if ratio >= 1 {
            size = CGSize(width: fixLength * ratio, height: fixLength)
        } else {
            size = CGSize(width: fixLength, height: fixLength / ratio)
        }
        return self.resize(size) ?? self
    }
    
    func resize(_ size: CGSize) -> UIImage? {
        if size.width <= 0 || size.height <= 0 {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return temp
    }
}








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
   
    var selectedTimeline : BoundLayer?
    var lastContentOffset : CGPoint = .zero
    
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
        
        contentScrollView.contentInset = UIEdgeInsets(top: 0, left: view.bounds.width/2 - 30, bottom: 0, right: view.bounds.width/2)
        thumbCollectionView.contentInset = UIEdgeInsets(top: 0, left: view.bounds.width/2 - 30, bottom: 0, right: view.bounds.width/2)
        prepareVideo()
        test.translatesAutoresizingMaskIntoConstraints = false
        test1.translatesAutoresizingMaskIntoConstraints = false
        test2.translatesAutoresizingMaskIntoConstraints = false
        test3.translatesAutoresizingMaskIntoConstraints = false
        test4.translatesAutoresizingMaskIntoConstraints = false
        test5.translatesAutoresizingMaskIntoConstraints = false
        test6.translatesAutoresizingMaskIntoConstraints = false
        
        contentPuttingStack.addArrangedSubview(test)
        contentPuttingStack.addArrangedSubview(test1)
        contentPuttingStack.addArrangedSubview(test2)
        contentPuttingStack.addArrangedSubview(test3)
        contentPuttingStack.addArrangedSubview(test4)
        contentPuttingStack.addArrangedSubview(test5)
        contentPuttingStack.addArrangedSubview(test6)
        
        test.heightAnchor.constraint(equalToConstant: 35).isActive = true
        test1.heightAnchor.constraint(equalToConstant: 35).isActive = true
        test2.heightAnchor.constraint(equalToConstant: 35).isActive = true
        test3.heightAnchor.constraint(equalToConstant: 35).isActive = true
        test4.heightAnchor.constraint(equalToConstant: 35).isActive = true
        test5.heightAnchor.constraint(equalToConstant: 35).isActive = true
        test6.heightAnchor.constraint(equalToConstant: 35).isActive = true
       
        
        contentScrollView.delegate = self
    }
    
    @objc func rangeSliderValueChanged(_ rangeSlider: BoundLayer) {
        if rangeSlider.superview is CustomView {
            let st = rangeSlider.superview?.subviews[0]
            if st is CustomView2 {
               
                let width : Double = (rangeSlider.upperValue * 30) - (rangeSlider.lowerValue * 30) - 30
                st!.frame = CGRect(x: Int(ceil(rangeSlider.lowerValue * 30))+30, y: 0, width: Int(ceil(width)) , height: 35)
                st?.superview?.layoutIfNeeded()
            }
        }
    }
    
    var thumbtimeSeconds : Double = .zero
    func prepareVideo(){
        PHCachingImageManager().requestAVAsset(forVideo: phAsset!, options: nil) { (avAsset, _, _) in
            
            guard let avAsset = avAsset else {
                return
            }
            
            self.myAsset = avAsset
            self.generateVideoPreviewImage(for: avAsset)
            let thumbTime: CMTime = avAsset.duration
            let tmp : Double = Double(CMTimeGetSeconds(thumbTime))
            self.thumbtimeSeconds = ceil(tmp)
            
            DispatchQueue.main.async {
                self.widthofContents.constant = CGFloat(ceil(tmp + 2) * 30)
//                print(CGFloat(ceil(tmp + 2) * 30))
//                self.contentScrollView.contentSize = CGSize(width: CGFloat(ceil(tmp + 2) * 30), height: self.contentScrollView.bounds.height)
                self.testt()
            }
        }
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
    
    private func generateVideoPreviewImage(
        for video: AVAsset
    ) {
        var sourceTime = [NSValue]()
        let imageGenerator = AVAssetImageGenerator(asset: video)
        self.imageGenerator = imageGenerator
        
//        imageGenerator.maximumSize = size.applying(.init(scaleX: 1.5, y: 1.5))
        // Add tolerance.
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceAfter = .positiveInfinity
        imageGenerator.requestedTimeToleranceBefore = .positiveInfinity
                
//        let step = Float(video.duration.seconds) / 16
        let totatDuration = Float(video.duration.seconds)
        for index in stride(from: 0, to: totatDuration , by: 1){
            let cmTime = CMTime(seconds: Double(Float(index)), preferredTimescale: 600)
            sourceTime.append(NSValue(time: cmTime))
            
        }
        
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: sourceTime) {
            [weak self] _, image, _, _, _ in
            
            DispatchQueue.main.async {
                let image = image.flatMap(UIImage.init)
                guard let image = image else { return }
                self!.thumbImgArray.append(image)
                self!.thumbCollectionView.reloadData()
            }
        }
    }
    
}

extension TimelineViewController :  UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
       return thumbImgArray.count + 2
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = thumbCollectionView.dequeueReusableCell(withReuseIdentifier: "ThumbCollectionViewCell", for: indexPath) as? ThumbCollectionViewCell {
            if indexPath.row == 0 || indexPath.row == thumbImgArray.count + 1 {
                cell.thumbImageView.image = UIImage(named: "101")
                return cell
            }
            cell.thumbImageView.image = thumbImgArray[indexPath.row - 1]
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
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//
//        return UIEdgeInsets(top: 0, left: view.bounds.width/2, bottom: 0, right: view.bounds.width/2)
//    }
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
        print(scrollView.contentOffset.x, scrollView.contentOffset.y, "both")
        if scrollView == thumbCollectionView {
            if abs(scrollView.contentOffset.x - lastContentOffset.x) > abs(scrollView.contentOffset.y - lastContentOffset.y) {
                contentScrollView.contentOffset.x = scrollView.contentOffset.x
            }else {
                scrollView.contentOffset.x = lastContentOffset.x
            }
            
//            contentScrollView.contentOffset.y = lastContentOffset.y
            
            
        }
        else if scrollView == contentScrollView {
            thumbCollectionView.contentOffset.x = scrollView.contentOffset.x
            contentScrollView.contentOffset.y = lastContentOffset.y
        }
        lastContentOffset = contentScrollView.contentOffset
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






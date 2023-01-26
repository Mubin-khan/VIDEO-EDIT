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

class TimelineViewController: UIViewController{
   
    
    let test = CustomView(frame: CGRect(x: 0, y: 0, width: 400, height: 35))
    let test1 = CustomView(frame: CGRect(x: 0, y: 0, width: 400, height: 35))
    let test2 = CustomView(frame: CGRect(x: 0, y: 0, width: 400, height: 35))
    let test3 = CustomView(frame: CGRect(x: 0, y: 0, width: 400, height: 35))
    
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
        
        contentScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        prepareVideo()
        
        contentPuttingStack.addSubview(test)
        contentPuttingStack.addSubview(test1)
        contentPuttingStack.addSubview(test2)
        contentPuttingStack.addSubview(test3)
        
        contentScrollView.delegate = self
    }
    
    func prepareVideo(){
        PHCachingImageManager().requestAVAsset(forVideo: phAsset!, options: nil) { (avAsset, _, _) in
            
            guard let avAsset = avAsset else {
                return
            }
            
            self.myAsset = avAsset
            self.generateVideoPreviewImage(for: avAsset)
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
        for index in stride(from: 0, to: totatDuration , by: 1.5){
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
        widthofContents.constant = CGFloat(thumbImgArray.count * 30)
       return thumbImgArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = thumbCollectionView.dequeueReusableCell(withReuseIdentifier: "ThumbCollectionViewCell", for: indexPath) as? ThumbCollectionViewCell {
            cell.thumbImageView.image = thumbImgArray[indexPath.row]
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 0)
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
            contentScrollView.contentOffset = scrollView.contentOffset
        }
        if scrollView == contentScrollView {
            thumbCollectionView.contentOffset = scrollView.contentOffset
        }
    }
}






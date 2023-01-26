//
//  ViewController.swift
//  VIDEO
//
//  Created by appsyneefo on 9/5/22.
//

import UIKit
import UniformTypeIdentifiers
import TLPhotoPicker
import Photos
import AVFoundation


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TLPhotosPickerViewControllerDelegate {
    
    var selectedAssets = [TLPHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    let viewController = CustomPhotoPickerViewController()
    @IBAction func pickVideoAction(_ sender: Any) {
//        getAccessToVideoLibrary()
        
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showExceededMaximumAlert(vc: picker)
        }
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.maxSelectedAssets = 1
        configure.singleSelectedMode = true
        configure.allowedPhotograph = false
        configure.allowedLivePhotos = false
        configure.mediaType = .video
        viewController.configure = configure
//        viewController.selectedAssets = self.selectedAssets
        self.present(viewController.wrapNavigationControllerWithoutBar(), animated: true, completion: nil)
    }
    
    func showExceededMaximumAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "", message: "Exceed Maximum Number Of Selection", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    func getAccessToVideoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            let picker = UIImagePickerController()
//
//            guard UIImagePickerController.canRecordVideos else { return nil }
//
//            let camera = UIImagePickerController.isCameraDeviceAvailable(preferredCamera)
//                ? preferredCamera
//                : .rear
            
            let picker = UIImagePickerController()
            
////            picker.delegate = delegate
//            picker.mediaTypes = [UTType.movie.identifier]
//            picker.sourceType = .camera
//            picker.cameraCaptureMode = .video
////            picker.cameraDevice = camera
//            picker.videoQuality = .typeHigh
            
//            picker.modalPresentationStyle = .fullScreen
            
            
            picker.delegate = self
            picker.sourceType = .savedPhotosAlbum
            picker.mediaTypes = ["public.movie"]
            picker.allowsEditing = false
            picker.videoQuality = .typeHigh
            present(picker, animated: true, completion: nil)
        }
    }
    
   func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       self.dismiss(animated: true, completion: nil)
   }

   var videoURL: NSURL?
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      
       let vc = VideoViewController()
       
       if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
           vc.url = videoURL
//           let pathString = videoURL.relativePath
           self.navigationController?.pushViewController(vc, animated: true)
       }
     
       self.dismiss(animated: true, completion: nil)
      
   }
    
    func shouldDismissPhotoPicker(withTLPHAssets: [TLPHAsset]) -> Bool {
           // use selected order, fullresolution image
       
        
        self.selectedAssets = withTLPHAssets
//        print(selectedAssets.first?.type)
        return true
    }
    
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        // if you want to used phasset.
//        print("came ===============")
    }

    func photoPickerDidCancel() {
//        print("hellllo =========")
        // cancel
    }

    func dismissComplete() {
        // picker dismiss completion
//        print("came 2 ===============")
        let vc = TimelineViewController()
        if selectedAssets.first?.phAsset != nil {
            vc.phAsset = selectedAssets.first?.phAsset
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        self.showExceededMaximumAlert(vc: picker)
    }
    
    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        picker.dismiss(animated: true) {
            let alert = UIAlertController(title: "", message: "Denied albums permissions granted", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        let alert = UIAlertController(title: "", message: "Denied camera permissions granted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        picker.present(alert, animated: true, completion: nil)
    }

   
    func showUnsatisifiedSizeAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "Oups!", message: "The required size is: 300 x 300", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: TLPhotosPickerLogDelegate {
    //For Log User Interaction
    func selectedCameraCell(picker: TLPhotosPickerViewController) {
        print("selectedCameraCell")
    }
    
    func selectedPhoto(picker: TLPhotosPickerViewController, at: Int) {
        print("selectedPhoto")
    }
    
    func deselectedPhoto(picker: TLPhotosPickerViewController, at: Int) {
        print("deselectedPhoto")
    }
    
    func selectedAlbum(picker: TLPhotosPickerViewController, title: String, at: Int) {
        print("selectedAlbum")
    }
}



extension CIImage {
    
    func toUIImage() -> UIImage? {
        let context = CIContext()
        guard let cgImage = context.createCGImage(self, from: self.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
}

extension UIImage {
    
    func toCIImage() -> CIImage? {
        var ci = self.ciImage
        if ci == nil, let cg = self.cgImage {
            ci = CIImage(cgImage: cg)
        }
        return ci
    }
    
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension CGImage {
    func convertCGImageToCIImage() -> CIImage! {
        var ciImage = CIImage(cgImage: self)
        return ciImage
    }
}

extension UIImage {
    class func imageWithLayer(layer: CALayer) -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.isOpaque, 0.0)
////        layer.render(in: UIGraphicsGetCurrentContext()!)
//        if let ctx = UIGraphicsGetCurrentContext() {
//            layer.render(in: ctx)
//        }
//        let img = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return img
        
            UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.isOpaque, UIScreen.main.scale)

            defer { UIGraphicsEndImageContext() }

            // Don't proceed unless we have context
            guard let context = UIGraphicsGetCurrentContext() else {
              return nil
            }

            layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
         
    }
}

struct StickerValueModel {
    var selectedStickerCategroy : Int
    var selectedStickerContent : Int
    var stickerFrame : CGRect
    var stickerOrigin : CGPoint
    var stickerRadian : CGFloat
    var stickerAlpha : CGFloat
    var isFlipped : Bool
    var stickerTag : Int
    var startTime : Float64
    var endTime : Float64
    
    init(selectedStickerCategroy: Int, selectedStickerContent: Int, stickerFrame: CGRect, stickerOrigin: CGPoint, stickerRadian: CGFloat, stickerAlpha: CGFloat, isFlipped: Bool, stickerTag: Int, startTime: Float64, endTime: Float64) {
        self.selectedStickerCategroy = selectedStickerCategroy
        self.selectedStickerContent = selectedStickerContent
        self.stickerFrame = stickerFrame
        self.stickerOrigin = stickerOrigin
        self.stickerRadian = stickerRadian
        self.stickerAlpha = stickerAlpha
        self.isFlipped = isFlipped
        self.stickerTag = stickerTag
        self.startTime = startTime
        self.endTime = endTime
    }
    
    func isEquals(compareTo : StickerValueModel) -> Bool {
        return self.selectedStickerCategroy == compareTo.selectedStickerCategroy &&
        self.selectedStickerContent ==  compareTo.selectedStickerContent &&
        self.stickerFrame ==  compareTo.stickerFrame &&
        self.stickerRadian ==  compareTo.stickerRadian &&
        self.stickerAlpha ==  compareTo.stickerAlpha &&
        self.isFlipped ==  compareTo.isFlipped &&
        self.stickerTag ==  compareTo.stickerTag &&
        self.stickerOrigin == compareTo.stickerOrigin
    }
}

extension UIView {
    var rotation: Float {
        let radians:Float = atan2f(Float(self.transform.b), Float(self.transform.a))
        return radians
    }
}

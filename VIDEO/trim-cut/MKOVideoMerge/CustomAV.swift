////
////  CustomAV.swift
////  VIDEO
////
////  Created by appsyneefo on 9/25/22.
////
//
import UIKit
import VideoToolbox

class CustomOverlayInstruction: NSObject ,  AVVideoCompositionInstructionProtocol{
    var timeRange: CMTimeRange
    
//the 5 variables below are required to implement the class
//    var timeRange: CMTimeRange?
//describes the duration that the given intructions are used
    var enablePostProcessing: Bool = true
// this is if you are also working with Core Animation as well
    var containsTweening: Bool = false
// to learn more about this i reccomend just looking it up but for now
//you can make it false
    var requiredSourceTrackIDs: [NSValue]?
//if there are any specific id you are requiring for your asset tracks
    var passthroughTrackID: CMPersistentTrackID = kCMPersistentTrackID_Invalid
// if a trackId is in the passthroughTrackId then the for duration that it is available,
//the compositor wont be run
    var rotateSecondAsset: Bool?
    //info that we are passing onto the compositor
    
    var stickerImage : CGImage
    var currentFilter : GlobalClass.FilterStates
    var brightness : CGFloat
    var contrast : CGFloat
    var saturation : CGFloat
    var extWidth : CGFloat
    var extHeight : CGFloat
    
    init(timerange:CMTimeRange , rotateSecondAsset: Bool, stickerImage : CGImage, currentFilter : GlobalClass.FilterStates, br : CGFloat, con : CGFloat, sat : CGFloat, width : CGFloat, height : CGFloat){
        self.timeRange = timerange
        self.rotateSecondAsset = rotateSecondAsset
        self.stickerImage = stickerImage
        self.currentFilter = currentFilter
        self.brightness = br
        self.contrast = con
        self.saturation = sat
        self.extWidth = width
        self.extHeight = height
    }
}


class CustomCompositor: NSObject , AVVideoCompositing{
    
    let context = CIContext(options: nil)
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        
        return nil
    }
    
   
    private var renderContext : AVVideoCompositionRenderContext?
    //the renderContext provided to the compositor
    
    var sourcePixelBufferAttributes: [String : Any]?{
        get {
            return ["\(kCVPixelBufferPixelFormatTypeKey)": kCVPixelFormatType_32BGRA]
        }
    }
    //the list of possible pixel attributes
    //Use kCVPixelFormatType_32BGRA if you are planning on processing with Core Animation Layer
    //Omitted attributes will be supplied by the composition engine to allow for the best performance
    
    var requiredPixelBufferAttributesForRenderContext: [String : Any]{
        get {
            return ["\(kCVPixelBufferPixelFormatTypeKey)": kCVPixelFormatType_32BGRA]
        }
    }
    //The pixel buffer attributes required by the video compositor for new buffers created for processing.
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext){
         renderContext = newRenderContext
        /*this function is called if the render context
        of the compositor has changed to something new*/
    }
    
     func startRequest(_ request: AVAsynchronousVideoCompositionRequest) {
         /* This is where you will process your frames, for each sequence of frame you
         will recieve a render context that supplies a new empty frame , and instructions
         that are assigned to the render context as well*/
         
         
         guard let instruction = request.videoCompositionInstruction as? CustomOverlayInstruction else{
             request.finish(with: NSError(domain: "getblix.co", code: 760, userInfo: nil))
                             return
                         }
         
         let destinationFrame = request.renderContext.newPixelBuffer()
         

        //get the destination frame from renderContext
        if(request.sourceTrackIDs.count == 1){
    
        let firstFrame = request.sourceFrame(byTrackID: request.sourceTrackIDs[0].int32Value)
        let secondFrame = request.sourceFrame(byTrackID: request.sourceTrackIDs[0].int32Value)
            
      
            //if your tracks were assigned a uniqe id you can use that as well.

//            let instruction = request.videoCompositionInstruction
            //get the instructions assigned to the render request

           
            CVPixelBufferLockBaseAddress(firstFrame! , .readOnly)
                            CVPixelBufferLockBaseAddress(secondFrame!, .readOnly)
                            CVPixelBufferLockBaseAddress(destinationFrame!, CVPixelBufferLockFlags(rawValue: 0))
            //lock all addresses before processing
            let firstImg = createSourceImage(from: firstFrame)
            //turn the two pixel buffers into CGImage
            //I do this to make it easier to manipulate the frames
            let secondImg = createSourceImage(from: secondFrame)
            // you can also use the provided Correctorientation function below
            //to correct orientation of any frame
            let destWidth = CVPixelBufferGetWidth(destinationFrame!)
            let destHeight = CVPixelBufferGetHeight(destinationFrame!)
            
            
            // filter & blur
            var topImage = CIImage(cgImage: firstImg!)
            if instruction.currentFilter == .gpu {
               let outputUIImage = applyGPUImageLookupFilter(topImage.toUIImage(), UIImage(named: "lut1"))
                topImage = (outputUIImage?.toCIImage())!
            }else if instruction.currentFilter == .mono {
                let filterr = CIFilter(name: "CIColorMonochrome")!

                filterr.setValue(topImage, forKey: kCIInputImageKey)
                topImage = filterr.outputImage!
            } else if instruction.currentFilter == .sepia {
                let filterr = CIFilter(name: "CISepiaTone")!

                filterr.setValue(topImage, forKey: kCIInputImageKey)
                topImage = filterr.outputImage!
            }

            let filter = CIFilter(name: "CIColorControls")!

            filter.setValue(topImage, forKey: kCIInputImageKey)
            filter.setValue(instruction.brightness, forKey: kCIInputBrightnessKey)
            filter.setValue(instruction.contrast, forKey: kCIInputContrastKey)
            filter.setValue(instruction.saturation, forKey: kCIInputSaturationKey)
            
            let firstImage = convertCIImageToCGImage(inputImage: filter.outputImage!)
            
            let backUIImage = applyBlurfilter(filter.outputImage!.toUIImage())
            let backImag1 = backUIImage?.toCIImage()
            let backImage = convertCIImageToCGImage(inputImage: backImag1!)

//            if(rotate){
//                //you can rotate the image however you see fit or need to
//                //you can also attach additional instruction to help you
//                //determine the necessary changes
//            }

            //we will be using CALayers to make overlaying sumer simple
            let frame = CGRect(x: 0, y: 0, width: destWidth , height: destHeight)
            //this will be the background frame size
//            let innerFrame = CGRect(x: 0, y: 0,
//                                    width: 1280,
//                                    height: 720)
            //this will be the overlayFrameSize
            let backgroundLayer = CALayer()
            backgroundLayer.frame = frame
            backgroundLayer.contentsGravity = .resizeAspectFill
            backgroundLayer.contents = backImage
//create the backgroundLayer and fill it with firstImag
            let overLayLayer = CALayer()
            overLayLayer.frame = frame
            overLayLayer.contentsGravity = .resizeAspect
            overLayLayer.contents = firstImage
            
//            let sticketLayer = CALayer()
//            sticketLayer.frame = frame
//            sticketLayer.contentsGravity = .resizeAspectFill
//            sticketLayer.contents = instruction.stickerImage
            
//            add(image: instruction.stickerImage, to: sticketLayer, frame: sticketLayer.frame)
            
//create the overlay layer and fill it with secondImg
            let finalLayer = CALayer()
            finalLayer.frame = frame
            finalLayer.backgroundColor = UIColor.clear.cgColor
            finalLayer.addSublayer(backgroundLayer)
            finalLayer.addSublayer(overLayLayer)
//            finalLayer.addSublayer(sticketLayer)
            //add the two layers onto the final layer
            //make sure you add the backgroundLayer first
            //and then the overlay Layer
             let fullImg = imageWithLayer(layer: finalLayer)
            //create image using the CALayer
            //this image will be drawn into the CVPixelBuffer
            var gc : CGContext?
            if let destination = destinationFrame, let image = firstImg?.colorSpace {
                    gc = CGContext(data: CVPixelBufferGetBaseAddress(destination),
                 width: destWidth,
                 height: destHeight,
                 bitsPerComponent: 8,
                 bytesPerRow: CVPixelBufferGetBytesPerRow(destination),
                 space: image,
                 bitmapInfo: secondImg?.bitmapInfo.rawValue ?? 0)
            }

            gc?.draw(fullImg, in: frame)
            //draw in the image using CGContext
            CATransaction.flush()
            //make sure you flush the current CALayers , if you fail to
            //Swift will hold on to them and cause a memory leak
            CVPixelBufferUnlockBaseAddress(destinationFrame!, CVPixelBufferLockFlags(rawValue: 0))
            CVPixelBufferUnlockBaseAddress(firstFrame!, .readOnly)
            CVPixelBufferUnlockBaseAddress(secondFrame!, .readOnly)
            //unlock addresses after finishing
            request.finish(withComposedVideoFrame: destinationFrame!)
            //end function with request.finish
        
    }
    
    func imageWithLayer(layer: CALayer) -> CGImage {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.isOpaque, 1.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        return img!.cgImage!
    }
    
    func createSourceImage(from buffer: CVPixelBuffer?) -> CGImage? {
        var image : CGImage?
        VTCreateCGImageFromCVPixelBuffer(buffer!, options: nil, imageOut: &image)
        return image
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
         
         func applyBlurfilter(_ mainImage : UIImage?) -> UIImage?{
             guard let mainImage = mainImage else {
                 return nil
             }
             
             let mainPicture = GPUImagePicture(image: mainImage)
             let filter = GPUImageGaussianBlurFilter()
             filter.blurRadiusInPixels = 10
             
             mainPicture?.addTarget(filter)
             filter.useNextFrameForImageCapture()
             mainPicture?.processImage()
             
             let outputImge = filter.imageFromCurrentFramebuffer()
             return outputImge

         }

  

//    func correctImageOrientation(cgImage: CGImage?, orienation: UIImage.Orientation) -> CGImage? {
//        guard let cgImage = cgImage else { return nil }
//        var orientedImage: CGImage?
//
//        let originalWidth = cgImage.width
//        let originalHeight = cgImage.height
//        let bitsPerComponent = cgImage.bitsPerComponent
//        let bytesPerRow = cgImage.bytesPerRow
//        let bitmapInfo = cgImage.bitmapInfo
//
//        guard let colorSpace = cgImage.colorSpace else { return nil }
//
//        let degreesToRotate = orienation.getDegree()
//        let mirrored = orienation.isMirror()
//
//        var width = originalWidth
//        var height = originalHeight
//
//        let radians = degreesToRotate * Double.pi / 180.0
//        let swapWidthHeight = Int(degreesToRotate / 90) % 2 != 0
//
//        if swapWidthHeight {
//            swap(&width, &height)
//        }
//
//        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
//
//        context?.translateBy(x: CGFloat(width) / 2.0, y: CGFloat(height) / 2.0)
//        if mirrored {
//            context?.scaleBy(x: -1.0, y: 1.0)
//        }
//        context?.rotate(by: CGFloat(radians))
//        if swapWidthHeight {
//            swap(&width, &height)
//        }
//        context?.translateBy(x: -CGFloat(width) / 2.0, y: -CGFloat(height) / 2.0)
//
//        context?.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(originalWidth), height: CGFloat(originalHeight)))
//        orientedImage = context?.makeImage()
//
//        return orientedImage
//    }
}

    func add(image: CGImage, to layer: CALayer, frame: CGRect) {
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
        stickerLayer.contents = UIImage(named: "101")!.cgImage
        stickerLayer.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        
        let degrees = 30.0
        let radians = CGFloat(degrees * .pi / 180)
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

}

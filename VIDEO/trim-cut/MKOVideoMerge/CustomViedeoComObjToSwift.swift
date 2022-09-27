////
////  CustomViedeoComObjToSwift.swift
////  VIDEO
////
////  Created by appsyneefo on 9/26/22.
////
//
//import UIKit
//
//import UIKit
//
//class CustomVideoCompositorSwift {
//   
//    func startRequest(_ request: AVAsynchronousVideoCompositionRequest) {
//
//        let destination = request.renderContext.newPixelBuffer()
//        //    printf(@"MSg:%d ",request.sourceTrackIDs.count > );
//        if request.sourceTrackIDs.count > 0 {
//            let front = request.sourceFrame(byTrackID: CMPersistentTrackID(request.sourceTrackIDs[0].intValue))
//            let back = request.sourceFrame(byTrackID: CMPersistentTrackID(request.sourceTrackIDs[0].intValue))
//            
//            guard let front = front, let back = back , let destination = destination else { return }
//            
//            CVPixelBufferLockBaseAddress(front, .readOnly)
//            CVPixelBufferLockBaseAddress(back, .readOnly)
//            CVPixelBufferLockBaseAddress(destination, [])
//            renderFrontBuffer(front, back: back, to: destination)
//            CVPixelBufferUnlockBaseAddress(destination, [])
//            CVPixelBufferUnlockBaseAddress(back, .readOnly)
//            CVPixelBufferUnlockBaseAddress(front, .readOnly)
//        }
//        
//        request.finish(withComposedVideoFrame: destination!)
////        CVBufferRelease(destination)
//    }
//    
//    func renderFrontBuffer(_ front: CVPixelBuffer?, back: CVPixelBuffer?, to destination: CVPixelBuffer?) {
//        let frontImage = createSourceImage(from: front)
//        let backImage = createSourceImage(from: back)
//        var width: size_t? = nil
//        if let destination = destination{
//            width = CVPixelBufferGetWidth(destination)
//        }
//        var height: size_t? = nil
//        if let destination = destination {
//            height = CVPixelBufferGetHeight(destination)
//        }
//    }
//    
//   
//    func createSourceImage(from buffer: CVPixelBuffer?) -> CGImage? {
//        var width: size_t? = nil
//        if let buffer = buffer {
//            width = CVPixelBufferGetWidth(buffer)
//        }
//        var height: size_t? = nil
//        if let buffer = buffer {
//            height = CVPixelBufferGetHeight(buffer)
//        }
//        var stride: size_t? = nil
//        if let buffer = buffer{
//            stride = CVPixelBufferGetBytesPerRow(buffer)
//        }
//        var data: UnsafeMutablePointer? = nil
//        if let buffer = buffer{
//            data = CVPixelBufferGetBaseAddress(buffer)
//        }
//        
//        let rgb = CGColorSpaceCreateDeviceRGB()
//        let provider = CGDataProvider(dataInfo: nil, data: &data, size: height * stride, releaseData: nil)
//        var image: CGImage? = nil
//        if let last = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue), let provider {
//            image = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: stride, space: rgb, bitmapInfo: last, provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
//        }
//        CGDataProviderRelease(provider)
//
//        return image
//    }
//    
//}

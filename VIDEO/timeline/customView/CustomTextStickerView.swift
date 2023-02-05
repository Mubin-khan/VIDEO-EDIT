//
//  CustomTextView.swift
//  VIDEO
//
//  Created by appsyneefo on 1/26/23.
//

import UIKit

class RangeSliderThumbLayer1: CALayer {
    
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    weak var rangeSlider: BoundLayer?
    
    var strokeColor: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var lineWidth: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(in ctx: CGContext) {
        guard let slider = rangeSlider else {
            return
        }
        
        let thumbFrame = bounds.insetBy(dx: 0.0, dy: 0.0)
        let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
        let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
        
        // Fill
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.addPath(thumbPath.cgPath)
        ctx.fillPath()
        
        // Outline
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineWidth(lineWidth)
        ctx.addPath(thumbPath.cgPath)
        ctx.strokePath()
        
        if highlighted {
            ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()
        }
    }
}

class RangeSliderThumbLayer2: CALayer {
    
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    weak var rangeSlider: BoundLayer?
    
    var strokeColor: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
    var lineWidth: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(in ctx: CGContext) {
        guard let slider = rangeSlider else {
            return
        }
        
        let thumbFrame = bounds.insetBy(dx: 0.0, dy: 0.0)
        let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
        let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
        
        // Fill
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.addPath(thumbPath.cgPath)
        ctx.fillPath()
        
        // Outline
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineWidth(lineWidth)
        ctx.addPath(thumbPath.cgPath)
        ctx.strokePath()
        
        if highlighted {
            ctx.setFillColor(UIColor.black.withAlphaComponent(0.3).cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()
        }
    }
}

//protocol BoundDelegate {
//    func updatedUpperValueTouchLocation(_ up : Bool)
//    func didendTracking()
//}

class BoundLayer : UIControl {
//    var delegate : BoundDelegate?
    fileprivate var previouslocation = CGPoint()
    var initialOffset : CGFloat? = .zero
    
    @IBInspectable var curvaceousness: CGFloat = 0.0 {
        didSet {
            if curvaceousness < 0.0 {
                curvaceousness = 0.0
            }
            
            if curvaceousness > 1.0 {
                curvaceousness = 1.0
            }
            
//            trackLayer.setNeedsDisplay()
            sideScl.setNeedsDisplay()
            sideScr.setNeedsDisplay()
        }
    }
    
    @IBInspectable var minimumValue: Double = 0.0 {
        willSet(newValue) {
            assert(newValue < maximumValue, "RangeSlider: minimumValue should be lower than maximumValue")
        }
        didSet {
            updateLayerFrames()
        }
    }
    
    @IBInspectable var maximumValue: Double = 100 {
        willSet(newValue) {
            assert(newValue > minimumValue, "RangeSlider: maximumValue should be greater than minimumValue")
        }
        didSet {
            updateLayerFrames()
        }
    }
    
    @IBInspectable var lowerValue: Double = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    @IBInspectable var upperValue: Double = 100 {
        didSet {
            
            updateLayerFrames()
        }
    }
    
    @IBInspectable var thumbTintColor: UIColor = UIColor.white {
        didSet {
            sideScr.setNeedsDisplay()
            sideScl.setNeedsDisplay()
        }
    }
    
    @IBInspectable var midLayerColor: UIColor = UIColor.clear {
        didSet {
            midLayer.setNeedsDisplay()
        }
    }
    
    fileprivate var thumbWidth: CGFloat = 16
    
    fileprivate let sideScl = RangeSliderThumbLayer1()
    fileprivate let sideScr = RangeSliderThumbLayer1()
    fileprivate let midLayer = RangeSliderThumbLayer2()
    
//    lazy var sideScl : UIControl = {
//       let sidsc = UIControl(frame: CGRect(x: 0, y: 0, width: 5, height: 35))
//        sidsc.backgroundColor = .blue
//        sidsc.isUserInteractionEnabled = true
//        return sidsc
//    }()
//
//    lazy var sideScr : UIControl = {
//        let sidsc = UIControl(frame: CGRect(x: 0, y: 0, width: 5, height: 35))
//        sidsc.backgroundColor = .blue
//        sidsc.isUserInteractionEnabled = true
//        return sidsc
//    }()
    
    override func layoutSublayers(of: CALayer) {
        super.layoutSublayers(of:layer)
        updateLayerFrames()
    }

    func updateLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue))
        print(lowerThumbCenter, "center ")
        sideScl.frame = CGRect(x: lowerThumbCenter - thumbWidth/2.0 + 14, y: 0.0, width: thumbWidth, height: 35)
        sideScl.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(upperValue))
        sideScr.frame = CGRect(x: upperThumbCenter - thumbWidth/2.0 , y: 0.0, width: thumbWidth, height: 35)
        sideScr.setNeedsDisplay()
        
        midLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth/2.0 + 14 + thumbWidth , y: 0, width: upperThumbCenter - lowerThumbCenter - 30, height: 35)
        midLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
   
    func positionForValue(_ value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth/2.0)
    }
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  //initWithCode to init view from xib or storyboard
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  //common func to init our view
  private func setupView() {
      sideScl.rangeSlider = self
      sideScl.contentsScale = UIScreen.main.scale
      layer.addSublayer(sideScl)
      
      sideScr.rangeSlider = self
      sideScr.contentsScale = UIScreen.main.scale
      layer.addSublayer(sideScr)
      
      midLayer.rangeSlider = self
      midLayer.contentsScale = UIScreen.main.scale
      layer.addSublayer(midLayer)
  }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previouslocation = touch.location(in: self)
//        print(previouslocation, sideScl.frame, sideScr.frame, "thelldod")
        // Hit test the thumb layers
        if sideScl.frame.contains(previouslocation) {
            sideScl.highlighted = true
//            lowerLayerSelected = lowerThumbLayer.highlighted

        } else if sideScr.frame.contains(previouslocation) {
            sideScr.highlighted = true
//            lowerLayerSelected = lowerThumbLayer.highlighted

        }
        
        else if midLayer.frame.contains(previouslocation) {
            midLayer.highlighted = true
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
//        sideScl.highlighted = true
        return sideScl.highlighted || sideScr.highlighted || midLayer.highlighted
//        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
       
        // Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previouslocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)
        
        previouslocation = location
        
        // Update the values
        if sideScl.highlighted {
          let lv = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gapBetweenThumbs)
            
            if upperValue - lv >= 1.5 {
                lowerValue = lv
            }
         }
        else if sideScr.highlighted {
            let uv = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + gapBetweenThumbs, upperValue: maximumValue)
            
            if uv - lowerValue >= 1.5 {
                upperValue = uv
            }
        }
        
        else if midLayer.highlighted {
            let lv = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gapBetweenThumbs)
            let uv = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + gapBetweenThumbs, upperValue: maximumValue)
            if (upperValue - lowerValue).rounded(toPlaces: 2) == (uv - lv).rounded(toPlaces: 2) {
                lowerValue = lv
                upperValue = uv
            }
        }
        
//        let screenPoint1 = self.superview?.convert(CGPoint(x: upperValue*30, y: location.y), to: nil)
       
//        if let screenPoint1 = screenPoint1, screenPoint1.x > 300 {
//            delegate?.updatedUpperValueTouchLocation(true)
//        }
        sendActions(for: .valueChanged)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        sideScl.highlighted = false
        sideScr.highlighted = false
        midLayer.highlighted = false
        
//        delegate?.didendTracking()
    }
    
    func boundValue(_ value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    var gapBetweenThumbs: Double {
        return 0.0 * Double(thumbWidth) * (maximumValue - minimumValue) / Double(bounds.width)
    }
}

class CustomView: UIView {
  //initWithFrame to init view from code
    lazy var headerTitle: UILabel = {
        let headerTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        headerTitle.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        headerTitle.text = "Custom View"
        headerTitle.textAlignment = .center
        return headerTitle
      }()
    
    lazy var sideScl : UIControl = {
       let sidsc = UIControl(frame: CGRect(x: 0, y: 0, width: 5, height: 35))
        sidsc.backgroundColor = .blue
        sidsc.addGestureRecognizer(rotateGesture)
        sidsc.isUserInteractionEnabled = true
        return sidsc
    }()
    
    lazy var sideScr : UIControl = {
        let sidsc = UIControl(frame: CGRect(x: 0, y: 0, width: 5, height: 35))
        sidsc.backgroundColor = .blue
        sidsc.addGestureRecognizer(rotateGesture)
        sidsc.isUserInteractionEnabled = true
        return sidsc
    }()
    
    private lazy var rotateGesture = {
        return UIPanGestureRecognizer(target: self, action: #selector(handleRotateGesture(_:)))
    }()
    
    @objc func handleRotateGesture(_ recognizer: UIPanGestureRecognizer) {
        print("hello wordld")
    }
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  //initWithCode to init view from xib or storyboard
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  //common func to init our view
  private func setupView() {
     
    backgroundColor = .black
//    sideScl.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
//      sideScr.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
//    addSubview(sideScl)
//    addSubview(sideScr)
//    addSubview(headerTitle)
  }
}

//class CustomView2: UIControl {
//  //initWithFrame to init view from code
//    fileprivate var previouslocation = CGPoint()
//
//    @IBInspectable var minimumValue: Double = 0.0 {
//        willSet(newValue) {
//            assert(newValue < maximumValue, "RangeSlider: minimumValue should be lower than maximumValue")
//        }
//        didSet {
////            updateLayerFrames()
//        }
//    }
//
//    @IBInspectable var maximumValue: Double = 100 {
//        willSet(newValue) {
//            assert(newValue > minimumValue, "RangeSlider: maximumValue should be greater than minimumValue")
//        }
//        didSet {
////            updateLayerFrames()
//        }
//    }
//
//    @IBInspectable var lowerValue: Double = 0.0 {
//        didSet {
//            updateLayerFrames()
//        }
//    }
//
//    @IBInspectable var upperValue: Double = 100 {
//        didSet {
//
//            updateLayerFrames()
//        }
//    }
//
//    @IBInspectable var thumbTintColor: UIColor = UIColor.white {
//        didSet {
//            sideScr.setNeedsDisplay()
//            sideScl.setNeedsDisplay()
//        }
//    }
//
//    fileprivate var thumbWidth: CGFloat = 13
//
//    lazy var headerTitle: UILabel = {
//        let headerTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
//        headerTitle.font = UIFont.systemFont(ofSize: 22, weight: .medium)
//        headerTitle.text = "Custom View"
//        headerTitle.textAlignment = .center
//        return headerTitle
//      }()
//
//    fileprivate let sideScl = RangeSliderThumbLayer1()
//    fileprivate let sideScr = RangeSliderThumbLayer1()
//
////    lazy var sideScl : UIControl = {
////       let sidsc = UIControl(frame: CGRect(x: 0, y: 0, width: 5, height: 35))
////        sidsc.backgroundColor = .blue
////        sidsc.isUserInteractionEnabled = true
////        return sidsc
////    }()
////
////    lazy var sideScr : UIControl = {
////        let sidsc = UIControl(frame: CGRect(x: 0, y: 0, width: 5, height: 35))
////        sidsc.backgroundColor = .blue
////        sidsc.isUserInteractionEnabled = true
////        return sidsc
////    }()
//
//    func updateLayerFrames(){
//        let lowerThumbCenter = positionForValue(lowerValue)
//        print(lowerThumbCenter, "thumb center")
////        sideScl.frame = CGRect(x: lowerThumbCenter - thumbWidth/2.0, y: 0, width: thumbWidth, height: 35)
//        self.frame = CGRect(x: self.frame.origin.x + lowerThumbCenter - thumbWidth/2.0, y: 0, width: self.bounds.width - (lowerThumbCenter - thumbWidth/2.0), height: 35)
//
//        self.superview?.layoutIfNeeded()
//        sideScl.setNeedsDisplay()
//    }
//
//
//    func positionForValue(_ value: Double) -> Double {
//        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
//            (maximumValue - minimumValue) + Double(thumbWidth/2.0)
//    }
//
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//    setupView()
//  }
//
//  //initWithCode to init view from xib or storyboard
//  required init?(coder aDecoder: NSCoder) {
//    super.init(coder: aDecoder)
//    setupView()
//  }
//
//  //common func to init our view
//  private func setupView() {
//    backgroundColor = .systemPink
////    sideScl.autoresizingMask = [.flexibleRightMargin]
////    sideScr.autoresizingMask = [.flexibleLeftMargin]
////      sideScl.rangeSlider = self
//      sideScl.contentsScale = UIScreen.main.scale
//
//      layer.addSublayer(sideScl)
//
//
////      sideScr.rangeSlider = self
//      sideScr.contentsScale = UIScreen.main.scale
//      layer.addSublayer(sideScr)
////      layer.addSublayer(sideScl)
////      layer.addSublayer(sideScr)
//      addSubview(headerTitle)
//  }
//
//    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//
//        return true
////        previouslocation = touch.location(in: self)
////
////        // Hit test the thumb layers
////        if lowerThumbLayer.frame.contains(previouslocation) {
////            lowerThumbLayer.highlighted = true
////            lowerLayerSelected = lowerThumbLayer.highlighted
////
////        } else if upperThumbLayer.frame.contains(previouslocation) {
////            upperThumbLayer.highlighted = true
////            lowerLayerSelected = lowerThumbLayer.highlighted
////
////        }
////        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
//    }
//
//    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//        let location = touch.location(in: self)
//
//        // Determine by how much the user has dragged
//        let deltaLocation = Double(location.x - previouslocation.x)
//        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)
//
//        previouslocation = location
//
//        // Update the values
////        if lowerThumbLayer.highlighted {
//          let lv = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gapBetweenThumbs)
//            print(upperValue, lv)
//            if upperValue - lv >= 1 {
//                lowerValue = lv
//            }
////        }
////        else if upperThumbLayer.highlighted {
////            let uv = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + gapBetweenThumbs, upperValue: maximumValue)
////            print(uv, lowerValue)
////            if uv - lowerValue >= 1 {
////                upperValue = uv
////            }
////        }
//
//        sendActions(for: .valueChanged)
//        return true
//    }
//
//    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
////        lowerThumbLayer.highlighted = false
////        upperThumbLayer.highlighted = false
//    }
//
//    func boundValue(_ value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
//        return min(max(value, lowerValue), upperValue)
//    }
//
//    var gapBetweenThumbs: Double {
//        return 0.0 * Double(thumbWidth) * (maximumValue - minimumValue) / Double(bounds.width)
//    }
//}

protocol CustomView2Protocols {
    func gotTouchEvent(mv : UIView)
}

class CustomView2: UIView, UIGestureRecognizerDelegate {
  
    var delegate : CustomView2Protocols?
    
    
    
    lazy var headerTitle: UILabel = {
        let headerTitle = UILabel(frame: .zero)
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        headerTitle.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        headerTitle.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        headerTitle.textAlignment = .center
        return headerTitle
      }()
    
   
    lazy var stickerImageView : UIImageView = {
      let stickerImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 35))
        stickerImageView.backgroundColor = .clear
        return stickerImageView
    }()
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  //initWithCode to init view from xib or storyboard
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  //common func to init our view
  private func setupView() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
      tapGesture.delegate = self
    addGestureRecognizer(tapGesture)
    backgroundColor = .yellow
    addSubview(headerTitle)
    addSubview(stickerImageView)
  }
    
//    private lazy var tapGesture = {
//        return UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
//    }()
    
    @objc
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        delegate?.gotTouchEvent(mv: self)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}



//
//  YView.swift
//  VIDEO
//
//  Created by appsyneefo on 9/21/22.
//

import UIKit

class YView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp(frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(_ rect: CGRect) {
        let layer = CAShapeLayer()
        // The Bezier path that we made needs to be converted to
        // a CGPath before it can be used on a layer.
        layer.path = createBeizierPath(rect)?.cgPath
        // apply other properties related to the path
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 1.0
        self.layer.addSublayer(layer)
    }
    
    func createBeizierPath(_ rect: CGRect) -> UIBezierPath? {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.origin.y + 10))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.origin.y))
        path.move(to: CGPoint(x: rect.midX, y: rect.origin.y + 10))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
    
    override func draw(_ rect: CGRect) {

    }
    
}

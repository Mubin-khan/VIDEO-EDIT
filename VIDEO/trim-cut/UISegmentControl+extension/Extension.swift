//
//  Extension.swift
//  VIDEO
//
//  Created by appsyneefo on 9/21/22.
//

import UIKit

extension UISegmentedControl {
//    func removeBorder() {
//        layer.cornerRadius = 4.0
//        layer.masksToBounds = true
//        if let backgroundColor = backgroundColor {
//            setBackgroundImage(type(of: self).init(color: backgroundColor), for: .normal, barMetrics: .default)
//        }
//        if let tintColor = tintColor {
//            setBackgroundImage(self.init(color: tintColor), for: .selected, barMetrics: .default)
//        }
//        if let backgroundColor = backgroundColor {
//            setDividerImage(self.init(color: backgroundColor), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
//        }
//        var attributes: [AnyHashable : Any]? = nil
//        if let tintColor = tintColor {
//            attributes = [
//                NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),
//                NSAttributedString.Key.foregroundColor : tintColor
//            ]
//        }
//        setTitleTextAttributes(attributes as? [NSAttributedString.Key : Any], for: .normal)
//        let highlightedAttributes = [
//            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),
//            NSAttributedString.Key.foregroundColor : UIColor.white
//        ]
//        setTitleTextAttributes(highlightedAttributes as? [NSAttributedString.Key : Any], for: .selected)
//    }
    
    func image(with color: UIColor?) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        if let CGColor = color?.cgColor {
            context?.setFillColor(CGColor)
        }
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

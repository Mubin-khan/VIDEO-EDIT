//
//  ExportViewController.swift
//  VIDEO
//
//  Created by appsyneefo on 9/18/22.
//

import UIKit
import MKRingProgressView

class ExportViewController: UIViewController {

    enum FilterStates {
        case mono, sepia, gpu, none
    }
    
    var currentFilter = FilterStates.none
    var brightness : CGFloat = 0
    var contrast : CGFloat = 1
    var saturation : CGFloat = 1
    
    
    let ringProgressView = RingProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    @IBOutlet weak var progessView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        ringProgressView.startColor = .white
        ringProgressView.endColor = .gray
        ringProgressView.ringWidth = 10
        ringProgressView.progress = 0.0
        progessView.addSubview(ringProgressView)
        
    }
    
    
    

}

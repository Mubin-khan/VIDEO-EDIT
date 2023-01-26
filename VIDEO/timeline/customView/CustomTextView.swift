//
//  CustomTextView.swift
//  VIDEO
//
//  Created by appsyneefo on 1/26/23.
//

import UIKit

class CustomView: UIView {
  //initWithFrame to init view from code
    lazy var headerTitle: UILabel = {
        let headerTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        headerTitle.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        headerTitle.text = "Custom View"
        headerTitle.textAlignment = .center
        return headerTitle
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
    backgroundColor = .red
    addSubview(headerTitle)
  }
}

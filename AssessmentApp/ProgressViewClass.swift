//
//  LoaderClass.swift
//  InsideTrackHealth
//
//  Created by Sumit K Das on 5/7/17.
//  Copyright © 2017 Sangeeth K Sivakumar. All rights reserved.
//

import Foundation
import UIKit

class ProgressViewClass: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
            label.font = UIFont(name: "Helvetica-Neue", size: 22)
            label.textColor = UIColor.black
        }
    }
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.prominent)
    let vibrancyView: UIVisualEffectView
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect())
        super.init(effect: blurEffect)
        self.setup()
}
    required init(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect())
        super.init(coder: aDecoder)!
        self.setup()
        
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(activityIndictor)
        vibrancyView.contentView.addSubview(label)
        activityIndictor.startAnimating()
}

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            
            let width = superview.frame.size.width / 2
            let height: CGFloat = 50.0
            self.frame = CGRect(x: (superview.frame.width / 2 - width / 2), y: (superview.frame.height / 2 - height / 2), width: width, height: height)
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 20
            
            activityIndictor.frame = CGRect(x: 5, y: (height / 2 - activityIndicatorSize / 2), width: activityIndicatorSize, height: activityIndicatorSize)
            
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            label.text = text
            label.textAlignment = NSTextAlignment.center

            label.frame = CGRect(x: activityIndicatorSize + 5, y: 0, width: (width - activityIndicatorSize - 15), height: height)
            
            label.textColor = UIColor.gray
            label.font = UIFont.boldSystemFont(ofSize: 16)
        }
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
}

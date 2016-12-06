//
//  CompilationOverlayView.swift
//  Happiness
//
//  Created by Deeksha Prabhakar on 12/4/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import ParseUI

class CompilationOverlayView: UIView {
    
    // Our custom view from the XIB file
    var view: UIView!
    @IBOutlet weak var kenBurnsView: JBKenBurnsView!
    @IBOutlet weak var profileImage: PFImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CompilationOverlayView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func initSubviews() {
        view = loadViewFromXibFile()
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = 4.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 4.0
        view.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        
        profileImage.layer.cornerRadius = 40.0
        profileImage.layer.borderColor = UIConstants.secondarySelectedThemeColor.cgColor
        profileImage.layer.borderWidth = 1.0
    }
    
    func displayView(_ onView: UIView) {
        
    }
    
    func hideView() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { (finished) -> Void in
            self.removeFromSuperview()
        })
    }


}

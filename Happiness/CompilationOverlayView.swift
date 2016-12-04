//
//  CompilationOverlayView.swift
//  Happiness
//
//  Created by Deeksha Prabhakar on 12/4/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

@objc protocol CompilationOverlayViewDelegate {
    @objc optional func startCompilation(inView: CompilationOverlayView)
}

class CompilationOverlayView: UIView {
    
    // Our custom view from the XIB file
    var view: UIView!
    @IBOutlet weak var kenBurnsView: JBKenBurnsView!
    @IBOutlet weak var actionView: UIView!
    weak var delegate:CompilationOverlayViewDelegate?
    
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
//        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
//        self.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = 4.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 4.0
        view.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
    }
    
    func displayView(_ onView: UIView) {
        self.alpha = 0.0
        onView.addSubview(self)
        
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: onView, attribute: .centerY, multiplier: 1.0, constant: -80.0)) // move it a bit upwards
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: onView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        onView.needsUpdateConstraints()
        
        // display the view
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 1.0
            self.transform = CGAffineTransform.identity
        }, completion: { (finished) -> Void in
           
        })
    }
    
    @IBAction func onStartKenBurns(_ sender: Any) {
        delegate?.startCompilation!(inView: self)
    }
    
    
    func hideView() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { (finished) -> Void in
            self.removeFromSuperview()
        })
    }


}

//
//  CompilationAlertView.swift
//  Happiness
//
//  Created by Deeksha Prabhakar on 12/4/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

protocol CompilationAlertViewDelegate {
    func compilationActionTakenByUser(isShow:Bool)
}

class CompilationAlertView: UIView {
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var yesButton: UIButton!
    var compileAlertDelegate: CompilationAlertViewDelegate?
    
    // Our custom view from the XIB file
    var view: UIView!
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
        let nib = UINib(nibName: "CompilationAlertView", bundle: bundle)
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
        view.layer.shadowRadius = 5.0
        view.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        //view.layer.borderColor =  UIColor.init(red: 171/255, green: 71/255, blue: 188/255, alpha: 1).cgColor
        //view.layer.borderWidth = 1.0
        view.clipsToBounds = true
        noButton.layer.cornerRadius = 5.0
        yesButton.layer.cornerRadius = 5.0
    }
    
    func displayView(onView: UIView) {
        self.alpha = 0.0
        onView.addSubview(self)
        
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: onView, attribute: .centerY, multiplier: 1.0, constant: -20.0)) // move it a bit upwards
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: onView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        onView.needsUpdateConstraints()
        
        // display the view
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 1.0
            self.transform = CGAffineTransform.identity
        }, completion: { (finished) -> Void in
            // When finished wait 1.5 seconds, than hide it
            let delayTime = DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                //self.hideView()
            }
        })

    }
    
    /**
     Updates constraints for the view. Specifies the height and width for the view
     */
    override func updateConstraints() {
        super.updateConstraints()
        
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 185.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 280.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
    }

  
    @IBAction func onCancel(_ sender: Any) {
        compileAlertDelegate?.compilationActionTakenByUser(isShow: false)
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        compileAlertDelegate?.compilationActionTakenByUser(isShow: true)
    }
    
    /**
     Hides the view with animation
     */
     func hideView() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { (finished) -> Void in
            self.removeFromSuperview()
        })
    }

}

//
//  TabBarView.swift
//  Happiness
//
//  Created by James Zhou on 11/12/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

@objc protocol TabBarViewDelegate {
    
    @objc optional func tabBarView(didTapButton tabBarView: TabBarView)
    
}


class TabBarView: UIView {

    @IBOutlet weak var tabButton: UIButton!
    
    weak var delegate: TabBarViewDelegate?
    
    override func awakeFromNib() {
        self.tabButton.addTarget(self, action: #selector(onButtonTap), for: .touchUpInside)
    }
    
    func setTabName(name: String) {
        self.tabButton.setTitle(name, for: .normal)
        self.tabButton.titleLabel?.font = UIFont(name: UIConstants.textFontName, size: 18)
    }
    
    func markSelected() {
        self.backgroundColor = UIConstants.secondaryThemeColor
        self.tabButton.setTitleColor(UIConstants.primaryThemeColor, for: .normal)
    }
    
    func markUnselected() {
        self.backgroundColor = UIConstants.primaryThemeColor
        self.tabButton.setTitleColor(UIConstants.secondaryThemeColor, for: .normal)
    }
    
    func onButtonTap() {
        self.delegate?.tabBarView?(didTapButton: self)
    }

    

}

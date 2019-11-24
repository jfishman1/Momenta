//
//  BaseCell.swift
//  humble
//
//  Created by Jonathon Fishman on 10/7/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    
    // Protocol Delegate method
    weak var delegate: TransitioningDelegateForCVCell?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

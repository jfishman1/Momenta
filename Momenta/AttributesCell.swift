//
//  AttributesCell.swift
//  humble
//
//  Created by Jonathon Fishman on 2/18/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit

class AttributesCell: UITableViewCell {
    
    @IBOutlet weak var attributeLabel1: AttributesLabel!
    @IBOutlet weak var attributeLabel2: AttributesLabel!
    @IBOutlet weak var attributeLabel3: AttributesLabel!
    @IBOutlet weak var attributeLabel4: AttributesLabel!
    @IBOutlet weak var attributeLabel5: AttributesLabel!
    @IBOutlet weak var attributeLabel6: AttributesLabel!
    @IBOutlet weak var attributeLabel7: AttributesLabel!
    @IBOutlet weak var attributeLabel8: AttributesLabel!
   // @IBOutlet weak var attributeLabel9: AttributesLabel!
   // @IBOutlet weak var attributeLabel10: AttributesLabel!
    
    var labels = [AttributesLabel]()
    var attributeName = [String]()
    var attributesCount = 0
    var attributesArray = [String]() {
        didSet {
            for attribute in attributesArray {
                attributeName.append(attribute)
            }
        }
    }
    
    var item: ProfileViewModelItem? {
        didSet {
            guard let item = item as? ProfileViewModelAttributesItem else {
                return
            }
            self.attributesArray = item.attributes
            self.attributesCount = item.attributes.count
            //setupLabels()
        }
    }
    
    func setupLabels() {
        for i in 0..<attributesCount {
            let attributeLabel = labels[i] as AttributesLabel? 
            attributeLabel?.text = attributeName[i]
            attributeLabel?.isHidden = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labels.append(contentsOf: [attributeLabel1, attributeLabel2, attributeLabel3, attributeLabel4, attributeLabel5, attributeLabel6, attributeLabel7, attributeLabel8])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

class AttributesLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1
        backgroundColor = UIColor.white
        isHidden = true
    }

    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.width += 20
            contentSize.height += 23.5
            return contentSize
        }
    }
}

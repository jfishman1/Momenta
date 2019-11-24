//
//  SelectCategoryViewController.swift
//  humble
//
//  Created by Jonathon Fishman on 3/21/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit

class SelectCategoryViewController: UIViewController {
    
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    @IBOutlet weak var contentView: UIView!
    var selectedCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barButtonItem.image = UIImage(named: "CancelButtonGray")
        updateDisplay()
    }

    @IBAction func onSCButtonTap(_ sender: SCButton) {
        if !sender.isSelected {
            self.updateDisplay()
            sender.backgroundColor = Utility.sharedInstance.mainGreen
            sender.setTitleColor(.white, for: .normal)
            sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        }
        selectedCategory = sender.titleLabel?.text
        barButtonItem.image = UIImage(named: "checkmark icon")
    }
    
    func updateDisplay() {
        var arrayOfButtons = [SCButton]()
        for subview in self.contentView.subviews  {
            if subview is SCButton {
                arrayOfButtons.append(subview as! SCButton)
            }
        }
        for button in arrayOfButtons {
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor.darkGray, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        }
    }
    
    
    @IBAction func onDismissBarButton(_ sender: UIBarButtonItem) {
        if selectedCategory == nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "unwindSegueToCreatePostVC", sender: self)
        }
    }
    
}

class SCButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
        let height = heightAnchor.constraint(equalToConstant: 35)
        height.isActive = true
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1
        backgroundColor = UIColor.white
        setTitleColor(UIColor.darkGray, for: .normal)
        titleEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
    }
    
}

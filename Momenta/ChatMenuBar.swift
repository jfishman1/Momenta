//
//  ChatMenuBar.swift
//  humble
//
//  Created by Jonathon Fishman on 10/3/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit

class ChatMenuBar: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.isScrollEnabled = false
        return cv
    }()
    
    let menuBarCellId = "menuBarCellId"
    let labelNames = ["Groups", "Private"]
    var chatCollectionViewController: ChatCollectionViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.register(ChatMenuBarCell.self, forCellWithReuseIdentifier: menuBarCellId)
        addSubview(collectionView)
//        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
//        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition())
        setupHorizontalBar()
    }
    
    var horizontalBarLeftAnchorConstraint: NSLayoutConstraint?
    
    func setupHorizontalBar() {
        let horizontalBarView = UIView()
        horizontalBarView.backgroundColor = UIColor.darkGray
        horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(horizontalBarView)
        horizontalBarLeftAnchorConstraint = horizontalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        horizontalBarLeftAnchorConstraint?.isActive = true
        horizontalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        horizontalBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/2).isActive = true
        horizontalBarView.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        chatCollectionViewController?.scrollToMenuIndex(indexPath.item)
    }
    
    // MARK: UICollectionViewDataSource methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: menuBarCellId, for: indexPath) as! ChatMenuBarCell
        cell.textLabel.text = labelNames[indexPath.row]
        return cell
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 2, height: frame.height + 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

class ChatMenuBarCell: UICollectionViewCell {
    let textLabel: UILabel = {
        let tL = UILabel()
        tL.translatesAutoresizingMaskIntoConstraints = false
        tL.textColor = UIColor.lightGray
        tL.font = UIFont.boldSystemFont(ofSize: 20.0)
        return tL
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet{
            textLabel.highlightedTextColor = isHighlighted ? UIColor.darkGray : UIColor.lightGray
        }
    }
    
    override var isSelected: Bool {
        didSet {
            textLabel.highlightedTextColor = isSelected ? UIColor.darkGray : UIColor.lightGray
            //print("isSelected = \(isSelected)")
        }
    }
    
    func setupViews() {
        addSubview(textLabel)
        addConstraintsWithFormat(format: "H:[v0]", views: textLabel)
        addConstraintsWithFormat(format: "V:[v0(100)]", views: textLabel)
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
}

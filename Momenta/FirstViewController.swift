//
//  FirstViewController.swift
//  humble
//
//  Created by Jonathon Fishman on 12/15/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
        
    let imageArray = ["P1I1", "P1I2", "P1I3"] //h:390 w:300
    
    var contentWidth: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // scrollView.delegate = self
       // loadScrollViewImages()
    }

    func loadScrollViewImages() {
        pageControl.numberOfPages = imageArray.count
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = Utility.sharedInstance.mainGreen
        pageControl.addTarget(self, action: #selector(self.pageChanged), for: .valueChanged)
        
        for i in 0...2 {
            let imageToDisplay = UIImage(named: imageArray[i])
            let imageView = UIImageView(image: imageToDisplay)
            imageView.contentMode = UIView.ContentMode.scaleAspectFill
            //imageView.backgroundColor = .red
            
            let xCoordinate = view.frame.midX + view.frame.width * CGFloat(i)
//            print("xCoordinate: ", xCoordinate)
//            print("yCoordinate: ", scrollView.frame.height)
            contentWidth += view.frame.width
            scrollView.addSubview(imageView)
            
            imageView.frame = CGRect(x: xCoordinate - 150, y: (scrollView.frame.height - 390), width: 300, height: 390)
        }
        scrollView.contentSize = CGSize(width: contentWidth, height: 390)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
        pageControl.currentPageIndicatorTintColor = Utility.sharedInstance.mainGreen
    }
    
//    //MARK: UIScrollView Delegate
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let viewWidth: CGFloat = scrollView.frame.size.width
//        // content offset - tells by how much the scroll view has scrolled.
//        let pageNumber = floor((scrollView.contentOffset.x - viewWidth / 50) / viewWidth) + 1
//        pageControl.currentPage = Int(pageNumber)
//    }
    
    //MARK: Page tap action
    @objc func pageChanged() {
        let pageNumber = pageControl.currentPage
        var frame = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(pageNumber)
        frame.origin.y = 0
        scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    @IBAction func pageDidChange(_ sender: UIPageControl) {
    }
    

}

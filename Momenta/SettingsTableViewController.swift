//
//  SettingsTableViewController.swift
//  humble
//
//  Created by Jonathon Fishman on 3/8/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import UIKit
import OneSignal

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var user: User?
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getDataUpdate), name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: nil)
        UserDataManager.sharedInstance.requestCurrentUserData()
    }
    @objc private func getDataUpdate() {
        if let currentUserData = UserDataManager.sharedInstance.currentUserData {
            self.user = currentUserData
            let firstName = user?.firstName ?? "Name"
            let lastName = user?.lastName ?? ""
            nameLabel.text = "\(firstName) \(lastName)"
            emailLabel.text = user?.email ?? "None"
        } else {
            handleLogout()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .default
        setupNavigationItems()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        //attemptReloadOfTableView()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: self)
    }
    
    func setupNavigationItems() {
        let dismissImage = UIImage(named: "CancelButtonGray")?.withRenderingMode(.alwaysOriginal)
        let dismissBarButtonItem = UIBarButtonItem(image: dismissImage, style: .plain, target: self, action: #selector(leaveSettings))
        navigationItem.leftBarButtonItem = dismissBarButtonItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "goToEditUserSettings", sender: self)
            } else if indexPath.row == 1 {
                performSegue(withIdentifier: "goToEditUserSettings", sender: self)
            }
        }
    }
    
    @objc func leaveSettings() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onLogoutButton(_ sender: UIButton) {
        handleLogout()
    }
    
    func handleLogout() {
        Utility.sharedInstance.logoutAndRemoveUserDefaults()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FirstViewController") as UIViewController
        OneSignal.logoutEmail()
        OneSignal.removeExternalUserId({externalUserIdRemoved in
            print("external User ID Disassociated: ", externalUserIdRemoved.debugDescription)
        })
        self.present(controller, animated: true, completion: nil)
    }

}

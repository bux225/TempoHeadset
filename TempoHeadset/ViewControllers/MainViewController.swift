//
//  MainViewController.swift
//  TempoHeadset
//
//  Created by Soltis, Matthew on 2/3/19.
//  Copyright © 2019 Soltis, Matthew. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    fileprivate var channelViewController: ChannelViewController?
    fileprivate var usersTableViewController: UsersTableViewController?
    fileprivate var openTokController = OpenTokController()
    fileprivate var loginViewController = LoginViewController()
    let spinner = SpinnerViewController()
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        print("Main ViewDidLoad")
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //defaults.set(nil, forKey: "userName")
        openTokController.delegate = self
        channelViewController?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Main ViewDidAppear")
        if defaults.object(forKey: "userName") == nil {
            performSegue(withIdentifier: "loginView", sender: self)
            print("performSegue")
        } else {
            connectToSession()
        }
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Main Prepare for Segue")
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let channelController = segue.destination as? ChannelViewController {
            channelViewController = channelController
        }
        if let usersController = segue.destination as? UsersTableViewController {
            usersTableViewController = usersController
        }
        if let loginController = segue.destination as? LoginViewController {
            loginViewController = loginController
        }
    }
    
    func connectToSession() {
        print("Main connectToSession")
        createSpinnerView()
        openTokController.connectToSession(teamName: defaults.object(forKey: "teamName") as! String)
    }
    
    func createSpinnerView() {
        print("Main createSpinnerView")
        self.addChild(spinner)
        spinner.view.frame = view.frame
        self.view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
    
    func stopSpinner() {
        print("Main stopSpinner")
        spinner.willMove(toParent: nil)
        spinner.view.removeFromSuperview()
        spinner.removeFromParent()
    }
    
}

extension MainViewController: OpenTokDelegate {
    
    func didPublish(_ myStreamId: String) {
        stopSpinner()
    }
    
    func usersChanged(_ usersOnChannel: [String]) {
        usersTableViewController?.modifyUsers(newUsers: usersOnChannel)
    }
}

extension MainViewController: ChannelViewControllerDelegate {
    func switchChannels(_ channel: Int) {
        openTokController.switchChannels(channel: channel)
    }
}


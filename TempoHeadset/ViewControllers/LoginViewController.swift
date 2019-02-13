//
//  LoginViewController.swift
//  TempoHeadset
//
//  Created by Soltis, Matthew on 2/3/19.
//  Copyright © 2019 Soltis, Matthew. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var ch0: UITextField!
    @IBOutlet weak var ch1: UITextField!
    @IBOutlet weak var ch2: UITextField!
    @IBOutlet weak var ch3: UITextField!
    let defaults = UserDefaults.standard


    override func viewDidLoad() {
        print("login ViewDidLoad")
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if defaults.object(forKey: "teamName") == nil {
            defaults.set("Legacy High School", forKey: "teamName")
            let teamChannels = ["Offense 1","Offense 2","Defense 1","Defense 2"]
            defaults.set(teamChannels, forKey: "teamChannels")
            defaults.synchronize()
        }
        teamName.text = defaults.object(forKey: "teamName") as? String
        let channels = defaults.object(forKey: "teamChannels") as? [String]
        ch0.text = channels![0]
        ch1.text = channels![1]
        ch2.text = channels![2]
        ch3.text = channels![3]
    }
    

    @IBAction func setUsername(_ sender: UITextField) {
        defaults.set(sender.text, forKey: "userName")
        defaults.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ChannelViewController.swift
//  TempoHeadset
//
//  Created by Soltis, Matthew on 2/3/19.
//  Copyright © 2019 Soltis, Matthew. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation


class ChannelViewController: UIViewController {
    weak var delegate: ChannelViewControllerDelegate?
    @IBOutlet var channelButtons: [UIButton]!
    @IBOutlet weak var allButton: UIButton!
    var currentChannel:Int = -1
    var channelNames = [String]()
    
    override func viewDidLoad() {
        print("channel ViewDidLoad")
        super.viewDidLoad()
        
        // Do any additional setup after loading the view
        var audioPlayer = AVAudioPlayer()
        let commandCenter = MPRemoteCommandCenter.shared()
        let sound = Bundle.main.path(forResource: "intro", ofType: "mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
            audioPlayer.play()
        } catch {
            print(error)
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [unowned self] event in
            self.captureToggle()
            return .success
        }
        
        if let chNames = UserDefaults.standard.object(forKey: "teamChannels") as? [String] {
            channelNames = chNames
        } else {
            channelNames = ["Undefined", "Undefined", "Undefined", "Undefined"]
        }
        for button in channelButtons {
            formatDisconnectedButton(button: button)
            button.layer.cornerRadius = button.frame.height / 2
            button.clipsToBounds = true
            button.setTitle(channelNames[button.tag], for: .normal)
        }
        allButton.backgroundColor = UIColor.red
        allButton.setTitleColor(.white, for: .normal)
        allButton.layer.cornerRadius = allButton.frame.height / 2
        allButton.clipsToBounds = true
    }
    
    @IBAction func selectChannel(_ sender: UIButton) {
        let index = sender.tag
        print(NSDate().timeIntervalSince1970)
        if index != currentChannel {
            if currentChannel != -1 {
                formatDisconnectedButton(button: channelButtons[currentChannel])
            } else {
                allButton.backgroundColor = UIColor.red
                allButton.setTitleColor(.white, for: .normal)
            }
            print("Did Select channel: " + String(index))
            currentChannel = index
            formatConnectedButton(button: channelButtons[currentChannel])
            delegate?.switchChannels(currentChannel)
        }
    }
    
    @IBAction func selectAllButton(_ sender: Any) {
        print("Did Select channel: All")
        if currentChannel != -1 {
            formatDisconnectedButton(button: channelButtons[currentChannel])
        }
        currentChannel = -1
        formatConnectedButton(button: allButton)
    }
    
    func formatDisconnectedButton(button:UIButton) {
        button.backgroundColor = UIColor(red:102/255, green:102/255, blue:255/255, alpha:1.0)
        button.setTitleColor(.white, for: .normal)
    }
    func formatConnectedButton(button:UIButton) {
        button.backgroundColor = UIColor.green
        button.setTitleColor(.black, for: .normal)
    }
    
    func captureToggle() {
        print("channel captureToggle")
        var newChannel = currentChannel + 1
        if newChannel == channelButtons.count {
            newChannel = 0
        }
        channelButtons[newChannel].sendActions(for: .touchUpInside)
    }
    
}

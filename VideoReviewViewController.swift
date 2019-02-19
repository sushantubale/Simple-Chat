//
//  VideoReviewViewController.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/19/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class VideoReviewViewController: UIViewController {

    var url: URL?
    fileprivate var player: AVPlayer? {
        didSet { player?.play() }
    }
    
    var playerLayer: AVPlayerLayer?
    fileprivate var playerObserver: Any?

    deinit {
        guard let observer = playerObserver else { return }
        NotificationCenter.default.removeObserver(observer)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(backAction))
        
        let fileURL =  url
        let player = AVPlayer(url: fileURL!)
        let resetPlayer = {
            player.seek(to: CMTime.zero)
            player.play()
        }
        playerObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { notification in
            resetPlayer()
        }
        self.player = player
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = view.bounds
        view.layer.insertSublayer(playerLayer!, at: 0)
        let sendButton = UIButton()
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(UIColor.blue, for: .normal)
        sendButton.frame = CGRect(x: 15, y: -50, width: 300, height: 500)
        //myFirstButton.addTarget(self, action: #selector(myClass.pressed(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(sendButton)
    }
    
    @objc func backAction() {
        playerLayer?.removeFromSuperlayer()
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

//
//  VideoViewController.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/18/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class VideoViewController: UIViewController {

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

        self.navigationController?.navigationBar.setGradientBackground(colors: [
            UIColor.red.cgColor,
            UIColor.green.cgColor,
            UIColor.blue.cgColor
            ])
        

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

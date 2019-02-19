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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let videoPlayer = AVPlayer(url: url!)
        // create instance of playerlayer with videoPlayer
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        // set its videoGravity to AVLayerVideoGravityResizeAspectFill to make it full size
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // add it to your view
        playerLayer.frame = self.view.frame
        
        self.view.layer.addSublayer(playerLayer)
        // start playing video
        videoPlayer.play()
        

        // Do any additional setup after loading the view.
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

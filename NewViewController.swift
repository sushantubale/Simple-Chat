//
//  NewViewController.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 2/17/19.
//  Copyright © 2019 Sushant Ubale. All rights reserved.
//

import UIKit
import Photos
import SceneKit
import ARKit

class NewViewController: UIViewController, ARSCNViewDelegate {
    
    var users: Users?
        
    lazy var playButton: UIButton = {
        let playbutton = UIButton(type: .system)
        playbutton.translatesAutoresizingMaskIntoConstraints = false
        playbutton.setImage(UIImage(named: "play3.png"), for: .normal)
        playbutton.tintColor = .white
        return playbutton
    }()
    
     var sceneView: ARSCNView!

    var recorder: SceneKitVideoRecorder?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backAction))
        sceneView = ARSCNView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height), options: [:])
        sceneView.delegate = self
        playButton.addTarget(self, action: #selector(startRecording(sender:)), for: UIControl.Event.touchDown)
        playButton.addTarget(self, action: #selector(stopRecording(sender:)), for:  .touchUpInside)
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "CeilingFanLamp.scn")
        
        // Set the scene to the view
        sceneView.scene = scene!
        
        self.sceneView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: self.sceneView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: self.sceneView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        self.view.addSubview(sceneView)
        recorder = try! SceneKitVideoRecorder(withARSCNView: sceneView)
    }
    
    @objc func backAction() {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    @objc func startRecording (sender: UIButton) {
        sender.backgroundColor = .red
        self.recorder?.startWriting()
    }
    
    @objc func stopRecording (sender: UIButton) {
        sender.backgroundColor = .white
        self.recorder?.finishWriting().onSuccess { [weak self] url in
            print("Recording Finished", url)
            self?.checkAuthorizationAndPresentActivityController(toShare: url, using: self!)
        }
    }
    
    private func checkAuthorizationAndPresentActivityController(toShare data: Any, using presenter: UIViewController) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            let videoReviewViewController = VideoReviewViewController()
            videoReviewViewController.url = data as! URL
            videoReviewViewController.users = users
            DispatchQueue.main.async {
                let navController = UINavigationController(rootViewController: videoReviewViewController)
                self.present(navController, animated: true, completion: nil)
            }
            
        case .restricted, .denied:
            let libraryRestrictedAlert = UIAlertController(title: "Photos access denied",
                                                           message: "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots.",
                                                           preferredStyle: UIAlertController.Style.alert)
            libraryRestrictedAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            presenter.present(libraryRestrictedAlert, animated: true, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                if authorizationStatus == .authorized {
                    let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                    activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.print]
                    presenter.present(activityViewController, animated: true, completion: nil)
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }

}

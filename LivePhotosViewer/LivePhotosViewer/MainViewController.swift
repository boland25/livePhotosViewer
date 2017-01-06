//
//  MainViewController.swift
//  LivePhotosViewer
//
//  Created by Gregory Boland on 1/6/17.
//  Copyright © 2017 mallocmedia. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class MainViewController: AVPlayerViewController {

    let photoStore: LivePhotoStore = LivePhotoStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoStore.configure(targetSize: targetSize)
        photoStore.filter()
        startTheShow()
        print("after configure is called")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startTheShow() -> Void {
        //I call get resource here and display it in the player
        photoStore.getNextPhoto{ (livePhotoURL) in
            // Now that we have the Live Photo, show it.
            let playerItem = AVPlayerItem(url: livePhotoURL)
            self.player = AVPlayer(playerItem: playerItem)
            self.player?.play()
        }
    }
    
    // MARK: Image display
    
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: self.view.bounds.width * scale,
                      height: self.view.bounds.height * scale)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

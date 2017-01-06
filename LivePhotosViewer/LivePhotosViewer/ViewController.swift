//
//  ViewController.swift
//  LivePhotosViewer
//
//  Created by boland on 12/26/16.
//  Copyright © 2016 mallocmedia. All rights reserved.
//

import UIKit
import Photos
#if os(iOS)
import PhotosUI
#endif

final class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    @IBOutlet weak var videoContainer: UIView!
    
    let photoStore: LivePhotoStore = LivePhotoStore()
    var videoPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        livePhotoView.delegate = self
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
            if let player = self.videoPlayer {
                //if it exists already just replace the item
                player.replaceCurrentItem(with: playerItem)
            } else {
                self.videoPlayer = AVPlayer(playerItem: playerItem)
                self.playerLayer = AVPlayerLayer(player: self.videoPlayer)
                if let playaLayer = self.playerLayer {
                    playaLayer.frame = self.view.bounds
                    self.videoContainer.layer.addSublayer(playaLayer)
                    print("slow play? \(playerItem.canPlaySlowForward)")
                    self.videoPlayer?.play()
                    self.videoPlayer?.rate = 0.3
                }
            }
            //TODO: remove the old video data at the old url, then save the new one
            
            
            
        }
    }
    
    // MARK: Image display
    
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale,
                      height: imageView.bounds.height * scale)
    }


}

extension ViewController: PHLivePhotoViewDelegate {
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        print("Beginning playback")
    }
    
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        print("did end playing")
        //this will need to trigger the next one
        startTheShow()
    }

    
}


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
        photoStore.getLivePhoto(for: 1) { (livePhoto) in
            // Now that we have the Live Photo, show it.
            self.imageView.isHidden = true
            self.livePhotoView.livePhoto = livePhoto
            self.livePhotoView.startPlayback(with: .full)
        }
    }
    
    // MARK: Image display
    
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale,
                      height: imageView.bounds.height * scale)
    }


}


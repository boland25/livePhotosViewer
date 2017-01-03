//
//  LivePhotoStore.swift
//  LivePhotosViewer
//
//  Created by boland on 12/29/16.
//  Copyright © 2016 mallocmedia. All rights reserved.
//

import UIKit
import Photos
#if os(iOS)
    import PhotosUI
#endif

enum Section: Int {
    case allPhotos = 0
    case smartAlbums
    case userCollections
    
    static let count = 3
}



class LivePhotoStore: NSObject {
    
    var allPhotos: PHFetchResult<PHAsset>!
    var livePhotos: [PHAsset]?
    var currentPhotoIndex: Int = 0
    var targetSize: CGSize?
    var smartAlbums: PHFetchResult<PHAssetCollection>!
    var userCollections: PHFetchResult<PHCollection>!
    let sectionLocalizedTitles = ["", NSLocalizedString("Smart Albums", comment: ""), NSLocalizedString("Albums", comment: "")]
    
    
    public func configure(targetSize: CGSize) {
        print("configuring")
        self.targetSize = targetSize
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        
        PHPhotoLibrary.shared().register(self as PHPhotoLibraryChangeObserver)
        
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    public func filter() -> Void {
        var onlyLivePhotos = [PHAsset]()
        allPhotos.enumerateObjects({ (asset, index, isLast) in
            if asset.mediaSubtypes == .photoLive {
                print("This is a live photo \(asset.mediaSubtypes)")
                onlyLivePhotos.append(asset)
            }
        })
        //I think for now i'm just going to overwrite whats there
        //TODO: in the future I should probably check for something there first
        livePhotos = onlyLivePhotos
        if let livePhotos = livePhotos {
            currentPhotoIndex = livePhotos.count - 1
        }

    }
    
    public func getLivePhoto(for index: Int, completionHandler: @escaping ((PHLivePhoto) -> Void)) -> Void {
        guard  let onlyLivePhotos = livePhotos, let targetSize = targetSize else { return }
        
        let asset = onlyLivePhotos[index]
        let options = PHLivePhotoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            // Handler might not be called on the main queue, so re-dispatch for UI work.
            DispatchQueue.main.async {
                //TODO: Add in the progress viewer here
                //self.progressView.progress = Float(progress)
            }
        }
        
        PHImageManager.default().requestLivePhoto(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { livePhoto, info in
            // Hide the progress view now the request has completed.
            //self.progressView.isHidden = true
            
            // If successful, show the live photo view and display the live photo.
            guard let livePhoto = livePhoto else { return }
            completionHandler(livePhoto)
        })
    }
    
    public func getResource(for index: Int) -> Void {
        guard  let onlyLivePhotos = livePhotos else { return }
        
        let asset = onlyLivePhotos[index]
        
        let resourceMan = PHAssetResourceManager.default()
        let assetResources = PHAssetResource.assetResources(for: asset)
        
        assetResources.forEach { (resource) in
            if resource.type == .pairedVideo {
                resourceMan.requestData(for: resource, options: nil, dataReceivedHandler: { (data) in
                    print("here is the data that I need to do something with \(data)")
                    //the asset itself should have a PHLIvePHotoView and I should be able to control it somehow
                    //TODO: **START HERE GREG*** I can probably just play this data in an AVPLauer and call it a day
                }, completionHandler: { (error) in
                    if let error = error {
                        print("error \(error)")
                    }
                })
            }
        }
    }
    
    public func getNextPhoto(completionHandler: @escaping ((PHLivePhoto) -> Void)) -> Void {
        guard let livePhotos = livePhotos else { return }
        
        
        getLivePhoto(for: currentPhotoIndex, completionHandler:completionHandler)
        currentPhotoIndex -= 1
        
    }

}

// MARK: PHPhotoLibraryChangeObserver
extension LivePhotoStore: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Check each of the three top-level fetches for changes.
            
            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
                // Update the cached fetch result.
                allPhotos = changeDetails.fetchResultAfterChanges
                // (The table row for this one doesn't need updating, it always says "All Photos".)
            }
            
            // Update the cached fetch results, and reload the table sections to match.
            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
                smartAlbums = changeDetails.fetchResultAfterChanges
            }
            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
                userCollections = changeDetails.fetchResultAfterChanges
            }
            
        }
    }
}


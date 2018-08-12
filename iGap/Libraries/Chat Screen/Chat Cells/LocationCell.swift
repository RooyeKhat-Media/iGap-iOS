/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */


import UIKit

class LocationCell: AbstractCell {
    
    @IBOutlet var mainBubbleView: UIView!
    @IBOutlet var mainBubbleViewWidth: NSLayoutConstraint!
    
    class func sizeForLocation() -> CGSize {
        return CGSize(width: 300, height: 180)
    }
    
    class func nib() -> UINib {
        return UINib(nibName: "LocationCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    class func locationPath(latitude: Double, longitude: Double) -> URL? {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return NSURL(fileURLWithPath: documents).appendingPathComponent("\(latitude)_\(longitude)")
    }
    
    override func setMessage(_ message: IGRoomMessage, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: RoomMessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        initializeView()
        makeLocationView()
        super.setMessage(message, isIncommingMessage: isIncommingMessage, shouldShowAvatar: shouldShowAvatar, messageSizes: messageSizes, isPreviousMessageFromSameSender: isPreviousMessageFromSameSender, isNextMessageFromSameSender: isNextMessageFromSameSender)
        manageLocationViewPosition(messageSizes: messageSizes)
        setLocationImage()
    }
    
    private func initializeView(){
        /********** view **********/
        mainBubbleViewAbs = mainBubbleView
        mainBubbleViewWidthAbs = mainBubbleViewWidth
    }
    
    private func setLocationImage(path: String? = nil){
        
        let latitude = finalRoomMessage.location?.latitude
        let longitude = finalRoomMessage.location?.longitude
        
        let locationPath = LocationCell.locationPath(latitude: latitude!, longitude: longitude!)?.path
        
        if FileManager.default.fileExists(atPath: locationPath!) {
            if let image = UIImage(contentsOfFile: locationPath!) {
                imgMediaAbs.image = image
            }
        } else {
            IGDownloadManager.sharedManager.downloadLocation(latitude: latitude!, longitude: longitude!, locationObserver: { (locationPath) -> Void in
                if let image = UIImage(contentsOfFile: locationPath) {
                    DispatchQueue.main.async {
                        self.imgMediaAbs.image = image
                    }
                }
            })
        }
    }
    
    private func makeLocationView(){
        if imgMediaAbs != nil {
            imgMediaAbs.removeFromSuperview()
            imgMediaAbs = nil
        }
        
        if imgMediaAbs == nil {
            imgMediaAbs = IGImageView()
            mainBubbleViewAbs.addSubview(imgMediaAbs)
        }
    }
    
    private func manageLocationViewPosition(messageSizes: RoomMessageCalculatedSize){
        imgMediaAbs.snp.makeConstraints { (make) in
            
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing)
            make.leading.equalTo(mainBubbleViewAbs.snp.leading)
            
            if imgMediaTopAbs != nil { imgMediaTopAbs.deactivate() }
            if imgMediaHeightAbs != nil { imgMediaHeightAbs.deactivate() }
            
            if isForward {
                imgMediaTopAbs = make.top.equalTo(forwardViewAbs.snp.bottom).constraint
            } else if isReply {
                imgMediaTopAbs = make.top.equalTo(replyViewAbs.snp.bottom).constraint
            } else {
                imgMediaTopAbs = make.top.equalTo(mainBubbleViewAbs.snp.top).constraint
            }
            imgMediaHeightAbs = make.height.equalTo(messageSizes.MessageAttachmentHeight).constraint
            
            if imgMediaTopAbs != nil { imgMediaTopAbs.activate() }
            if imgMediaHeightAbs != nil { imgMediaHeightAbs.activate() }
        }
    }
}

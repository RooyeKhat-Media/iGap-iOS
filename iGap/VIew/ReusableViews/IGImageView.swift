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

class IGImageView: GIFImageView {
    var attachmentId: String?
    
    func prepareForReuse() {
        attachmentId = nil
        animator?.prepareForReuse()
    }
    
    //FIXME: override was removed (check performance)
    func setThumbnaill(for attachment: IGFile) {
        attachmentId = attachment.primaryKeyId
        setOrFetchThumbnail(for: attachment)
    }
    
    func setOrFetchThumbnail(for attachment: IGFile) {
        if attachment.primaryKeyId != self.attachmentId {
            return
        }
        if let path = attachment.path() {
            if FileManager.default.fileExists(atPath: path.path) {
                if let image = UIImage(contentsOfFile: path.path) {
                    self.image = image
                    return
                }
            }
        }
        
        if let thumbnail = attachment.smallThumbnail {
            do {
                var path = URL(string: "")
                if attachment.attachedImage != nil {
                    self.image = attachment.attachedImage
                } else {
                    var image: UIImage?
                    path = thumbnail.path()
                    if FileManager.default.fileExists(atPath: path!.path) {
                        image = UIImage(contentsOfFile: path!.path)
                    }
                    
                    if image != nil {
                        self.image = image
                    } else {
                        throw NSError(domain: "asa", code: 1234, userInfo: nil)
                    }
                }
            } catch {
                IGDownloadManager.sharedManager.download(file: thumbnail, previewType:.smallThumbnail, completion: { (attachment) -> Void in
                    DispatchQueue.main.async {
                        self.setOrFetchThumbnail(for: attachment)
                    }
                }, failure: {
                    
                })
            }
        } else {
            switch attachment.type {
            case .image:
                self.image = nil
                break
            case .gif:
                break
            case .video:
                break
            case .audio:
                self.image = UIImage(named:"IG_Message_Cell_Player_Default_Cover")
                break
            case .voice:
                break
            case .file:
                break
            }
        }
    }
    
    
    //FIXME: override was removed (check performance)
    func setImagee(avatar: IGAvatar) {
        attachmentId = avatar.file?.primaryKeyId
        setOrFetchAvatar(avatar)
    }
    
    func setOrFetchAvatar(_ avatar: IGAvatar) {
        if avatar.file?.primaryKeyId != self.attachmentId {
            return
        }
        if let smallThumbnail = avatar.file?.smallThumbnail {
            do {
                if smallThumbnail.attachedImage != nil {
                    self.image = smallThumbnail.attachedImage
                } else {
                    var image: UIImage?
                    let path = smallThumbnail.path()
                    if FileManager.default.fileExists(atPath: path!.path) {
                        image = UIImage(contentsOfFile: path!.path)
                    }
                    
                    if image != nil {
                        self.image = image
                    } else {
                        throw NSError(domain: "asa", code: 1234, userInfo: nil)
                    }
                }
            } catch {
                IGDownloadManager.sharedManager.download(file: smallThumbnail, previewType:.smallThumbnail, completion: { (attachment) -> Void in
                    DispatchQueue.main.async {
                        let path = smallThumbnail.path()
                        if let data = try? Data(contentsOf: path!) {
                            if let image = UIImage(data: data) {
                                self.image = image
                            }
                        }
                    }
                }, failure: {
                    
                })
            }
        }
        
    }
    
    
    
//    public func prepareForAnimation(withGIFData imageData: Data, loopCount: Int = 0, completionHandler: ((Void) -> Void)? = .none) {
//        self.image = UIImage(data: imageData)
//        animator?.prepareForAnimation(withGIFData: imageData, size: frame.size, contentMode: contentMode, loopCount: loopCount, completionHandler: completionHandler)
//    }
    
}

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
import SnapKit

class FileCell: AbstractCell {
    
    @IBOutlet var mainBubbleView: UIView!
    @IBOutlet weak var messageView: UIView!
    
    @IBOutlet weak var txtMessageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainBubbleViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var txtMessage: ActiveLabel!
    
    var fileTop: Constraint!
    
    var txtFileName: UILabel!
    var txtFileSize: UILabel!
    
    class func nib() -> UINib {
        return UINib(nibName: "FileCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    
    override func setMessage(_ message: IGRoomMessage, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: RoomMessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        initializeView()
        makeFileView()
        super.setMessage(message, isIncommingMessage: isIncommingMessage, shouldShowAvatar: shouldShowAvatar, messageSizes: messageSizes, isPreviousMessageFromSameSender: isPreviousMessageFromSameSender, isNextMessageFromSameSender: isNextMessageFromSameSender)
        manageFileViewPosition()
        setFile()
    }
    
    private func initializeView(){
        
        /********** view **********/
        mainBubbleViewAbs = mainBubbleView
        mainBubbleViewWidthAbs = mainBubbleViewWidth
        messageViewAbs = messageView
        
        /********** lable **********/
        txtMessageAbs = txtMessage
        
        /******** constraint ********/
        txtMessageHeightConstraintAbs = txtMessageHeightConstraint
    }
    
    
    /*
     * for this cell we need evaluate views before call setMessage because in setMessage indicatorViewAbs
     * will be managed for download/upload state so indicatorViewAbs should have a value and for evaluate
     * position of views after setMessage we call manageFileViewPosition because first we need evaluate
     * forwardViewAbs/replyViewAbs in AbstractCell
     */
    private func makeFileView(){
        if imgFileAbs == nil {
            imgFileAbs = UIImageView()
            mainBubbleViewAbs.addSubview(imgFileAbs)
        }
        
        if indicatorViewAbs == nil {
            indicatorViewAbs = IGDownloadUploadIndicatorView()
            mainBubbleViewAbs.addSubview(indicatorViewAbs)
        }
        
        if txtFileName == nil {
            txtFileName = UILabel()
            txtFileName.font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightMedium)
            txtFileName.numberOfLines = 1
            mainBubbleViewAbs.addSubview(txtFileName)
        }
        
        if txtFileSize == nil {
            txtFileSize = UILabel()
            txtFileSize.font = UIFont.systemFont(ofSize: 11.0, weight: UIFontWeightMedium)
            txtFileSize.numberOfLines = 0
            mainBubbleViewAbs.addSubview(txtFileSize)
        }
    }
    
    private func manageFileViewPosition(){
        imgFileAbs.snp.makeConstraints { (make) in
            
            if fileTop != nil { fileTop.deactivate() }
            
            if isForward {
                fileTop = make.top.equalTo(forwardViewAbs.snp.bottom).offset(8.0).constraint
            } else if isReply {
                fileTop = make.top.equalTo(replyViewAbs.snp.bottom).offset(8.0).constraint
            } else {
                fileTop = make.top.equalTo(mainBubbleViewAbs.snp.top).offset(8.0).constraint
            }
            
            if fileTop != nil { fileTop.activate() }
            
            make.leading.equalTo(mainBubbleView.snp.leading).offset(8.0)
            make.width.equalTo(30.0)
            make.height.equalTo(34.0)
        }
        
        indicatorViewAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(imgFileAbs.snp.leading)
            make.trailing.equalTo(imgFileAbs.snp.trailing)
            make.top.equalTo(imgFileAbs.snp.top).offset(2)
            make.bottom.equalTo(imgFileAbs.snp.bottom).offset(-2)
        }
        
        txtFileName.snp.makeConstraints { (make) in
            make.leading.equalTo(imgFileAbs.snp.trailing).offset(10.0)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-10.0)
            make.top.equalTo(imgFileAbs.snp.top)
        }
        
        txtFileSize.snp.makeConstraints { (make) in
            make.leading.equalTo(imgFileAbs.snp.trailing).offset(10.0)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(10.0)
            make.bottom.equalTo(imgFileAbs.snp.bottom)
        }
    }
    
    private func setFile(){
        
        let attachment = finalRoomMessage.attachment!
        imgFileAbs.setThumbnail(for: attachment)
        txtFileName.text = attachment.name
        txtFileSize.text = attachment.sizeToString()
        
        if self.attachment?.status != .ready {
            indicatorViewAbs.layer.cornerRadius = 16.0
            indicatorViewAbs.layer.masksToBounds = true
            indicatorViewAbs.delegate = self
        }
        
        indicatorViewAbs.shouldShowSize = true
    }
}




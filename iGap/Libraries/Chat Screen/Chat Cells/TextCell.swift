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

class TextCell: AbstractCell {
    
    @IBOutlet var mainBubbleView: UIView!
    @IBOutlet weak var forwardView: UIView!
    @IBOutlet weak var replyView: UIView!
    @IBOutlet weak var avatarBackView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var replyLineView: UIView!
    
    @IBOutlet weak var txtEdited: UILabel!
    @IBOutlet weak var txtTime: UILabel!
    @IBOutlet weak var txtReplyDisplayName: UILabel!
    @IBOutlet weak var txtReplyMessage: UILabel!
    @IBOutlet weak var txtForward: UILabel!
    
    @IBOutlet weak var imgStatus: UIImageView!
    
    @IBOutlet weak var txtMessageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainBubbleViewWidth: NSLayoutConstraint!
    @IBOutlet weak var forwardHeight: NSLayoutConstraint!
    
    @IBOutlet weak var avatarView: IGAvatarView!
    @IBOutlet weak var txtMessage: ActiveLabel!
    
    class func nib() -> UINib {
        return UINib(nibName: "TextCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    
    override func setMessage(_ message: IGRoomMessage, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: RoomMessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        initializeView()
        super.setMessage(message, isIncommingMessage: isIncommingMessage, shouldShowAvatar: shouldShowAvatar, messageSizes: messageSizes, isPreviousMessageFromSameSender: isPreviousMessageFromSameSender, isNextMessageFromSameSender: isNextMessageFromSameSender)
    }
    
    private func initializeView(){
        
        /********** view **********/
        mainBubbleViewAbs = mainBubbleView
        mainBubbleViewWidthAbs = mainBubbleViewWidth
        forwardViewAbs = forwardView
        replyLineViewAbs = replyLineView
        avatarViewAbs = avatarView
        avatarBackViewAbs = avatarBackView
        messageViewAbs = messageView
        replyViewAbs = replyView
        
        /********** lable **********/
        txtMessageAbs = txtMessage
        txtTimeAbs = txtTime
        txtEditedAbs = txtEdited
        txtReplyDisplayNameAbs = txtReplyDisplayName
        txtReplyMessageAbs = txtReplyMessage
        txtForwardAbs = txtForward
        
        /********** image **********/
        imgStatusAbs = imgStatus
        
        /******** constraint ********/
        txtMessageHeightConstraintAbs = txtMessageHeightConstraint
        forwardHeightAbs = forwardHeight
    }
}


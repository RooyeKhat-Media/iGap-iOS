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

class AudioCell: AbstractCell {
    
    @IBOutlet var mainBubbleView: UIView!
    @IBOutlet weak var messageView: UIView!
    
    @IBOutlet weak var txtMessageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainBubbleViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var txtMessage: ActiveLabel!
    
    var imgAudioPosition: Constraint!
    
    var txtAudioName: UILabel!
    var txtAudioArtist: UILabel!
    var txtAudioTime: UILabel!
    var sliderAudio: UISlider!
    
    class func nib() -> UINib {
        return UINib(nibName: "AudioCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    
    override func setMessage(_ message: IGRoomMessage, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: RoomMessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        initializeView()
        makeAudioView()
        super.setMessage(message, isIncommingMessage: isIncommingMessage, shouldShowAvatar: shouldShowAvatar, messageSizes: messageSizes, isPreviousMessageFromSameSender: isPreviousMessageFromSameSender, isNextMessageFromSameSender: isNextMessageFromSameSender)
        manageAudioViewPosition()
        setAudio()
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
    private func makeAudioView(){
        if imgFileAbs == nil {
            imgFileAbs = UIImageView()
            mainBubbleViewAbs.addSubview(imgFileAbs)
        }
        
        if indicatorViewAbs == nil {
            indicatorViewAbs = IGDownloadUploadIndicatorView()
            mainBubbleViewAbs.addSubview(indicatorViewAbs)
        }
        
        if txtAudioName == nil {
            txtAudioName = UILabel()
            txtAudioName.font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightMedium)
            txtAudioName.numberOfLines = 1
            mainBubbleViewAbs.addSubview(txtAudioName)
        }
        
        if txtAudioArtist == nil {
            txtAudioArtist = UILabel()
            txtAudioArtist.font = UIFont.systemFont(ofSize: 11.0, weight: UIFontWeightMedium)
            txtAudioArtist.numberOfLines = 0
            mainBubbleViewAbs.addSubview(txtAudioArtist)
        }
        
        if sliderAudio == nil {
            sliderAudio = UISlider()
            mainBubbleViewAbs.addSubview(sliderAudio)
        }
        
        if txtAudioTime == nil {
            txtAudioTime = UILabel()
            txtAudioTime.font = UIFont.systemFont(ofSize: 10.0, weight: UIFontWeightRegular)
            txtAudioTime.numberOfLines = 1
            mainBubbleViewAbs.addSubview(txtAudioTime)
        }
    }
    
    private func manageAudioViewPosition(){
        imgFileAbs.snp.makeConstraints { (make) in
            
            if imgAudioPosition != nil { imgAudioPosition.deactivate() }
            
            if isForward {
                imgAudioPosition = make.top.equalTo(forwardViewAbs.snp.bottom).offset(8.0).constraint
            } else if isReply {
                imgAudioPosition = make.top.equalTo(replyViewAbs.snp.bottom).offset(8.0).constraint
            } else {
                imgAudioPosition = make.top.equalTo(mainBubbleViewAbs.snp.top).offset(8.0).constraint
            }
            
            if imgAudioPosition != nil { imgAudioPosition.activate() }
            
            make.leading.equalTo(mainBubbleView.snp.leading).offset(8.0)
            make.width.equalTo(63.0)
            make.height.equalTo(63.0)
        }
        
        indicatorViewAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(imgFileAbs.snp.leading)
            make.trailing.equalTo(imgFileAbs.snp.trailing)
            make.top.equalTo(imgFileAbs.snp.top)
            make.bottom.equalTo(imgFileAbs.snp.bottom)
        }
        
        txtAudioName.snp.makeConstraints { (make) in
            make.leading.equalTo(imgFileAbs.snp.trailing).offset(10.0)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-10.0)
            make.top.equalTo(imgFileAbs.snp.top)
        }
        
        txtAudioArtist.snp.makeConstraints { (make) in
            make.leading.equalTo(imgFileAbs.snp.trailing).offset(10.0)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-10.0)
            make.top.equalTo(txtAudioName.snp.bottom).offset(2.0)
        }
        
        sliderAudio.snp.makeConstraints { (make) in
            make.leading.equalTo(imgFileAbs.snp.trailing).offset(10.0)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-10.0)
            make.bottom.equalTo(txtAudioTime.snp.top).offset(-2.0)
        }
        
        txtAudioTime.snp.makeConstraints { (make) in
            make.leading.equalTo(imgFileAbs.snp.trailing).offset(10.0)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-10.0)
            make.bottom.equalTo(imgFileAbs.snp.bottom)
        }
    }
    
    private func setAudio(){
        
        let attachment: IGFile! = finalRoomMessage.attachment
        if isIncommingMessage {
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .normal)
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .focused)
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .selected)
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .highlighted)
        } else {
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .normal)
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .focused)
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .selected)
            sliderAudio.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .highlighted)
        }
        
        if self.attachment?.status != .ready {
            indicatorViewAbs.layer.cornerRadius = 16.0
            indicatorViewAbs.layer.masksToBounds = true
            indicatorViewAbs.size = attachment.sizeToString()
            indicatorViewAbs.delegate = self
        }
        
        txtAudioName.text = attachment.name
        txtAudioArtist.text = "artist"
        sliderAudio.setValue(0.0, animated: false)
        imgFileAbs.setThumbnail(for: attachment)
        imgFileAbs.layer.cornerRadius = 16.0
        imgFileAbs.layer.masksToBounds = true
        
        let timeM = Int(attachment.duration / 60)
        let timeS = Int(attachment.duration.truncatingRemainder(dividingBy: 60.0))
        txtAudioTime.text = "0:00 / \(timeM):\(timeS)"
    }
}





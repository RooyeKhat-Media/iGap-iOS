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

class VoiceCell: AbstractCell {
    
    @IBOutlet var mainBubbleView: UIView!
    @IBOutlet weak var mainBubbleViewWidth: NSLayoutConstraint!
    
    var txtVoiceRecorderName: UILabel!
    var txtVoiceTime: UILabel!
    var imgPlay: UIButton!
    var sliderVoice: UISlider!
    
    var imgFilePosition: Constraint!
    
    class func nib() -> UINib {
        return UINib(nibName: "VoiceCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    override func setMessage(_ message: IGRoomMessage, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: RoomMessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        initializeView()
        makeVoiceView()
        super.setMessage(message, isIncommingMessage: isIncommingMessage, shouldShowAvatar: shouldShowAvatar, messageSizes: messageSizes, isPreviousMessageFromSameSender: isPreviousMessageFromSameSender, isNextMessageFromSameSender: isNextMessageFromSameSender)
        manageVoiceViewPosition()
        setVoice()
    }
    
    private func initializeView(){
        /********** view **********/
        mainBubbleViewAbs = mainBubbleView
        mainBubbleViewWidthAbs = mainBubbleViewWidth
    }
    
    private func makeVoiceView(){
        if imgFileAbs == nil {
            imgFileAbs = UIImageView()
            mainBubbleViewAbs.addSubview(imgFileAbs)
        }
        
        if indicatorViewAbs == nil {
            indicatorViewAbs = IGDownloadUploadIndicatorView()
            mainBubbleViewAbs.addSubview(indicatorViewAbs)
        }
        
        if txtVoiceRecorderName == nil {
            txtVoiceRecorderName = UILabel()
            txtVoiceRecorderName.font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightMedium)
            txtVoiceRecorderName.numberOfLines = 1
            mainBubbleViewAbs.addSubview(txtVoiceRecorderName)
        }
        
        if txtVoiceTime == nil {
            txtVoiceTime = UILabel()
            txtVoiceTime.font = UIFont.systemFont(ofSize: 10.0, weight: UIFontWeightRegular)
            txtVoiceTime.numberOfLines = 1
            mainBubbleViewAbs.addSubview(txtVoiceTime)
        }
        
        if imgPlay == nil {
            imgPlay = UIButton()
            mainBubbleViewAbs.addSubview(imgPlay)
        }
        
        if sliderVoice == nil {
            sliderVoice = UISlider()
            mainBubbleViewAbs.addSubview(sliderVoice)
        }
    }
    
    private func manageVoiceViewPosition(){
        imgFileAbs.snp.makeConstraints { (make) in
            
            if imgFilePosition != nil { imgFilePosition.deactivate() }
            
            if isForward {
                imgFilePosition = make.top.equalTo(forwardViewAbs.snp.bottom).offset(15.0).constraint
            } else if isReply {
                imgFilePosition = make.top.equalTo(replyViewAbs.snp.bottom).offset(15.0).constraint
            } else {
                imgFilePosition = make.centerY.equalTo(mainBubbleViewAbs.snp.centerY).constraint
            }
            
            if imgFilePosition != nil { imgFilePosition.activate() }
            
            make.leading.equalTo(mainBubbleViewAbs.snp.leading).offset(8)
            make.height.equalTo(36.0)
            make.width.equalTo(36.0)
        }
        
        indicatorViewAbs.snp.makeConstraints { (make) in
            make.leading.equalTo(imgFileAbs.snp.leading)
            make.trailing.equalTo(imgFileAbs.snp.trailing)
            make.top.equalTo(imgFileAbs.snp.top)
            make.bottom.equalTo(imgFileAbs.snp.bottom)
        }
        
        txtVoiceRecorderName.snp.makeConstraints { (make) in
            make.bottom.equalTo(imgPlay.snp.top).offset(-2.0)
            make.leading.equalTo(imgFileAbs.snp.trailing).offset(8.0)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-8.0)
        }
        
        txtVoiceTime.snp.makeConstraints { (make) in
            make.top.equalTo(imgPlay.snp.bottom).offset(2.0)
            make.leading.equalTo(imgFileAbs.snp.trailing).offset(8.0)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-8.0)
        }
        
        imgPlay.snp.makeConstraints { (make) in
            make.leading.equalTo(imgFileAbs.snp.trailing).offset(8.0)
            make.centerY.equalTo(imgFileAbs.snp.centerY)
            make.height.equalTo(15.0)
            make.width.equalTo(15.0)
        }
        
        sliderVoice.snp.makeConstraints { (make) in
            make.leading.equalTo(imgPlay.snp.trailing).offset(4.0)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-8.0)
            make.centerY.equalTo(imgPlay.snp.centerY)
        }
    }
    
    private func setVoice(){
        
        let attachment: IGFile! = finalRoomMessage.attachment
        if finalRoomMessage.authorUser != nil {
            txtVoiceRecorderName.text = "Recorded by \(finalRoomMessage.authorUser!.displayName)"
        } else if finalRoomMessage.authorRoom != nil {
            txtVoiceRecorderName.text = "Recorded voice"
        }
        
        if isIncommingMessage {
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .normal)
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .focused)
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .selected)
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb"), for: .highlighted)
            sliderVoice.minimumTrackTintColor = UIColor.organizationalColor()
            sliderVoice.maximumTrackTintColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
            imgPlay.setImage(UIImage(named:"IG_Message_Cell_Player_Voice_Play"), for: .normal)
        } else {
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .normal)
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .focused)
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .selected)
            sliderVoice.setThumbImage(UIImage(named: "IG_Message_Cell_Player_Slider_Thumb_Outgoing"), for: .highlighted)
            sliderVoice.minimumTrackTintColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
            sliderVoice.maximumTrackTintColor = UIColor(red: 22.0/255.0, green: 91.0/255.0, blue: 88.0/255.0, alpha: 1.0)
            imgPlay.setImage(UIImage(named:"IG_Message_Cell_Player_Voice_Play"), for: .normal)
        }
        
        if self.attachment?.status != .ready {
            indicatorViewAbs.layer.cornerRadius = 16.0
            indicatorViewAbs.layer.masksToBounds = true
            indicatorViewAbs.size = attachment.sizeToString()
            indicatorViewAbs.delegate = self
        }
        
        imgFileAbs.setThumbnail(for: attachment)
        sliderVoice.setValue(0.0, animated: false)
        let timeM = Int(attachment.duration / 60)
        let timeS = Int(attachment.duration.truncatingRemainder(dividingBy: 60.0))
        txtVoiceTime.text = "0:00 / \(timeM):\(timeS)"
    }
}



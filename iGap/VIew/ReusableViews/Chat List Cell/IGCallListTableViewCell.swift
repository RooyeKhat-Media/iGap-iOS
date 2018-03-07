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
import SwiftProtobuf
import RealmSwift

class IGCallListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarView: IGAvatarView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var offerTime: UILabel!
    @IBOutlet weak var callState: UILabel!
    @IBOutlet weak var callStateView: UILabel!
    
    class func nib() -> UINib {
        return UINib(nibName: "IGCallListTableViewCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.initialConfiguration()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.initialConfiguration()
    }
    
    
    func initialConfiguration() {
        self.selectionStyle = .none
    }
    
    func setCallLog(callLog: IGRealmCallLog) {
        
        let user = callLog.registeredUser
        
        if let test = callLog.registeredUser {
            avatarView.setUser(test)
        }
        
        contactName.text = user?.displayName
        offerTime.text = callLog.offerTime.completeHumanReadableTime()
        
        setState(callLog: callLog)
    }
    
    private func setState(callLog: IGRealmCallLog){
        switch callLog.status {
            
        case 0: //MISSED
            callStateView.text = ""
            callState.text = "Missed Call"
            
            callStateView.textColor = UIColor.callStatusColor(status: 0)
            callState.textColor = UIColor.callStatusColor(status: 0)
            break
            
        case 1: //CANCELED
            callStateView.text = ""
            callState.text = "Unanswerd Call"
            
            callStateView.textColor = UIColor.callStatusColor(status: 1)
            callState.textColor = UIColor.callStatusColor(status: 1)
            break
            
        case 2: //INCOMING
            callStateView.text = ""
            callState.text = convertDurationToHour(duration: callLog.duration)
            
            callStateView.textColor = UIColor.callStatusColor(status: 2)
            callState.textColor = UIColor.callStatusColor(status: 2)
            break
            
        case 3: //OUTGOING
            callStateView.text = ""
            callState.text = convertDurationToHour(duration: callLog.duration)
            
            callStateView.textColor = UIColor.callStatusColor(status: 3)
            callState.textColor = UIColor.callStatusColor(status: 3)
            break
            
        default:
            break
        }
    }
    
    private func convertDurationToHour(duration: Int32) -> String{
        let minute = String(format: "%02d", Int(duration / 60))
        let seconds = String(format: "%02d", Int(duration % 60))
        return minute+":"+seconds
    }
}










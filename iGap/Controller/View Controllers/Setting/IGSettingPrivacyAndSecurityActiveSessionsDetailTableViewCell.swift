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

class IGSettingPrivacyAndSecurityActiveSessionsDetailTableViewCell: UITableViewCell {
    let greenColor = UIColor.organizationalColor()
    
    @IBOutlet weak var activeSessionImageView: UIImageView!
    @IBOutlet weak var activeSessionTitle: UILabel!
    @IBOutlet weak var activeSessionLastseenLable: UILabel!
    @IBOutlet weak var activesessionCountryLable: UILabel!
    var items : [IGSession]?{
        didSet{
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        activeSessionLastseenLable.textColor = greenColor
    }

    func setSession(_ session: IGSession) {
        switch session.platform! {
        case .android :
            activeSessionTitle.text = "Android"
            activeSessionImageView.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Android")
        case .iOS :
            activeSessionTitle.text = "iOS"
            activeSessionImageView.image = UIImage(named:"IG_Settings_Active_Sessions_Device_iPhone")
        case .macOS :
            activeSessionTitle.text = "macOS"
            activeSessionImageView.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Mac")
        case .windows :
            activeSessionTitle.text = "windows"
            activeSessionImageView.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Windows")
        case .linux :
            activeSessionTitle.text = "linux"
            activeSessionImageView.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Linux")
        case .blackberry :
            activeSessionTitle.text = "blackberry"
        default:
            break
        }
        
        let lastActiveDateString = Date(timeIntervalSince1970: TimeInterval(session.activeTime)).completeHumanReadableTime()
        activeSessionLastseenLable.text = "Last active at: " + lastActiveDateString
        activesessionCountryLable.text = session.country
        
    }
}

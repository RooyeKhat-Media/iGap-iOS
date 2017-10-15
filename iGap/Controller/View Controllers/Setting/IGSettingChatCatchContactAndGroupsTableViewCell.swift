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

class IGSettingChatCatchContactAndGroupsTableViewCell: UITableViewCell {

    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactNameLable: UILabel!
    @IBOutlet weak var sizeOfCatchMediaFileLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        roundUserImage()
        // Initialization code
    }
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func roundUserImage(){
        contactImageView.layer.borderWidth = 0
        contactImageView.layer.masksToBounds = true
        let borderUserImageColor = UIColor.organizationalColor()
        contactImageView.layer.borderColor = borderUserImageColor.cgColor
        contactImageView.layer.cornerRadius = contactImageView.frame.size.height/2
        contactImageView.clipsToBounds = true
    }


}

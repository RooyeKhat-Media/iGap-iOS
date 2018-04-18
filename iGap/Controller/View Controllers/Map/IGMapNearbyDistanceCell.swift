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

class IGMapNearbyDistanceCell: UITableViewCell {
    
    @IBOutlet weak var avatarView: IGAvatarView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var userComment: UILabel!
    @IBOutlet weak var userDistance: UILabel!
    
    class func nib() -> UINib {
        return UINib(nibName: "IGMapNearbyDistanceCell", bundle: Bundle(for: self))
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
    
    func setUserInfo(nearbyDistance : IGRealmMapNearbyDistance) {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", nearbyDistance.id)
        if let userInfo = try! realm.objects(IGRegisteredUser.self).filter(predicate).first {
            avatarView.setUser(userInfo)
            contactName.text = userInfo.displayName
            if nearbyDistance.hasComment {
                userComment.text = nearbyDistance.comment
            } else {
                userComment.text = "No Status"
            }
            userDistance.text = "about \(nearbyDistance.distance) m"
        }
    }
}










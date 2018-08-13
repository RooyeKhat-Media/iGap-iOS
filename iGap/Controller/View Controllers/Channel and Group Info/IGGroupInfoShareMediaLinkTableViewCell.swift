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
import MBProgressHUD
import IGProtoBuff

class IGGroupInfoShareMediaLinkTableViewCell: UITableViewCell {
    
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var linkDescriptionLabel: UILabel!
    @IBOutlet weak var linkTitleLabel: ActiveLabel!
    
    var hud = MBProgressHUD()
    var urlClickDelegate : IGUrlClickDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setLinkDetails(message: IGRoomMessage) {
        
        if let creationtime = message.creationTime {
            creationDateLabel.text = "\(creationtime.completeHumanReadableTime())"
            linkDescriptionLabel.text = message.message
        }
        
        var input = message.message
        
        if !(input?.hasPrefix("http://"))! && !(input?.hasPrefix("https://"))! {
            input = "http://" + input!
        }
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: input!, options: [], range: NSRange(location: 0, length: (input?.utf16.count)!))
        
        for match in matches {
            var url = (input! as NSString).substring(with: match.range)
            if !(url.hasPrefix("http://")) && !(url.hasPrefix("https://")) {
                url = "http://" + url
            }
            linkTitleLabel.text = url
        }
        
        linkManager(txtMessage: linkTitleLabel)
    }
    
    private func linkManager(txtMessage: ActiveLabel?){
        txtMessage?.customize { (label) in
            let customInvitedLink = ActiveType.custom(pattern: "((?:http|https)://)?[iGap\\.net]+(\\.\\w{0})?(/(?<=/)(?:[\\join./]+[a-zA-Z0-9]{2,}))") //look for iGap.net/join/
            label.enabledTypes.append(customInvitedLink)
            label.hashtagColor = UIColor.organizationalColor()
            label.mentionColor = UIColor.organizationalColor()
            label.URLColor = UIColor.organizationalColor()
            label.customColor[customInvitedLink] = UIColor.organizationalColor()
            
            label.handleURLTap { url in
                self.urlClickDelegate?.didTapOnURl(url: url)
            }
            
            label.handleCustomTap(for:customInvitedLink) {
                self.urlClickDelegate?.didTapOnRoomLink(link: $0)
            }
        }
    }
}

extension NSRange {
    func range(for str: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }
        
        guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
        guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
        guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
        guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }
        
        return fromIndex ..< toIndex
    }
}

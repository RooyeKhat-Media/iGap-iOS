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

class IGGroupInfoShareMediaLinkTableViewCell: UITableViewCell {
    @IBOutlet weak var linkImageView: UIImageView!

    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var linkAddressLabel: UILabel!
    @IBOutlet weak var linkDescriptionLabel: UILabel!
    @IBOutlet weak var linkTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setLinkDetails(message: IGRoomMessage) {
        linkAddressLabel.text = message.message
        if let creationtime = message.creationTime {
            creationDateLabel.text = "\(creationtime)"
            linkDescriptionLabel.text = message.message
            
        }
        let input = message.message
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: input!, options: [], range: NSRange(location: 0, length: (input?.utf16.count)!))
        
        for match in matches {
            let url = (input! as NSString).substring(with: match.range)
            print(url)
            linkTitleLabel.text = url
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

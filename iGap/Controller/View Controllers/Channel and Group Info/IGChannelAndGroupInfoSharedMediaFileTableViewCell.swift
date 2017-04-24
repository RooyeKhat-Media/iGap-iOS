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

class IGChannelAndGroupInfoSharedMediaFileTableViewCell: UITableViewCell {

    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setFileDetails(attachment: IGFile , messsage: IGRoomMessage) {
        let fileImage = UIImage(named: "IG_Message_Cell_File_Generic")
        fileImageView.image = fileImage
        if let creationDate = messsage.creationTime {
            creationDateLabel.text = "\(creationDate)"
        }
        let sizeInByte = attachment.size
        var sizeSting = ""
        if sizeInByte < 1024 {
            //byte
            sizeSting = "\(sizeInByte) B"
        } else if sizeInByte < 1048576 {
            //kilobytes
            sizeSting = "\(sizeInByte/1024) KB"
        } else if sizeInByte < 1073741824 {
            //megabytes
            sizeSting = "\(sizeInByte/1048576) MB"
        } else { //if sizeInByte < 1099511627776 {
            //gigabytes
            sizeSting = "\(sizeInByte/1073741824) GB"
        }
        self.fileSizeLabel.text = sizeSting
        fileImageView.setThumbnail(for: attachment)
        fileNameLabel.text = attachment.name
        
            switch attachment.fileTypeBasedOnNameExtension {
        case .docx:
            self.fileImageView.image = UIImage(named: "IG_Message_Cell_File_Doc")
        default:
            self.fileImageView.image = UIImage(named: "IG_Message_Cell_File_Generic")
        }

        
    }

}

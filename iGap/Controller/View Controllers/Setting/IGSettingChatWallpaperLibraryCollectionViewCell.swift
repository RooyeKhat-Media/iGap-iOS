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

class IGSettingChatWallpaperLibraryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var backGroundimageView: UIImageView!
    
    public func loadImage(file: IGFile){
        backGroundimageView.setThumbnail(for: file)
    }
}

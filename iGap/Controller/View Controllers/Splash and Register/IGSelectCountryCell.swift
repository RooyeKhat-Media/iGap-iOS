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
import IGProtoBuff

class IGSelectCountryCell: UITableViewCell {

    @IBOutlet weak var txtCountry: UILabel!
    @IBOutlet weak var txtCountryCode: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setSearchResult(country: IGCountry) {
        txtCountry.text = country.localizedName
        txtCountryCode.text = country.phoneCode
    }
}

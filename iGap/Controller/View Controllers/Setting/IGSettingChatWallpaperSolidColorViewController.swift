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

class IGSettingChatWallpaperSolidColorViewController: UIViewController {

  
    var selectedColor: UIColor = UIColor.white
    
    // Setup
   // @IBOutlet var colorPicker: SwiftHSVColorPicker!
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "backToChatWallPaperMainList", sender: self)
   
      }
    @IBAction func ChooseButtonClicked(_ sender: UIButton) {
        // Get the selected color from the Color Picker.
       // let selectedColor = colorPicker.color
        
       // print(selectedColor! as UIColor)
        
      }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination as? IGSettingChatWallpaperTableViewController
        
        
    }
    


}

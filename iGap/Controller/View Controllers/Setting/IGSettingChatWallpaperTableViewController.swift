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

class IGSettingChatWallpaperTableViewController: UITableViewController,UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows : Int = 0
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            numberOfRows = 3
        }
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "GoToWallpaperLibraryPage", sender: self)
            case 1:
                GoToPhotoLibrary()
            case 2:
                performSegue(withIdentifier: "GoToSolidColorPage", sender: self)
            default:
                break
            }
        }
    }
        func GoToPhotoLibrary(){
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        self.imagePicker.sourceType = .photoLibrary
         self.present(self.imagePicker, animated: true, completion: nil)
        }
    
    @IBAction func goBackToAccountMainTable(seque:UIStoryboardSegue){
    }
 }

extension IGSettingChatWallpaperTableViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if imagePicker.sourceType == .photoLibrary {
            if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            }
        }
        imagePicker.dismiss(animated: true, completion: {
            // Anything you want to happen when the user saves an image
        })
    }
}

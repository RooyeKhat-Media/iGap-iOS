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
import RealmSwift

class IGSettingChatWallpaperTableViewController: UITableViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate{
    
    var imagePicker = UIImagePickerController()
    var isColorPage: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    }
    
    func initNavigationBar() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Chat Wallpaper")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
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
            case 0: // show wallpaper
                isColorPage = false
                performSegue(withIdentifier: "showWallpaperListPage", sender: self)
            case 1: // show solid color
                isColorPage = true
                performSegue(withIdentifier: "showWallpaperListPage", sender: self)
            case 2:
                let realm = try! Realm()
                let wallpaper = realm.objects(IGRealmWallpaper.self)
                try! realm.write {
                    realm.delete(wallpaper)
                }
                //GoToPhotoLibrary()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWallpaperListPage" {
            let wallpaperList = segue.destination as! IGSettingChatWallpaperLibraryCollectionViewController
            wallpaperList.isColorPage = self.isColorPage
        }
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

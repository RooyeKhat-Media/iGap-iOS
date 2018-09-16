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
import RealmSwift


private let reuseIdentifier = "WallpaperLibraryCell"
private let sectionInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
private let itemsPerRow: CGFloat = 3

class IGSettingChatWallpaperLibraryCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate {

    var libraryImageName : [IGFile] = []
    var librarySolidColor: [String] = []
    var wallpaperFile : IGFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
        let wallpapers = try! Realm().objects(IGRealmWallpaper.self).first
        
        if wallpapers != nil && (wallpapers?.file.count)! > 0 {
            
            for wallpaper in (wallpapers?.file)! {
                libraryImageName.append(wallpaper)
            }
            
            for solidColor in (wallpapers?.color)! {
                librarySolidColor.append(solidColor.innerString)
            }
            
        } else { // if not exist wallpapers in local get from server
            
            IGInfoWallpaperRequest.Generator.generate(fit: IGPInfoWallpaper.IGPFit.phone).success({ (protoResponse) in
                
                if let wallpaperResponse = protoResponse as? IGPInfoWallpaperResponse {
                    IGInfoWallpaperRequest.Handler.interpret(response: wallpaperResponse)
                    
                    if let wallpapers = try! Realm().objects(IGRealmWallpaper.self).first {
                        for wallpaper in wallpapers.file {
                            self.libraryImageName.append(wallpaper)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
                
            }).error({ (error, waitTime) in
                
            }).send()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Wallpaper")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        return libraryImageName.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,for: indexPath as IndexPath) as! IGSettingChatWallpaperLibraryCollectionViewCell
        cell.backGroundimageView.backgroundColor = UIColor.hexStringToUIColor(hex: librarySolidColor[indexPath.row])
        cell.loadImage(file: libraryImageName[indexPath.row])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        wallpaperFile = libraryImageName[indexPath.row]
        performSegue(withIdentifier: "showWallpaperPreview", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = view.frame.width
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
        func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWallpaperPreview" {
            let wallpaperPreview = segue.destination as! IGWallpaperPreview
            wallpaperPreview.wallpaperFile = wallpaperFile
        }
    }
}

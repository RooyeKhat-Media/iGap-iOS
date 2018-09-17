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
    var wallpaperFile : IGFile?
    var colorHex : String?
    var isColorPage: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
        let wallpapers = try! Realm().objects(IGRealmWallpaper.self).first
        
        if wallpapers != nil && ((wallpapers?.file.count)! > 0 || (wallpapers?.color.count)! > 0) {
            
            if isColorPage {
                for solidColor in (wallpapers?.color)! {
                    librarySolidColor.append(solidColor.innerString)
                }
            } else {
                for wallpaper in (wallpapers?.file)! {
                    libraryImageName.append(wallpaper)
                }
            }
            
        } else { // if not exist wallpapers in local get from server
            
            IGGlobal.prgShow(self.view)
            IGInfoWallpaperRequest.Generator.generate(fit: IGPInfoWallpaper.IGPFit.phone).success({ (protoResponse) in
                if let wallpaperResponse = protoResponse as? IGPInfoWallpaperResponse {
                    IGInfoWallpaperRequest.Handler.interpret(response: wallpaperResponse)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        IGGlobal.prgHide()
                        if let wallpapers = try! Realm().objects(IGRealmWallpaper.self).first {
                            
                            if self.isColorPage {
                                for solidColor in wallpapers.color {
                                    self.librarySolidColor.append(solidColor.innerString)
                                }
                            } else {
                                for wallpaper in wallpapers.file {
                                    self.libraryImageName.append(wallpaper)
                                }
                            }
                        }
                        
                        self.collectionView?.reloadData()
                    }
                }
                
            }).error({ (error, waitTime) in
                IGGlobal.prgHide()
            }).send()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func initNavigationBar() {
        
        var title = "Wallpapers"
        if isColorPage {
            title = "Solid Colors"
        }
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: title)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        if isColorPage {
            return librarySolidColor.count
        } else {
            return libraryImageName.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,for: indexPath as IndexPath) as! IGSettingChatWallpaperLibraryCollectionViewCell
        if isColorPage {
            cell.backGroundimageView.backgroundColor = UIColor.hexStringToUIColor(hex: librarySolidColor[indexPath.row])
        } else {
            cell.loadImage(file: libraryImageName[indexPath.row])
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isColorPage {
            colorHex = librarySolidColor[indexPath.row]
            performSegue(withIdentifier: "showWallpaperPreview", sender: self)
        } else {
            wallpaperFile = libraryImageName[indexPath.row]
            performSegue(withIdentifier: "showWallpaperPreview", sender: self)
        }
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
            if isColorPage {
                wallpaperPreview.colorHex = self.colorHex
            } else {
                wallpaperPreview.wallpaperFile = wallpaperFile
            }
        }
    }
}

extension IGSettingChatWallpaperLibraryCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthPerItem = (view.frame.width / itemsPerRow) - 15
        if isColorPage {
            return CGSize(width: widthPerItem, height: widthPerItem)
        } else {
            return CGSize(width: widthPerItem, height: widthPerItem + 80)
        }
    }
}

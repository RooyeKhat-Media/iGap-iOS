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
    
    private var localColorHexList : [String] =
        ["#2962ff","#00b8d4",
         "#b71c1c","#e53935","#e57373",
         "#880e4f","#d81b60","#f06292",
         "#4a148c","#8e24aa","#ba68c8",
         "#311b92","#5e35b1","#9575cd",
         "#1a237e","#3949ab","#7986cb",
         "#0d47a1","#1e88e5","#64b5f6",
         "#01579b","#039be5","#4fc3f7",
         "#006064","#00acc1","#4dd0e1",
         "#004d40","#00897b","#4db6ac",
         "#1b5e20","#43a047","#81c784",
         "#33691e","#7cb342","#aed581",
         "#827717","#c0ca33","#dce775",
         "#f57f17","#fdd835","#fff176",
         "#ff6f00","#ffb300","#ffd54f",
         "#e65100","#fb8c00","#fb8c00",
         "#bf360c","#f4511e","#ff8a65",
         "#3e2723","#6d4c41","#a1887f",
         "#212121","#757575","#e0e0e0",
         "#263238","#546e7a","#90a4ae"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
        let wallpapers = try! Realm().objects(IGRealmWallpaper.self).first
        
        if wallpapers != nil && ((wallpapers?.file.count)! > 0 || (wallpapers?.color.count)! > 0) {
            
            if isColorPage {
                librarySolidColor.append("#ffffff")
                for solidColor in (wallpapers?.color)! {
                    librarySolidColor.append(solidColor.innerString)
                }
                librarySolidColor.removeLast()
                appendLocalColors()
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
                                self.librarySolidColor.append("#ffffff")
                                for solidColor in wallpapers.color {
                                    self.librarySolidColor.append(solidColor.innerString)
                                }
                                self.librarySolidColor.removeLast()
                                self.appendLocalColors()
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
    
    private func appendLocalColors(){
        for color in localColorHexList {
            librarySolidColor.append(color)
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
            return CGSize(width: widthPerItem, height: (widthPerItem * 1.6))
        }
    }
}

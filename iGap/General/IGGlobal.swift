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
import SwiftProtobuf

let kIGUserLoggedInNotificationName = "im.igap.ios.user.logged.in"
let kIGNotificationNameDidCreateARoom = "im.igap.ios.room.created"
let kIGNoticationForPushUserExpire = "im.igap.ios.user.expire"

let IGNotificationStatusBarTapped         = Notification(name: Notification.Name(rawValue: "im.igap.statusbarTapped"))
let IGNotificationPushLoginToken          = Notification(name: Notification.Name(rawValue: "im.igap.ios.user.push.token"))
let IGNotificationPushTwoStepVerification = Notification(name: Notification.Name(rawValue: "im.igap.ios.user.push.two.step"))


class IGGlobal {
    //MARK: RegEx
    public class func matches(for regex: String, in text: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.count > 0
        } catch {
            return false
        }
    }
    
    //MARK: Random String
    public class func randomString(length : Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        for _ in 0..<length {
            let rand = Int(arc4random_uniform(UInt32(letters.characters.count)))
            randomString.append(letters[rand])
        }
        return randomString
    }
}

//MARK: -
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    //MARK: General Colors
    class func organizationalColor() -> UIColor {
        return UIColor(red:0/255.0, green:176.0/255.0, blue:191.0/255.0, alpha:1.0)
    }
    
    class func organizationalColorLight() -> UIColor {
        return UIColor(red:180.0/255.0, green:255.0/255.0, blue:255.0/255.0, alpha:1.0)
    }
    
    //MARK: MessageCVCell Bubble
    class func outgoingChatBuubleBackgroundColor() -> UIColor {
        return UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    }

    class func incommingChatBuubleBackgroundColor() -> UIColor {
        return UIColor.white
    }
    
    class func senderNameColor() -> UIColor {
        return UIColor(red: 0.0/255.0, green: 188.0/255.0, blue: 202.0/255.0, alpha: 1.0)
    }
    
    class func chatBubbleBackground(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor.incommingChatBuubleBackgroundColor()
        } else {
            return UIColor.outgoingChatBuubleBackgroundColor()
        }
    }
    
    class func chatBubbleTextColor(isIncommingMessage: Bool) -> UIColor {
        return UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
    }
    
    //MARK: MessageCVCell Time
    class func chatTimeTextColor(isIncommingMessage: Bool) -> UIColor {
        return UIColor(red: 105.0/255.0, green: 123.0/255.0, blue: 135.0/255.0, alpha: 1.0)
    }
    
    //MARK: MessageCVCell Forward
    class func chatForwardedFromViewBackgroundColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        } else {
            return UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 1.0)
        }
    }
    
    class func chatForwardedFromUsernameLabelColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor.organizationalColor()
        } else {
            return UIColor(red: 54.0/255.0, green: 54.0/255.0, blue: 54.0/255.0, alpha: 1.0)
        }
    }
    
    class func chatForwardedFromMediaContainerViewBackgroundColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        } else {
            return UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 1.0)
        }
    }
    
    class func chatForwardedFromBodyContainerViewBackgroundColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        } else {
            return UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 1.0)
        }
    }
    
    class func chatForwardedFromBodyLabelTextColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor.chatBubbleTextColor(isIncommingMessage: isIncommingMessage)
        } else {
            return UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0)
        }
    }

    
    //MARK: MessageCVCell Reply
    class func chatReplyToBackgroundColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        } else {
            return UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 1.0)
        }
    }
    
    class func chatReplyToIndicatorViewColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor.organizationalColor()
        } else {
            return UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0)
        }
    }
    
    class func chatReplyToUsernameLabelTextColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor.organizationalColor()
        } else {
            return UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0)
        }
    }
    
    class func chatReplyToMessageBodyLabelTextColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor(red: 54.0/255.0, green: 54.0/255.0, blue: 54.0/255.0, alpha: 1.0)
        } else {
            return UIColor.white
        }
    }
}

//MARK: -
extension Date {
    func convertToHumanReadable(onlyTimeIfToday: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        
        let calendar = NSCalendar.current
        if onlyTimeIfToday && !calendar.isDateInToday(self) {
            dateFormatter.dateFormat = "MMM, dd"
            return dateFormatter.string(from: self)
        }
        dateFormatter.dateFormat = "HH:mm"
        let hour = calendar.component(Calendar.Component.hour, from: self)
        let min = calendar.component(Calendar.Component.minute, from: self)
        return "\(String(format: "%02d", hour)):\(String(format: "%02d", min))"
    }
    
    func completeHumanReadableTime() -> String {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "dd MMM YYYY - HH:mm"
        let dateString = dayTimePeriodFormatter.string(from: self)
        return dateString
    }
    
    func humanReadableForLastSeen() -> String {
        let differenctToNow = Date().timeIntervalSince1970 - self.timeIntervalSince1970
        if differenctToNow < 10 {
            return "just now"
        } else if differenctToNow < 120 {
            return "in a minute"
        } else if differenctToNow < 3600 {
            let minutes = Int(differenctToNow / 60)
            return "\(minutes) minutes ago"
        } else if differenctToNow < 3600 * 2 {
            return "an hour ago"
        } else if differenctToNow < 3600 * 24 {
            let hours = Int(differenctToNow / 3600)
            return "\(hours) hours ago"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        let dateString = dateFormatter.string(from: self)
        dateFormatter.dateFormat = "h:mm a"
        let timeString = dateFormatter.string(from: self)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.humanReadableForLastSeen()
//        }

        return dateString + " at " + timeString
        
    }
}

//MARK: -
extension Data {
    func igSHA256() -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(self.count), &hash)
        }
        return Data(bytes: hash)
    }
}
//MARK: -
extension UIViewController {
    func setTabbarHidden(_ hide: Bool, animated: Bool) {
        if (self.isTabbarHidden() == hide ){
            return
        }
        // get a frame calculation ready
        let height = self.tabBarController?.tabBar.frame.size.height
        let offsetY = hide ? height! : -(height!)
        
        // zero duration means no animation
        let duration = animated ? 0.3 : 0.0
        
        UIView.animate(withDuration: duration, animations: {
            let frame = self.tabBarController?.tabBar.frame;
            self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY)
        }, completion: {completed in
            
        })
    }
    
    func isTabbarHidden() -> Bool {
        return (self.tabBarController?.tabBar.frame.origin.y)! >= self.view.frame.maxY
    }
    
    func showAlert(title: String, message: String, action: (()->())? = nil, completion: (() -> Swift.Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (alertAction) in
            if let action = action {
                action()
            }
        }
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: completion)
    }
}

//MARK: -
extension NSCache {
    subscript (key: AnyObject) -> AnyObject? {
        get {
            return (self as! NSCache<AnyObject,AnyObject>).object(forKey: key)
        }
        set {
            if let value: AnyObject = newValue {
                (self as! NSCache<AnyObject,AnyObject>).setObject(value, forKey: key)
            } else {
                (self as! NSCache<AnyObject,AnyObject>).removeObject(forKey: key)
            }
        }
    }
}

var imagesMap = [String : UIImageView]()

//MARK: -
extension UIImageView {
    func setThumbnail(for attachment:IGFile) {
        //NOTE: temporary commented due to performance problems
//        if let path = attachment.path() {
//            if FileManager.default.fileExists(atPath: path.path) {
//                if let image = UIImage(contentsOfFile: path.path) {
//                    self.image = image
//                    return
//                }
//            }
//        }
        if attachment.type == .voice {
              self.image = UIImage(named:"IG_Message_Cell_Voice")
        } else if attachment.type == .file {
            let filename: NSString = attachment.name! as NSString
            let fileExtension = filename.pathExtension
            
            if fileExtension != "" {
                if fileExtension == "doc" {
                    self.image = UIImage(named:"IG_Message_Cell_File_Doc")
                    
                } else if fileExtension == "exe" {
                    self.image = UIImage(named:"IG_Message_Cell_File_Exe")
                    
                } else if fileExtension == "pdf" {
                    self.image = UIImage(named:"IG_Message_Cell_File_Pdf")
                    
                } else if fileExtension == "txt" {
                    self.image = UIImage(named:"IG_Message_Cell_File_Txt")
                    
                } else {
                    self.image = UIImage(named:"IG_Message_Cell_File_Generic")
                }
                
            } else {
                self.image = UIImage(named:"IG_Message_Cell_File_Generic")
            }
            
        } else if attachment.type == .audio {
            self.image = UIImage(named:"IG_Message_Cell_Player_Default_Cover")
        } else {
            if let image = UIImage.originalImage(for: attachment) {
                self.image = image
            } else if let thumbnail = attachment.smallThumbnail {
                do {
                    var path = URL(string: "")
                    if attachment.attachedImage != nil {
                        self.image = attachment.attachedImage
                    } else {
                        var image: UIImage?
                        path = thumbnail.path()
                        if FileManager.default.fileExists(atPath: path!.path) {
                            image = UIImage(contentsOfFile: path!.path)
                        }
                        
                        if image != nil {
                            self.image = image
                        } else {
                            throw NSError(domain: "asa", code: 1234, userInfo: nil)
                        }
                    }
                } catch {
                    imagesMap[attachment.cacheID!] = self
                    IGDownloadManager.sharedManager.download(file: thumbnail, previewType:.smallThumbnail, completion: { (attachment) -> Void in
                        DispatchQueue.main.async {
                            if let image = imagesMap[attachment.cacheID!]{
                                image.setThumbnail(for: attachment)
                            }
                        }
                    }, failure: {
                        
                    })
                }
            } else {
                switch attachment.type {
                case .image:
                    self.image = nil
                    break
                case .gif:
                    break
                case .video:
                    break
                case .audio:
                    self.image = UIImage(named:"IG_Message_Cell_Player_Default_Cover")
                    break
                default:
                    break
                }
            }
        }
        
    }
    
    func setImage(for attachment:IGFile) {
        if attachment.attachedImage != nil {
            self.image = attachment.attachedImage
        } else {
            let path = attachment.path()
            let data = try! Data(contentsOf: path!)
            if let image = UIImage(data: data) {
                self.image = image
            }
        }
    }
    
    func setImage(avatar: IGAvatar) {
        if let smallThumbnail = avatar.file?.smallThumbnail {
            do {
                if smallThumbnail.attachedImage != nil {
                    self.image = smallThumbnail.attachedImage
                } else {
                    var image: UIImage?
                    let path = smallThumbnail.path()
                    if FileManager.default.fileExists(atPath: path!.path) {
                        image = UIImage(contentsOfFile: path!.path)
                    }
                    
                    if image != nil {
                        self.image = image
                    } else {
                        throw NSError(domain: "asa", code: 1234, userInfo: nil)
                    }
                }
            } catch {
                IGDownloadManager.sharedManager.download(file: smallThumbnail, previewType:.smallThumbnail, completion: { (attachment) -> Void in
                    DispatchQueue.main.async {
                        let path = smallThumbnail.path()
                        if let data = try? Data(contentsOf: path!) {
                            if let image = UIImage(data: data) {
                                self.image = image
                            }
                        }
                    }
                }, failure: {
                    
                })
            }
        }
        
    }
    
}

//MARK: -
extension UIImage {
    class func thumbnail(for attachment: IGFile) -> UIImage? {
        if let thumbnail = attachment.smallThumbnail {
            return self.originalImage(for: thumbnail)
        }
        return nil
    }
    
    class func originalImage(for attachment: IGFile) -> UIImage? {
        if let path = attachment.path() {
            if FileManager.default.fileExists(atPath: path.path) {
                if let image = UIImage(contentsOfFile: path.path) {
                    return image
                }
            }
        }
        if let attachedImage = attachment.attachedImage {
            return attachedImage
        } else {
            if let path = attachment.path() {
                do {
                    let data = try Data(contentsOf: path)
                    return UIImage(data: data)
                } catch  {
                    return nil
                }
            }
            
            return nil
        }
    }
}


//MARK: -
extension UIFont {
    
    enum FontWeight {
        case ultraLight
        case light
        case regular
        case medium
        case bold
    }
    
    class func igFont(ofSize fontSize: CGFloat, weight: FontWeight = .regular) -> UIFont {
        switch weight {
        case .ultraLight:
            return UIFont(name: "IRANSans-UltraLight", size: fontSize)!
        case .light:
            return UIFont(name: "IRANSans-Light", size: fontSize)!
        case .regular:
            return UIFont(name: "IRANSans", size: fontSize)!
        case .medium:
            return UIFont(name: "IRANSans-Medium", size: fontSize)!
        case .bold:
            return UIFont(name: "IRANSans-Bold", size: fontSize)!
        }
    }
    
//    func bold() -> UIFont {
//        return withTraits(traits: .traitBold)
//    }
    
//    func italic() -> UIFont {
//        return withTraits(traits: .traitItalic)
//    }
    
//    func withTraits(traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
//        
//        if let result = CTFontCreateCopyWithSymbolicTraits(self as CTFont, 0, nil, .traitItalic, .traitItalic) {
//            return result as UIFont
//        }
//        
//        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))!
//        return UIFont(descriptor: descriptor, size: 0)
//    }
}

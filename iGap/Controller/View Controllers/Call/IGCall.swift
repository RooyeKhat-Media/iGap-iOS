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
import AVFoundation
import IGProtoBuff
import SnapKit

class IGCall: UIViewController, CallStateObserver, ReturnToCallObserver {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var viewTransparent: UIView!
    @IBOutlet weak var txtiGap: UILabel!
    @IBOutlet weak var txtCallerName: UILabel!
    @IBOutlet weak var txtCallState: UILabel!
    @IBOutlet weak var txtCallTime: UILabel!
    @IBOutlet weak var btnAnswer: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnMute: UIButton!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var btnSpeaker: UIButton!
    
    var userId: Int64!
    var userInfo: IGRegisteredUser!
    var room: IGRoom!
    var isIncommingCall: Bool!
    var isSpeakerEnable = false
    var isMuteEnable = false
    var callIsConnected = false
    var callTimer: Timer!
    var recordedTime: Int = 0
    var player: AVAudioPlayer?
    
    internal static var callStateStatic: String!
    internal static var sendLeaveRequest = true
    internal static var callPageIsEnable = false // this varibale will be used for detect that call page is enable or no. connection state of call isn't important now!
    internal static var staticReturnToCall: ReturnToCallObserver!

    /************************************************/
    /***************** User Actions *****************/
    /************************************************/
    
    @IBAction func btnAnswer(_ sender: UIButton) {
        RTCClient.getInstance().answerCall()
        manageView(stateAnswer: false)
    }
    
    @IBAction func btnCancel(_ sender: UIButton) {
        RTCClient.getInstance().sendLeaveCall()
        self.playSound(sound: "igap_disconnect")
        self.dismmis()
    }
    
    @IBAction func btnMute(_ sender: UIButton) {
        if isMuteEnable {
            btnMute.setTitle("", for: UIControlState.normal)
        } else {
            btnMute.setTitle("", for: UIControlState.normal)
        }
        muteCall(mute: isMuteEnable)
        isMuteEnable = !isMuteEnable
    }
    
    @IBAction func btnChat(_ sender: UIButton) {
        IGRecentsTableViewController.needGetInfo = false
        
        let realm = try! Realm()
        let predicate = NSPredicate(format: "chatRoom.peer.id = %lld", userId)
        if let roomInfo = try realm.objects(IGRoom.self).filter(predicate).first {
            room = roomInfo
            performSegue(withIdentifier: "showRoomMessages", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRoomMessages" {
            let navigationController = segue.destination as! IGNavigationController
            let messageViewController = navigationController.topViewController as! IGMessageViewController
            messageViewController.room = room
            messageViewController.customizeBackItem = true
        }
    }
    
    @IBAction func btnSpeaker(_ sender: UIButton) {
        if isSpeakerEnable {
            speakerState(state: AVAudioSessionPortOverride.none)
            btnSpeaker.setTitle("", for: UIControlState.normal)
        } else {
            speakerState(state: AVAudioSessionPortOverride.speaker)
            btnSpeaker.setTitle("", for: UIControlState.normal)
        }
        isSpeakerEnable = !isSpeakerEnable
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIDevice.current.isProximityMonitoringEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIDevice.current.isProximityMonitoringEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        IGCall.staticReturnToCall = self
        IGCall.callPageIsEnable = true
        
        buttonViewCustomize(button: btnAnswer, color: UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 1.0), imgName: "IG_Tabbar_Call_On")
        buttonViewCustomize(button: btnCancel, color: UIColor.red, imgName: "IG_Nav_Bar_Plus")
        buttonViewCustomize(button: btnMute, color: UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 0.2), imgName: "IG_Tabbar_Call_On")
        buttonViewCustomize(button: btnChat, color: UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 0.2), imgName: "")
        buttonViewCustomize(button: btnSpeaker, color: UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 0.2), imgName: "")
        
        
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", userId)
        guard let userRegisteredInfo = try! realm.objects(IGRegisteredUser.self).filter(predicate).first else {
            return
        }
        userInfo = userRegisteredInfo
        txtCallerName.text = userRegisteredInfo.displayName
        
        
        RTCClient.getInstance().initCallStateObserver(stateDelegate: self)
        
        if isIncommingCall {
            incommingCall()
            playSound(sound: "tone", repeatEnable: true)
        } else {
            playSound(sound: "igap_signaling", repeatEnable: true)
            outgoingCall()
        }
        
        if let avatar = userRegisteredInfo.avatar {
            setImageMain(avatar: avatar)
        }
    }
    
    private func buttonViewCustomize(button: UIButton, color: UIColor, imgName: String = ""){
        button.backgroundColor = color
        
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowRadius = 0.1
        button.layer.shadowOpacity = 0.1
        
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.masksToBounds = false
        button.layer.cornerRadius = button.frame.width / 2
    }
    
    private func incommingCall() {
        guard let delegate = RTCClient.getInstance().callStateDelegate else {
            return
        }
        delegate.onStateChange(state: RTCClientConnectionState.IncommingCall)
        manageView(stateAnswer: true)
    }
    
    private func outgoingCall() {
        RTCClient.getInstance().callStateDelegate.onStateChange(state: RTCClientConnectionState.Dialing)
        RTCClient.getInstance().startConnection()
        RTCClient.getInstance().makeOffer(userId: userId)
        manageView(stateAnswer: false)
    }
    
    private func manageView(stateAnswer: Bool){
        if stateAnswer {
            btnMute.isHidden = true
            btnSpeaker.isHidden = true
            btnChat.isHidden = true
            txtCallTime.isHidden = true

        } else {
            btnMute.isHidden = false
            btnSpeaker.isHidden = false
            btnChat.isHidden = false
            txtCallTime.isHidden = false
            btnAnswer.isHidden = true
            txtCallTime.isHidden = true
            
            btnCancel.snp.updateConstraints { (make) in
                make.bottom.equalTo(btnChat.snp.top).offset(-54)
                make.width.equalTo(70)
                make.height.equalTo(70)
                make.centerX.equalTo(btnChat.snp.centerX)
            }
        }
    }
    
    private func speakerState(state: AVAudioSessionPortOverride){
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.overrideOutputAudioPort(state)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
    }
    
    private func muteCall(mute: Bool){
        for audioTrack in RTCClient.mediaStream.audioTracks {
            audioTrack.isEnabled = mute
        }
    }
    
    func onStateChange(state: RTCClientConnectionState) {
        
        DispatchQueue.main.async {
            switch state {
                
            case .Connecting:
                RTCClient.needNewInstance = false
                break
                
            case .Connected:
                self.txtCallTime.isHidden = false
                self.txtCallState.text = "Connected"
                
                if !self.callIsConnected {
                    self.callIsConnected = true
                    self.playSound(sound: "igap_connect")
                }
                
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch let error {
                    print(error.localizedDescription)
                }
                if self.callTimer == nil {
                    self.callTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
                    self.callTimer?.fire()
                }
                break
                
            case .Finished, .Disconnected:
                self.txtCallState.text = "Disconnected"
                self.playSound(sound: "igap_disconnect")
                self.dismmis()
                RTCClient.getInstance().callStateDelegate = nil
                break
                
            case .Missed:
                self.txtCallState.text = "Missed"
                self.dismmis()
                break
                
            case .NotAnswered:
                self.txtCallState.text = "NotAnswered"
                self.playSound(sound: "igap_noresponse")
                self.dismmis()
                break
                
            case .Rejected:
                self.txtCallState.text = "Rejected"
                self.playSound(sound: "igap_disconnect")
                self.dismmis()
                break
                
            case .TooLong:
                self.txtCallState.text = "TooLong"
                self.playSound(sound: "igap_disconnect")
                self.dismmis()
                break
                
            case .Failed:
                self.txtCallState.text = "Failed"
                self.playSound(sound: "igap_noresponse")
                self.dismmis()
                break
                
            case .Unavailable:
                self.txtCallState.text = "Unavailable"
                self.playSound(sound: "igap_noresponse")
                self.dismmis()
                break
                
            case .IncommingCall:
                self.txtCallState.text = "IncommingCall..."
                break
                
            case .Ringing:
                self.txtCallState.text = "Ringing..."
                self.playSound(sound: "igap_ringing", repeatEnable: true)
                break
                
            case .Dialing:
                self.txtCallState.text = "Dialing..."
                break
                
            case .signalingOfferForbiddenYouAreTalkingWithYourOtherDevices:
                let alert = UIAlertController(title: "Signaling Forbidden", message: "You Are Talking With Your Other Devices", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismmis()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                break
                
            case .signalingOfferForbiddenTheUserIsInConversation:
                let alert = UIAlertController(title: "Signaling Forbidden", message: "The User Is In Conversation", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismmis()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                break
                
            case .signalingOfferForbiddenDialedNumberIsNotActive:
                let alert = UIAlertController(title: "Signaling Forbidden", message: "Dialed Number Is Not Active", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismmis()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                break
                
            case .signalingOfferForbiddenUserIsBlocked:
                let alert = UIAlertController(title: "Signaling Forbidden", message: "User Is Blocked", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismmis()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                break
                
            case .signalingOfferForbiddenIsNotAllowedToCommunicate:
                self.playSound(sound: "igap_disconnect")
                let alert = UIAlertController(title: "Signaling Forbidden", message: "Is Not Allowed To Communicate", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismmis()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                break
                
            default:
                break
            }
        }
    }
    
    func returnToCall() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateTimerLabel() {
        recordedTime += 1
        let minute = String(format: "%02d", Int(recordedTime/60))
        let seconds = String(format: "%02d", Int(recordedTime%60))
        self.txtCallTime.text = minute + ":" + seconds
    }
    
    private func dismmis() {
        RTCClient.getInstance().disconnect()
        IGCall.callPageIsEnable = false
        callIsConnected = false
        
        if let timer = callTimer {
            timer.invalidate()
        }
        
        if IGCall.sendLeaveRequest {
            IGCall.sendLeaveRequest = false
            sendLeaveCall()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.getLatestCallLog()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    public func sendLeaveCall(){
        IGSignalingLeaveRequest.Generator.generate().success({ (protoResponse) in
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.sendLeaveCall()
                break
            default:
                break
            }
        }).send()
    }
    
    private func getLatestCallLog(){
        IGSignalingGetLogRequest.Generator.generate(offset: Int32(0), limit: 1).success { (responseProtoMessage) in
            
            if let logResponse = responseProtoMessage as? IGPSignalingGetLogResponse {
                IGSignalingGetLogRequest.Handler.interpret(response: logResponse)
            }
            
            }.error({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    self.getLatestCallLog()
                    break
                default:
                    break
                }
            }).send()
    }
    
    
    func playSound(sound: String, repeatEnable: Bool = false) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        
            if player != nil {
                player?.stop()
            }
            
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            if repeatEnable {
                player.numberOfLoops = -1
            }
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func setImageMain(avatar: IGAvatar) {
        if let originalFile = avatar.file {
            do {
                if originalFile.attachedImage != nil {
                    imgAvatar.image = originalFile.attachedImage
                } else {
                    var image: UIImage?
                    let path = originalFile.path()
                    if FileManager.default.fileExists(atPath: path!.path) {
                        image = UIImage(contentsOfFile: path!.path)
                    }
                    
                    if image != nil {
                        self.imgAvatar.image = image
                        self.viewTransparent.isHidden = false
                    } else {
                        throw NSError(domain: "asa", code: 1234, userInfo: nil)
                    }
                }
            } catch {
                IGDownloadManager.sharedManager.download(file: originalFile, previewType:.originalFile, completion: { (attachment) -> Void in
                    DispatchQueue.main.async {
                        let path = originalFile.path()
                        if let data = try? Data(contentsOf: path!) {
                            if let image = UIImage(data: data) {
                                self.viewTransparent.isHidden = false
                                self.imgAvatar.image = image
                            }
                        }
                    }
                }, failure: {
                    
                })
            }
        }
    }
}





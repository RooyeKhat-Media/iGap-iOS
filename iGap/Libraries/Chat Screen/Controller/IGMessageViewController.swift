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
import SwiftProtobuf
import GrowingTextView
import pop
import SnapKit
import AVFoundation
import DBAttachmentPickerControllerLibrary
import INSPhotoGalleryFramework
import AVKit
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa
import MBProgressHUD

class IGHeader: UICollectionReusableView {
    
    override var reuseIdentifier: String? {
        get {
            return "IGHeader"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.red
        
        let label = UILabel(frame: frame)
        label.text = "sdasdasdasd"
        self.addSubview(label)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class IGMessageViewController: UIViewController, DidSelectLocationDelegate , UIGestureRecognizerDelegate {

    @IBOutlet weak var collectionView: IGMessageCollectionView!
    @IBOutlet weak var inputBarContainerView: UIView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var inputTextView: GrowingTextView!
    @IBOutlet weak var inputTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputBarHeightContainerConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputBarView: UIView!
    @IBOutlet weak var inputBarBackgroundView: UIView!
    @IBOutlet weak var inputBarLeftView: UIView!
    @IBOutlet weak var inputBarRightiew: UIView!
    @IBOutlet weak var inputBarViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputBarRecordButton: UIButton!
    @IBOutlet weak var inputBarSendButton: UIButton!
    @IBOutlet weak var inputBarRecordTimeLabel: UILabel!
    @IBOutlet weak var inputBarRecordView: UIView!
    @IBOutlet weak var inputBarRecodingBlinkingView: UIView!
    @IBOutlet weak var inputBarRecordRightView: UIView!
    @IBOutlet weak var inputBarRecordViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputBarAttachmentView: UIView!
    @IBOutlet weak var inputBarAttachmentViewThumnailImageView: UIImageView!
    @IBOutlet weak var inputBarAttachmentViewFileNameLabel: UILabel!
    @IBOutlet weak var inputBarAttachmentViewFileSizeLabel: UILabel!
    @IBOutlet weak var inputBarAttachmentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputBarOriginalMessageView: UIView!
    @IBOutlet weak var inputBarOriginalMessageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputBarOriginalMessageViewSenderNameLabel: UILabel!
    @IBOutlet weak var inputBarOriginalMessageViewBodyTextLabel: UILabel!
    @IBOutlet weak var scrollToBottomContainerView: UIView!
    @IBOutlet weak var scrollToBottomContainerViewConstraint: NSLayoutConstraint!
    private let disposeBag = DisposeBag()
    var allowForGetHistory: Bool = true
    var isInMessageViewController : Bool = true
    var recorder: AVAudioRecorder?
    var isRecordingVoice = false
    var voiceRecorderTimer: Timer?
    var recordedTime: Int = 0
    var inputTextViewHeight: CGFloat = 0.0
    var inputBarRecordRightBigViewWidthConstraintInitialValue: CGFloat = 0.0
    var inputBarRecordRightBigViewInitialFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var bouncingViewWhileRecord: UIView?
    var initialLongTapOnRecordButtonPosition: CGPoint?
    var collectionViewTopInsetOffset: CGFloat = 0.0
    var connectionStatus : IGAppManager.ConnectionStatus?
    var reportMessageId: Int64?
    
    
    //var messages = [IGRoomMessage]()
    let sortProperties = [SortDescriptor(keyPath: "creationTime", ascending: false),
                          SortDescriptor(keyPath: "id", ascending: false)]
    let sortPropertiesForMedia = [SortDescriptor(keyPath: "creationTime", ascending: true),
                                  SortDescriptor(keyPath: "id", ascending: true)]
    var messages: Results<IGRoomMessage>! //try! Realm().objects(IGRoomMessage.self)
    var messagesWithMedia = try! Realm().objects(IGRoomMessage.self)
    var messagesWithForwardedMedia = try! Realm().objects(IGRoomMessage.self)
    var notificationToken: NotificationToken?
    
    var messageCellIdentifer = IGMessageCollectionViewCell.cellReuseIdentifier()
    var logMessageCellIdentifer = IGMessageLogCollectionViewCell.cellReuseIdentifier()
    var room : IGRoom?
    var openChatFromLink: Bool = false
    var customizeBackItem: Bool = false
    //let currentLoggedInUserID = IGAppManager.sharedManager.userID()
    let currentLoggedInUserAuthorHash = IGAppManager.sharedManager.authorHash()
    
    var selectedMessageToEdit: IGRoomMessage?
    var selectedMessageToReply: IGRoomMessage?
    var selectedMessageToForwardToThisRoom:   IGRoomMessage?
    var selectedMessageToForwardFromThisRoom: IGRoomMessage?
    var currentAttachment: IGFile?
    var selectedUserToSeeTheirInfo: IGRegisteredUser?
    var selectedChannelToSeeTheirInfo: IGChannelRoom?
    var selectedGroupToSeeTheirInfo: IGGroupRoom?
    var hud = MBProgressHUD()
    
    /* variables for fetch message */
    var allMessages:Results<IGRoomMessage>!
    var getMessageLimit = 25
    var scrollToTopLimit:CGFloat = 20
    var messageSize = 0
    var page = 0
    var firstId:Int64 = 0
    var lastId:Int64 = 0
    
    var isEndOfScroll = false
    var lowerAllow = true
    var allowForGetHistoryLocal = true
    var isFirstHistory = true
    var hasLocal = true

    fileprivate var typingStatusExpiryTimer = Timer() //use this to send cancel for typing status
    
    //MARK: - Initilizers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (connectionStatus) in
            DispatchQueue.main.async {
                self.updateConnectionStatus(connectionStatus)
                
            }
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).disposed(by: disposeBag)
        

        
        self.addNotificationObserverForTapOnStatusBar()
        var canBecomeFirstResponder: Bool { return true }
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.setNavigationBarForRoom(room!)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            if self.room?.type == .chat {
                self.selectedUserToSeeTheirInfo = (self.room?.chatRoom?.peer)!
                self.performSegue(withIdentifier: "showUserInfo", sender: self)
            }
            if self.room?.type == .channel {
                self.selectedChannelToSeeTheirInfo = self.room?.channelRoom
                self.performSegue(withIdentifier: "showChannelinfo", sender: self)
            }
            if self.room?.type == .group {
                self.selectedGroupToSeeTheirInfo = self.room?.groupRoom
                self.performSegue(withIdentifier: "showGroupInfo", sender: self)
            }
            
        }
        navigationItem.centerViewContainer?.addAction {
            if self.room?.type == .chat {
                self.selectedUserToSeeTheirInfo = (self.room?.chatRoom?.peer)!
                self.performSegue(withIdentifier: "showUserInfo", sender: self)
            } else {
                
            }
        }
        
        if customizeBackItem {
            navigationItem.backViewContainer?.addAction {
                self.performSegue(withIdentifier: "showRoomList", sender: self)
            }
        }
        
        if room!.isReadOnly {
            if room!.isParticipant == false {
                inputBarContainerView.isHidden = true
                joinButton.isHidden = false
            } else {
                inputBarContainerView.isHidden = true
                collectionViewTopInsetOffset = -54.0 + 8.0
                

            }
        } else {
            
        }
        
        

        
        
//        let predicate = NSPredicate(format: "roomId = %d AND isDeleted == false", self.room!.id)
//        messages = try! Realm().objects(IGRoomMessage.self).filter(predicate).sorted(byProperty: "creationTime")
//        messages = try! IGFactory.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(byProperty: "creationTime")
        
        let messagesWithMediaPredicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND (typeRaw = %d OR typeRaw = %d)", self.room!.id, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue)
        messagesWithMedia = try! Realm().objects(IGRoomMessage.self).filter(messagesWithMediaPredicate).sorted(by: sortPropertiesForMedia)
        
        let messagesWithForwardedMediaPredicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND (forwardedFrom.typeRaw == 1 OR forwardedFrom.typeRaw == 2 OR forwardedFrom.typeRaw == 3 OR forwardedFrom.typeRaw == 4)", self.room!.id)
        messagesWithForwardedMedia = try! Realm().objects(IGRoomMessage.self).filter(messagesWithForwardedMediaPredicate).sorted(by: sortPropertiesForMedia)
        
        self.collectionView.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        self.collectionView.delaysContentTouches = false
        self.collectionView.keyboardDismissMode = .none
        self.collectionView.dataSource = self
        self.collectionView.delegate = self


        let bgColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        
        self.view.backgroundColor = bgColor
        self.view.superview?.backgroundColor = bgColor
        self.view.superview?.superview?.backgroundColor = bgColor
        self.view.superview?.superview?.superview?.backgroundColor = bgColor
        self.view.superview?.superview?.superview?.superview?.backgroundColor = bgColor

        
        let inputTextViewInitialHeight:CGFloat = 22.0 //initial without reply || forward || attachment || text
        self.inputTextViewHeight = inputTextViewInitialHeight
        self.setInputBarHeight()
        
        
        inputTextView.delegate = self
        inputTextView.placeholder = "Write here ..."
        inputTextView.placeholderColor = UIColor(red: 173.0/255.0, green: 173.0/255.0, blue: 173.0/255.0, alpha: 1.0)
        inputTextView.maxHeight = 83.0 // almost 4 lines
        inputTextView.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: -5, right: 0)
        
        
        inputBarLeftView.layer.cornerRadius = 6.0//19.0
        inputBarLeftView.layer.masksToBounds = true
        inputBarRightiew.layer.cornerRadius = 6.0//19.0
        inputBarRightiew.layer.masksToBounds = true
        
        
        inputBarBackgroundView.layer.cornerRadius = 6.0//19.0
        inputBarBackgroundView.layer.masksToBounds = false
        inputBarBackgroundView.layer.shadowColor = UIColor.black.cgColor
        inputBarBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 0)
        inputBarBackgroundView.layer.shadowRadius = 4.0
        inputBarBackgroundView.layer.shadowOpacity = 0.15
        inputBarBackgroundView.layer.borderColor = UIColor(red: 209.0/255.0, green: 209.0/255.0, blue: 209.0/255.0, alpha: 1.0).cgColor
        inputBarBackgroundView.layer.borderWidth  = 1.0
        
        inputBarView.layer.cornerRadius = 6.0//19.0
        inputBarView.layer.masksToBounds = true
        
        inputBarRecordView.layer.cornerRadius = 6.0//19.0
        inputBarRecordView.layer.masksToBounds = false
        inputBarRecodingBlinkingView.layer.cornerRadius = 8.0
        inputBarRecodingBlinkingView.layer.masksToBounds = false
        inputBarRecordRightView.layer.cornerRadius = 6.0//19.0
        inputBarRecordRightView.layer.masksToBounds = false
        
        inputBarRecordView.isHidden = true
        inputBarRecodingBlinkingView.isHidden = true
        inputBarRecordRightView.isHidden = true
        inputBarRecordTimeLabel.isHidden = true
        inputBarRecordTimeLabel.alpha = 0.0
        inputBarRecordViewLeftConstraint.constant = 200
        
        
        scrollToBottomContainerView.layer.cornerRadius = 20.0
        scrollToBottomContainerView.layer.masksToBounds = false
        scrollToBottomContainerView.layer.shadowColor = UIColor.black.cgColor
        scrollToBottomContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        scrollToBottomContainerView.layer.shadowRadius = 4.0
        scrollToBottomContainerView.layer.shadowOpacity = 0.15
        scrollToBottomContainerView.backgroundColor = UIColor.white
        scrollToBottomContainerView.isHidden = true
        
        self.setCollectionViewInset()
        //Keyboard Notification
        
        notification(register: true)
        inputBarSendButton.isHidden = true
        
        
        let tapAndHoldOnRecord = UILongPressGestureRecognizer(target: self, action: #selector(didTapAndHoldOnRecord(_:)))
        tapAndHoldOnRecord.minimumPressDuration = 0.5
        inputBarRecordButton.addGestureRecognizer(tapAndHoldOnRecord)
        
        messages = findAllMessages()
        updateObserver()
        
        if messages.count == 0 {
            fetchRoomHistoryWhenDbIsClear()
        }
    }
    
    func updateObserver(){
        self.notificationToken = messages?.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                break
            case .update(_, let deletions, let insertions, let modifications):
                
                for cellsPosition in modifications {
                    if self.collectionView.indexPathsForVisibleItems.contains(IndexPath(row: 0, section: cellsPosition)) {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                        break
                    }
                }
                
                if insertions.count > 0 || deletions.count > 0 {
                    
                    if self.isEndOfScroll && self.collectionView.numberOfSections > 100 {
                        self.resetGetHistoryValues()
                        self.messages = self.findAllMessages()
                    } else {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
                
                break
            case .error(let err):
                fatalError("\(err)")
                break
            }
        }
    }
    
    func findAllMessages(isHistory: Bool = false) -> Results<IGRoomMessage>!{
        
        if lastId == 0 {
            let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false", self.room!.id)
            allMessages = try! Realm().objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties)
            
            let messageCount = allMessages.count
            if messageCount == 0 {
                return allMessages
            }
            
            firstId = allMessages.toArray()[0].id
            
            if messageCount <= getMessageLimit {
                hasLocal = false
                scrollToTopLimit = 500
                lastId = allMessages.toArray()[allMessages.count-1].id
            } else {
                lastId = allMessages.toArray()[getMessageLimit].id
            }
            
        } else {
            page += 1
            
            if page > 1 {
                getMessageLimit = 100
            }
            
            let messageLimit = page * getMessageLimit
            let messageCount = allMessages.count
            
            if messageCount <= messageLimit {
                hasLocal = false
                scrollToTopLimit = 500
                lastId = allMessages.toArray()[allMessages.count-1].id
            } else {
                lastId = allMessages.toArray()[messageLimit].id
            }
        }
        
        let predicate = NSPredicate(format: "roomId = %lld AND id >= %lld AND isDeleted == false", self.room!.id, lastId)
        let messages = try! Realm().objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        return messages
    }
    
    /* reset values for get history from first */
    func resetGetHistoryValues(){
        lastId = 0
        page = 0
        getMessageLimit = 50
        scrollToTopLimit = 20
        hasLocal = true
    }
    
    
    /* delete all local messages before first message that have shouldFetchBefore==true */
    func deleteUnusedLocalMessage(){
        let predicate = NSPredicate(format: "roomId = %lld AND shouldFetchBefore == true", self.room!.id)
        let message = try! Realm().objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties).last
        
        var deleteId:Int64 = 0
        if let id = message?.id {
            deleteId = id
        }
        
        let predicateDelete = NSPredicate(format: "roomId = %lld AND id <= %lld", self.room!.id , deleteId)
        let messageDelete = try! Realm().objects(IGRoomMessage.self).filter(predicateDelete).sorted(by: sortProperties)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(messageDelete)
        }
    }
    
    func deleteForTest(){
        let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false", self.room!.id)
        let message = try! Realm().objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties)

        if message.count > 100 {
            
            let predicateDelete = NSPredicate(format: "roomId = %lld AND id <= %lld ", self.room!.id , message.toArray()[100].id)
            let messageDelete = try! Realm().objects(IGRoomMessage.self).filter(predicateDelete).sorted(by: sortProperties)
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(messageDelete)
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let forwardMsg = selectedMessageToForwardToThisRoom {
            self.forwardMessage(forwardMsg)
        } else if let draft = self.room!.draft {
            if draft.message != "" || draft.replyTo != -1 {
                inputTextView.text = draft.message
                inputTextView.placeholder = "Write here ..."
                if draft.replyTo != -1 {
                    let predicate = NSPredicate(format: "id = %lld AND roomId = %lld", draft.replyTo, self.room!.id)
                    if let replyToMessage = try! Realm().objects(IGRoomMessage.self).filter(predicate).first {
                        replyMessage(replyToMessage)
                    }
                }
                setSendAndRecordButtonStates()
            }
        }
        notification(register: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IGAppManager.sharedManager.currentMessagesNotificationToekn = self.notificationToken
        let navigationItem = self.navigationItem as! IGNavigationItem
//        _ = Observable.from(object: room!)
//            .subscribe(onNext: {aRoom in
//                print ("room changed")
//                
//            })
        
        
        if let roomVariable = IGRoomManager.shared.varible(for: room!) {
            roomVariable.asObservable().subscribe({ (event) in
                if event.element == self.room! {
                    DispatchQueue.main.async {
                        navigationItem.updateNavigationBarForRoom(event.element!)
                        
                    }
                }
            }).disposed(by: disposeBag)
//            _ = Observable.from(roomVariable).subscribe(onNext: { (roomVariable) in
//                print ("room changed")
//            }, onError: nil, onCompleted: nil, onDisposed: nil)
//            roomVariableFromRoomManagerCache = roomVariable
//            roomVariableFromRoomManagerCache?.asObservable().subscribe({ (event) in
//                DispatchQueue.main.async {
//                    if self.roomVariableFromRoomManagerCache?.value.id != room.id {
//                        return
//                    }
//                    navigationItem.updateNavigationBarForRoom(aRoom)
//                    
//                    
//                    
//                    
//                    
//                }
//            }).addDisposableTo(disposeBag)
        }
        
        
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            
        }
        
        self.setMessagesRead()
        
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IGAppManager.sharedManager.currentMessagesNotificationToekn = nil
        self.room!.saveDraft(inputTextView.text, replyToMessage: selectedMessageToReply)
        self.sendCancelTyping()
        self.isInMessageViewController = false
        self.sendCancelRecoringVoice()
        if let room = self.room {
            IGFactory.shared.markAllMessagesAsRead(roomId: room.id)
            if openChatFromLink { // TODO - also check if user before joined to this room don't send this request
                sendUnsubscribForRoom(roomId: room.id)
                IGFactory.shared.updateRoomParticipant(roomId: room.id, isParticipant: false)
            }
        }
    }
    
    deinit {
        if notificationToken != nil {
            notificationToken?.invalidate()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //TODO: check performance
        self.collectionView!.collectionViewLayout.invalidateLayout()
    }
    
    private func sendUnsubscribForRoom(roomId: Int64){
        IGClientUnsubscribeFromRoomRequest.Generator.generate(roomId: roomId).success { (responseProtoMessage) in
            }.error({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    self.sendUnsubscribForRoom(roomId: roomId)
                default:
                    break
                }
            }).send()
    }
    
    //MARK - Send Seen Status
    private func setMessagesRead() {
        if let room = self.room {
            IGFactory.shared.markAllMessagesAsRead(roomId: room.id)
        }
        self.messages!.forEach{
            if let authorHash = $0.authorHash {
                if authorHash != self.currentLoggedInUserAuthorHash! {
                    self.sendSeenForMessage($0)
                }
            }
        }
    }
    
    private func sendSeenForMessage(_ message: IGRoomMessage) {
        if message.status == .seen {
            return
        }
        switch self.room!.type {
        case .chat:
            if isInMessageViewController {
                IGChatUpdateStatusRequest.Generator.generate(roomID: self.room!.id, messageID: message.id, status: .seen).success({ (responseProto) in
                    switch responseProto {
                    case let response as IGPChatUpdateStatusResponse:
                        IGChatUpdateStatusRequest.Handler.interpret(response: response)
                    default:
                        break
                    }
                }).error({ (errorCode, waitTime) in
                    
                }).send()
            }
        case .group:
            if isInMessageViewController {
                IGGroupUpdateStatusRequest.Generator.generate(roomID: self.room!.id, messageID: message.id, status: .seen).success({ (responseProto) in
                    switch responseProto {
                    case let response as IGPGroupUpdateStatusResponse:
                        IGGroupUpdateStatusRequest.Handler.interpret(response: response)
                    default:
                        break
                    }
                }).error({ (errorCode, waitTime) in
                    
                }).send()
            }
            break
        case .channel:
            if isInMessageViewController {
                if let message = self.messages?.last {
                    IGChannelGetMessagesStatsRequest.Generator.generate(messages: [message], room: self.room!).success({ (responseProto) in
                        
                    }).error({ (errorCode, waitTime) in
                        
                    }).send()
                }
            }
        }
    }
    
    func userWasSelectedLocation(location: CLLocation) {
        print(location)
    }

    //MARK: - Scroll
    func updateScrollPosition(forceToLastMessage: Bool, wasAddedMessagesNewer: Bool?, initialContentOffset: CGPoint?, initialContentSize: CGSize?, animated: Bool) {
//        if forceToBottom {
//            scrollToLastMessage(animated: animated)
//        } else {
//            let initalContentBottomPadding = (initialContentSize!.height + self.collectionView.contentInset.bottom) - (initialContentOffset!.y + self.collectionView.frame.height)
//            
//            //100 is an arbitrary number can be anything that makes sense. 100, 150, ...
//            //we used this to see if user is near the bottom of scroll view and 
//            //we should scrolll to bottom
//            if initalContentBottomPadding < 100 {
//                scrollToLastMessage(animated: animated)
//            } else {
//                if didMessagesAddedToBottom != nil {
//                    keepScrollPosition(didMessagesAddedToBottom: didMessagesAddedToBottom!, initialContentOffset: initialContentOffset!, initialContentSize: initialContentSize!, animated: animated)
//                }
//            }
//        }
    }
    
//    private func scrollToLastMessage(animated: Bool) {
//        if self.collectionView.numberOfItems(inSection: 0) > 0  {
////            let indexPath = IndexPath(row: self.collectionView.numberOfItems(inSection: 0)-1, section: 0)
//            let indexPath = IndexPath(row: 0, section: self.collectionView.numberOfItems(inSection: 0)-1)
//            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
//        }
//    }
    
    private func keepScrollPosition(didMessagesAddedToBottom: Bool, initialContentOffset: CGPoint, initialContentSize: CGSize, animated: Bool) {
        if didMessagesAddedToBottom {
            self.collectionView.contentOffset = initialContentOffset
        } else {
            let contentOffsetY = self.collectionView.contentSize.height - (initialContentSize.height - initialContentOffset.y)
            // + self.collectionView.contentOffset.y - initialContentSize.height
            self.collectionView.contentOffset = CGPoint(x: self.collectionView.contentOffset.x, y: contentOffsetY)
        }
    }
    
    
    //MARK: -
    private func notification(register: Bool) {
        let center = NotificationCenter.default
        if register {
            center.addObserver(self,
                               selector: #selector(didReceiveKeyboardWillChangeFrameNotification(_:)),
                               name: NSNotification.Name.UIKeyboardWillHide,
                               object: nil)
            center.addObserver(self,
                               selector: #selector(didReceiveKeyboardWillChangeFrameNotification(_:)),
                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                               object: nil)
            
            center.addObserver(self,
                               selector: #selector(dodd),
                               name: NSNotification.Name.UIMenuControllerWillShowMenu,
                               object: nil)
            center.addObserver(self,
                               selector: #selector(dodd),
                               name: NSNotification.Name.UIMenuControllerWillHideMenu,
                               object: nil)
            center.addObserver(self,
                               selector: #selector(dodd),
                               name: NSNotification.Name.UIContentSizeCategoryDidChange,
                               object: nil)
        } else {
            center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
            center.removeObserver(self, name: NSNotification.Name.UIMenuControllerWillShowMenu, object: nil)
            center.removeObserver(self, name: NSNotification.Name.UIMenuControllerWillHideMenu, object: nil)
            center.removeObserver(self, name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        }
    }
    
    func dodd() {
    
    }
    
    func didReceiveKeyboardWillChangeFrameNotification(_ notification:Notification) {
        
        let userInfo = (notification.userInfo)!
        if let keyboardEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            
            let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! Int
            let animationCurveOption = (animationCurve << 16)
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            let keyboardBeginFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as! CGRect
            
            var bottomConstraint: CGFloat
            if keyboardEndFrame.origin.y == keyboardBeginFrame.origin.y {
                return
            } else if notification.name == Notification.Name.UIKeyboardWillHide  {
                //hidding keyboard
                bottomConstraint = 0.0
            } else {
                //showing keyboard
                bottomConstraint = keyboardEndFrame.size.height
            }
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(animationCurveOption)), animations: {
                self.inputBarViewBottomConstraint.constant = bottomConstraint
                //self.setCollectionViewInset()
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
        }
    }
        
    func setCollectionViewInset() {
        let value = inputBarHeightContainerConstraint.constant + collectionViewTopInsetOffset// + inputBarViewBottomConstraint.constant
        UIView.animate(withDuration: 0.2, animations: {
            self.collectionView.contentInset = UIEdgeInsetsMake(value, 0, 20, 0)
        }, completion: { (completed) in
            
        })
    }
    
    func updateConnectionStatus(_ status: IGAppManager.ConnectionStatus) {
        
        switch status {
        case .connected:
            connectionStatus = .connected
        case .connecting:
            connectionStatus = .connecting
        case .waitingForNetwork:
            connectionStatus = .waitingForNetwork
        }
        
    }
    
    
    
    //MARK: IBActions
    @IBAction func didTapOnSendButton(_ sender: UIButton) {
        if currentAttachment == nil && inputTextView.text == "" && selectedMessageToForwardToThisRoom == nil {
            return
        }
        
        inputTextView.text = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if connectionStatus == .waitingForNetwork || connectionStatus == .connecting {
            let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }else {
        if selectedMessageToEdit != nil {
                        switch room!.type {
            case .chat:
                IGChatEditMessageRequest.Generator.generate(message: selectedMessageToEdit!, newText: inputTextView.text,  room: room!).success({ (protoResponse) in
                    IGChatEditMessageRequest.Handler.interpret(response: protoResponse)
                }).error({ (errorCode, waitTime) in
                    
                }).send()
            case .group:
                IGGroupEditMessageRequest.Generator.generate(message: selectedMessageToEdit!, newText: inputTextView.text, room: room!).success({ (protoResponse) in
                    switch protoResponse {
                    case let response as IGPGroupEditMessageResponse:
                        IGGroupEditMessageRequest.Handler.interpret(response: response)
                    default:
                        break
                    }
                }).error({ (errorCode, waitTime) in
                    
                }).send()
            case .channel:
                IGChannelEditMessageRequest.Generator.generate(message: selectedMessageToEdit!, newText: inputTextView.text, room: room!).success({ (protoResponse) in
                    switch protoResponse {
                    case let response as IGPChannelEditMessageResponse:
                        IGChannelEditMessageRequest.Handler.interpret(response: response)
                    default:
                        break
                    }
                }).error({ (errorCode, waitTime) in
                    
                }).send()
            }
            
            selectedMessageToEdit = nil
            self.inputTextView.text = ""
            self.setInputBarHeight()
            self.sendCancelTyping()
            return
        }
        
        let message = IGRoomMessage(body: inputTextView.text)
        
        if currentAttachment != nil {
            currentAttachment?.status = .processingForUpload
            message.attachment = currentAttachment?.detach()
            IGAttachmentManager.sharedManager.add(attachment: currentAttachment!)
            switch currentAttachment!.type {
            case .image:
                if inputTextView.text == "" {
                    message.type = .image
                } else {
                    message.type = .imageAndText
                }
            case .video:
                if inputTextView.text == "" {
                    message.type = .video
                } else {
                    message.type = .videoAndText
                }
            case .audio:
                if inputTextView.text == "" {
                    message.type = .audio
                } else {
                    message.type = .audioAndText
                }
            case .voice:
                message.type = .voice
            case .file:
                if inputTextView.text == "" {
                    message.type = .file
                } else {
                    message.type = .fileAndText
                }
            default:
                break
            }
        } else {
            message.type = .text
        }
        message.repliedTo = selectedMessageToReply
        message.forwardedFrom = selectedMessageToForwardToThisRoom

        message.roomId = self.room!.id
        
        let detachedMessage = message.detach()
        
        IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
        IGMessageSender.defaultSender.send(message: message, to: room!)
        
        self.inputBarSendButton.isHidden = true
        self.inputBarRecordButton.isHidden = false
        self.inputTextView.text = ""
        self.selectedMessageToForwardToThisRoom = nil
        self.selectedMessageToReply = nil
        self.currentAttachment = nil
        self.setInputBarHeight()
        }
    }
    
    
    @IBAction func didTapOnAddAttachmentButton(_ sender: UIButton) {
        self.inputTextView.resignFirstResponder()
        let contact = UIAlertAction(title: "Contact", style: .default, handler: { (action) in
        })
        let location = UIAlertAction(title: "Location", style: .default, handler: { (action) in
            let settingStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let setCurrentLocationTableViewController = settingStoryBoard.instantiateViewController(withIdentifier: "SetCurrentLocationPage") as! IGMessageAttachmentCurrentLocationViewController
            let modalStyle: UIModalTransitionStyle = UIModalTransitionStyle.coverVertical
            setCurrentLocationTableViewController.modalTransitionStyle = modalStyle
            let navigationBar = IGNavigationController(rootViewController: setCurrentLocationTableViewController)
            self.present(navigationBar, animated: true, completion: nil)

        })
        _ = [contact, location]
        
        let attachmentPickerController = DBAttachmentPickerController(customActions: nil, finishPicking: { (files) in
            //at phase 1 we only select one media
            if files.count > 0 {
                let selectedFile = files[0]
                
                let attachment = IGFile(name: selectedFile.fileName)
                attachment.size = Int(selectedFile.fileSize)
                print("size = \(Int(selectedFile.fileSize))")
                switch selectedFile.sourceType {
                case .image, .phAsset:
                    selectedFile.loadOriginalImage(completion: { (image) in
                        var scaledImage = image
                        
                        if (image?.size.width)! > CGFloat(2000.0) || (image?.size.height)! >= CGFloat(2000) {
                            scaledImage = IGUploadManager.compress(image: image!)
                        }
                        
                        attachment.attachedImage = scaledImage
                        let imgData = UIImageJPEGRepresentation(scaledImage!, 0.7)
                        let randomString = IGGlobal.randomString(length: 16) + "_"
                        let fileNameOnDisk = randomString + selectedFile.fileName!
                        attachment.fileNameOnDisk = fileNameOnDisk
                        self.saveAttachmentToLocalStorage(data: imgData!, fileNameOnDisk: fileNameOnDisk)
                        
                        attachment.height = Double((scaledImage?.size.height)!)
                        attachment.width = Double((scaledImage?.size.width)!)
                        attachment.size = (imgData?.count)!
                        attachment.data = imgData
                        attachment.type = .image
                        
                        self.inputBarAttachmentViewThumnailImageView.image = attachment.attachedImage
                        
                        self.inputBarAttachmentViewThumnailImageView.layer.cornerRadius = 6.0
                        self.inputBarAttachmentViewThumnailImageView.layer.masksToBounds = true
                        
                        self.didSelectAttachment(attachment)
                    })
                    break
                case .documentURL:
                    //recorded videos will be here
                    //also selected files form other apps
                    
                    if selectedFile.originalFileResource() is String {
                        print ("This is a file selected from ")
                        let selectedFilePath = selectedFile.originalFileResource() as! String
                        
                        
                        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                        let randomString = IGGlobal.randomString(length: 16) + "_"
                        attachment.fileNameOnDisk = randomString + selectedFile.fileName!
                        let pathOnDisk = documents + "/" + randomString + selectedFile.fileName!
                        
                        try! FileManager.default.copyItem(atPath: selectedFilePath, toPath: pathOnDisk)
                        attachment.height = 0
                        print(URL(string: pathOnDisk)!.pathExtension)
                        attachment.width = 0
                        switch URL(string: pathOnDisk)!.pathExtension {
                        case "MP3":
                            attachment.type = .audio
                        case "MOV":
                            attachment.type = .video
                        case "MP4":
                            attachment.type = .video
                        default:
                            attachment.type = .file
                        }
                        attachment.name = selectedFile.fileName
                        
                        self.inputBarAttachmentViewThumnailImageView.layer.cornerRadius = 6.0
                        self.inputBarAttachmentViewThumnailImageView.layer.masksToBounds = true
                        
                        self.didSelectAttachment(attachment)
                    }
                    
                    
                    break
                case .unknown:
                    break
                }
            }
        }, cancel: nil)

        
        attachmentPickerController.mediaType = [.image , .video]
        attachmentPickerController.capturedVideoQulity = .typeHigh
        attachmentPickerController.allowsMultipleSelection = false
        attachmentPickerController.allowsSelectionFromOtherApps = true
        attachmentPickerController.present(on: self)
    }
    
    @IBAction func didTapOnDeleteSelectedAttachment(_ sender: UIButton) {
        self.currentAttachment = nil
        self.setInputBarHeight()
        let text = inputTextView.text as NSString
        if text.length > 0 {
            self.inputBarSendButton.isHidden = false
            self.inputBarRecordButton.isHidden = true
        } else {
            self.inputBarSendButton.isHidden = true
            self.inputBarRecordButton.isHidden = false
        }
    }
    
    @IBAction func didTapOnCancelReplyOrForwardButton(_ sender: UIButton) {
        self.selectedMessageToForwardToThisRoom = nil
        self.selectedMessageToReply = nil
        self.setInputBarHeight()
        self.setSendAndRecordButtonStates()
    }
    
    @IBAction func didTapOnScrollToBottomButton(_ sender: UIButton) {
        self.collectionView.setContentOffset(CGPoint(x: 0, y: -self.collectionView.contentInset.top) , animated: false)
    }
    
    @IBAction func didTapOnJoinButton(_ sender: UIButton) {
        var username: String?
        if room?.channelRoom != nil {
            if let channelRoom = room?.channelRoom {
                if channelRoom.type == .publicRoom {
                    username = channelRoom.publicExtra?.username
                }
            }
        }
        if room?.groupRoom != nil {
            if let groupRoom = room?.groupRoom {
                if groupRoom.type == .publicRoom {
                    username = groupRoom.publicExtra?.username
                }
            }
        }
        if let publicRooomUserName = username {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGClientJoinByUsernameRequest.Generator.generate(userName: publicRooomUserName).success({ (protoResponse) in
                self.openChatFromLink = false
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientJoinbyUsernameResponse as IGPClientJoinByUsernameResponse:
                        IGClientJoinByUsernameRequest.Handler.interpret(response: clientJoinbyUsernameResponse)
                        self.joinButton.isHidden = true
                        self.hud.hide(animated: true)
                        self.collectionViewTopInsetOffset = -54.0 + 8.0
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.hud.hide(animated: true)
                        self.present(alert, animated: true, completion: nil)
                    }
                case .clinetJoinByUsernameForbidden:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "You don't have permission to join this room", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.hud.hide(animated: true)
                        self.present(alert, animated: true, completion: nil)
                    }

                default:
                    break
                }
                
            }).send()
        }
    }
    

    //MARK: AudioRecorder
    func didTapAndHoldOnRecord(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            startRecording()
            initialLongTapOnRecordButtonPosition = gestureRecognizer.location(in: self.view)
        case .cancelled:
            print("cancelled")
        case .changed:
            let point = gestureRecognizer.location(in: self.view)
            let difX = (initialLongTapOnRecordButtonPosition?.x)! - point.x
            
            var newConstant:CGFloat = 0.0
            if difX > 10 {
                newConstant = 74 - difX
            } else {
                newConstant = 74
            }
            
            if newConstant > 0{
                inputBarRecordViewLeftConstraint.constant = newConstant
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.layoutIfNeeded()
                })
            } else {
                cancelRecording()
            }
            
            print("point: \(difX)")
            print("constant: \(inputBarRecordViewLeftConstraint.constant)")
            
        case .ended:
            finishRecording()
        case .failed:
            print("failed")
        case .possible:
            print("possible")
        }
    }
    
    func startRecording() {
        prepareViewForRecord()
        recordVoice()
    }
    
    func cancelRecording() {
        cleanViewAfterRecord()
        recorder?.stop()
        isRecordingVoice = false
        voiceRecorderTimer?.invalidate()
        recordedTime = 0
    }
    
    func finishRecording() {
        cleanViewAfterRecord()
        recorder?.stop()
        voiceRecorderTimer?.invalidate()
        recordedTime = 0
    }
    
    func prepareViewForRecord() {
        //disable rotation
        self.isRecordingVoice = true
        
        inputBarRecordView.isHidden = false
        inputBarRecodingBlinkingView.isHidden = false
        inputBarRecordRightView.isHidden = false
        inputBarRecordTimeLabel.isHidden = false
        
        inputTextView.isHidden = true
        inputBarLeftView.isHidden = true
        
        inputBarRecordViewLeftConstraint.constant = 74
        UIView.animate(withDuration: 0.5) {
            self.inputBarRecordTimeLabel.alpha = 1.0
            self.view.layoutIfNeeded()
        }
        
        if bouncingViewWhileRecord != nil {
            bouncingViewWhileRecord?.removeFromSuperview()
        }
        
        let frame = self.inputBarView.convert(inputBarRecordRightView.frame, from: inputBarRecordRightView)
        let width = frame.size.width
        //let bouncingViewFrame = CGRect(x: frame.origin.x - 2*width, y: frame.origin.y - 2*width, width: 3*width, height: 3*width)
        let bouncingViewFrame = CGRect(x: 0, y: 0, width: 3*width, height: 3*width)
        bouncingViewWhileRecord = UIView(frame: bouncingViewFrame)
        bouncingViewWhileRecord?.layer.cornerRadius = width * 3/2
        bouncingViewWhileRecord?.backgroundColor = UIColor.organizationalColor()
        bouncingViewWhileRecord?.alpha = 0.2
        self.view.addSubview(bouncingViewWhileRecord!)
        bouncingViewWhileRecord?.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(3*width)
            make.center.equalTo(self.inputBarRecordRightView)
        }
        
        
        let alpha = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        alpha?.toValue = 0.0
        alpha?.repeatForever = true
        alpha?.autoreverses = true
        alpha?.duration = 1.0
        inputBarRecodingBlinkingView.pop_add(alpha, forKey: "alphaBlinking")
        
        let size = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        size?.toValue = NSValue(cgPoint: CGPoint(x: 0.8, y: 0.8))
        size?.velocity = NSValue(cgPoint: CGPoint(x: 2, y: 2))
        size?.springBounciness = 20.0
        size?.repeatForever = true
        size?.autoreverses = true
        bouncingViewWhileRecord?.pop_add(size, forKey: "size")
        
        
        voiceRecorderTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
        voiceRecorderTimer?.fire()
    }
    
    func cleanViewAfterRecord() {
        inputBarRecordViewLeftConstraint.constant = 200
        UIView.animate(withDuration: 0.5) {
            self.inputBarRecordTimeLabel.text = "00:00"
            self.inputBarRecordTimeLabel.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
        
        UIView.animate(withDuration: 0.3, animations: {
            self.inputBarRecordView.alpha = 0.0
            self.inputBarRecodingBlinkingView.alpha = 0.0
            self.inputBarRecordRightView.alpha = 0.0
            self.inputBarRecordTimeLabel.alpha = 0.0
        }, completion: { (success) -> Void in
            //TODO: enable rotation
            self.inputBarRecordView.isHidden = true
            self.inputBarRecodingBlinkingView.isHidden = true
            self.inputBarRecordRightView.isHidden = true
            self.inputBarRecordTimeLabel.isHidden = true
            
            self.inputBarRecordView.alpha = 1.0
            self.inputBarRecodingBlinkingView.alpha = 1.0
            self.inputBarRecordRightView.alpha = 1.0
            self.inputBarRecordTimeLabel.alpha = 1.0
            
            self.inputTextView.isHidden = false
            self.inputBarLeftView.isHidden = false
            
            //animation
            self.inputBarRecodingBlinkingView.pop_removeAllAnimations()
            self.inputBarRecodingBlinkingView.alpha = 1.0
            self.bouncingViewWhileRecord?.removeFromSuperview()
            self.bouncingViewWhileRecord = nil
        })
        
        
    }
    
    func updateTimerLabel() {
        recordedTime += 1
        let minute = String(format: "%02d", Int(recordedTime/60))
        let seconds = String(format: "%02d", Int(recordedTime%60))
        inputBarRecordTimeLabel.text = minute + ":" + seconds
    }
    
    func recordVoice() {
        do {
            self.sendRecordingVoice()
            let fileName = "Recording - \(NSDate.timeIntervalSinceReferenceDate)"
            
            let writePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)?.appendingPathExtension("m4a")
            
            var audioRecorderSetting = Dictionary<String, Any>()
            audioRecorderSetting[AVFormatIDKey] = NSNumber(value: kAudioFormatMPEG4AAC)
            audioRecorderSetting[AVSampleRateKey] = NSNumber(value: 44100.0)
            audioRecorderSetting[AVNumberOfChannelsKey] = NSNumber(value: 2)
            
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
            recorder = try AVAudioRecorder(url: writePath!, settings: audioRecorderSetting)
            if recorder == nil {
                didFinishRecording(success: false)
                return
            }
            recorder?.isMeteringEnabled = true
            recorder?.delegate = self
            recorder?.prepareToRecord()
            recorder?.record()
        } catch {
            didFinishRecording(success: false)
        }
    }
    
    func didFinishRecording(success: Bool) {
        print((recorder?.url)!)
        recorder = nil
    }
    
    //MARK: Attachment Handlers
    func didSelectAttachment(_ attachment: IGFile) {
        self.currentAttachment = attachment
        self.setInputBarHeight()
        self.inputBarSendButton.isHidden = false
        self.inputBarRecordButton.isHidden = true
        self.inputBarAttachmentViewFileNameLabel.text  = currentAttachment?.name
        let sizeInByte = currentAttachment!.size
        var sizeSting = ""
        if sizeInByte < 1024 {
            //byte
            sizeSting = "\(sizeInByte) B"
        } else if sizeInByte < 1048576 {
            //kilobytes
            sizeSting = "\(sizeInByte/1024) KB"
        } else if sizeInByte < 1073741824 {
            //megabytes
            sizeSting = "\(sizeInByte/1048576) MB"
        } else { //if sizeInByte < 1099511627776 {
            //gigabytes
            sizeSting = "\(sizeInByte/1073741824) GB"
        }
        self.inputBarAttachmentViewFileSizeLabel.text = sizeSting
    }

    func saveAttachmentToLocalStorage(data: Data, fileNameOnDisk: String) {
        let path = IGFile.path(fileNameOnDisk: fileNameOnDisk)
        FileManager.default.createFile(atPath: path.path, contents: data, attributes: nil)
    }
    
    //MARK: Actions for tap and hold on messages
    fileprivate func copyMessage(_ message: IGRoomMessage) {
        if let text = message.message {
            UIPasteboard.general.string = text
        }
    }
    
    fileprivate func editMessage(_ message: IGRoomMessage) {
        self.selectedMessageToEdit = message
        self.selectedMessageToReply = nil
        self.selectedMessageToForwardToThisRoom = nil
        
        self.inputTextView.text = message.message
        inputTextView.placeholder = "Write here ..."
        self.inputTextView.becomeFirstResponder()
        self.inputBarOriginalMessageViewSenderNameLabel.text = "Edit Message"
        self.inputBarOriginalMessageViewBodyTextLabel.text = message.message
        self.setInputBarHeight()
        
    }
    
    fileprivate func replyMessage(_ message: IGRoomMessage) {
        self.selectedMessageToEdit = nil
        self.selectedMessageToReply = message
        self.selectedMessageToForwardToThisRoom = nil
        self.inputBarOriginalMessageViewSenderNameLabel.text = message.authorUser?.displayName
        self.inputBarOriginalMessageViewBodyTextLabel.text = message.message
        self.setInputBarHeight()
    }
    
    fileprivate func forwardMessage(_ message: IGRoomMessage) {
        self.selectedMessageToEdit = nil
        self.selectedMessageToReply = nil
        self.selectedMessageToForwardFromThisRoom = message
        self.inputBarOriginalMessageViewSenderNameLabel.text = message.authorUser?.displayName
        self.inputBarOriginalMessageViewBodyTextLabel.text = message.message
        self.setInputBarHeight()
        self.setSendAndRecordButtonStates()
    }
    
    func reportRoom(roomId: Int64, messageId: Int64, reason: IGPClientRoomReport.IGPReason) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGClientRoomReportRequest.Generator.generate(roomId: roomId, messageId: messageId, reason: reason).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case _ as IGPClientRoomReportResponse:
                    let alert = UIAlertController(title: "Success", message: "Your report has been successfully submitted", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .clientRoomReportReportedBefore:
                    let alert = UIAlertController(title: "Error", message: "This Room Reported Before", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .clientRoomReportForbidden:
                    let alert = UIAlertController(title: "Error", message: "Room Report Fobidden", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    func report(room: IGRoom, message: IGRoomMessage){
        let roomId = room.id
        let messageId = message.id
        
        let alertC = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let abuse = UIAlertAction(title: "Abuse", style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, messageId: messageId, reason: IGPClientRoomReport.IGPReason.abuse)
        })
        
        let spam = UIAlertAction(title: "Spam", style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, messageId: messageId, reason: IGPClientRoomReport.IGPReason.spam)
        })
        
        let violence = UIAlertAction(title: "Violence", style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, messageId: messageId, reason: IGPClientRoomReport.IGPReason.violence)
        })
        
        let pornography = UIAlertAction(title: "Pornography", style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, messageId: messageId, reason: IGPClientRoomReport.IGPReason.pornography)
        })
        
        let other = UIAlertAction(title: "Other ", style: .default, handler: { (action) in
            self.reportMessageId = messageId
            self.performSegue(withIdentifier: "showReportPage", sender: self)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        })
        
        alertC.addAction(abuse)
        alertC.addAction(spam)
        alertC.addAction(violence)
        alertC.addAction(pornography)
        alertC.addAction(other)
        alertC.addAction(cancel)
        
        self.present(alertC, animated: true, completion: {
            
        })
    }
    
    
    fileprivate func deleteMessage(_ message: IGRoomMessage, both: Bool = false) {
        switch room!.type {
        case .chat:
            IGChatDeleteMessageRequest.Generator.generate(message: message, room: self.room!, both: both).success { (responseProto) in
                switch responseProto {
                case let response as IGPChatDeleteMessageResponse:
                    IGChatDeleteMessageRequest.Handler.interpret(response: response)
                default:
                    break
                }
            }.error({ (errorCode, waitTime) in
                
            }).send()
        case .group:
            IGGroupDeleteMessageRequest.Generator.generate(message: message, room: room!).success({ (responseProto) in
                switch responseProto {
                case let response as IGPGroupDeleteMessageResponse:
                    IGGroupDeleteMessageRequest.Handler.interpret(response: response)
                default:
                    break
                }
            }).error({ (errorCode, waitTime) in
                
            }).send()
        case .channel:
            IGChannelDeleteMessageRequest.Generator.generate(message: message, room: room!).success({ (responseProto) in
                switch responseProto {
                case let response as IGPChannelDeleteMessageResponse:
                    IGChannelDeleteMessageRequest.Handler.interpret(response: response)
                default:
                    break
                }
            }).error({ (errorCode, waitTime) in
                
            }).send()
        }
    }
    
    
    //MARK: UI states
    func setSendAndRecordButtonStates() {
        if self.selectedMessageToForwardToThisRoom != nil {
            inputBarSendButton.isHidden = false
            inputBarRecordButton.isHidden = true
        } else {
            let text = self.inputTextView.text as NSString
            if text.length == 0 && currentAttachment == nil {
                //empty -> show recored
                inputBarSendButton.isHidden = true
                inputBarRecordButton.isHidden = false
            } else {
                //show send
                inputBarSendButton.isHidden = false
                inputBarRecordButton.isHidden = true
            }
        }
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserInfo" {
            let destinationVC = segue.destination as! IGRegistredUserInfoTableViewController
            destinationVC.user = self.selectedUserToSeeTheirInfo
            destinationVC.previousRoomId = room?.id
            destinationVC.room = room
        } else if segue.identifier == "showChannelinfo" {
            let destinationVC = segue.destination as! IGChannelInfoTableViewController
            destinationVC.selectedChannel = selectedChannelToSeeTheirInfo
            destinationVC.room = room
        } else if segue.identifier == "showGroupInfo" {
            let destinationTv = segue.destination as! IGGroupInfoTableViewController
            destinationTv.selectedGroup = selectedGroupToSeeTheirInfo
            destinationTv.room = room
        } else if segue.identifier == "showForwardMessageTable" {
            let navigationController = segue.destination as! IGNavigationController
            let destinationTv = navigationController.topViewController as! IGForwardMessageTableViewController
            destinationTv.delegate = self
        } else if segue.identifier == "showReportPage" {
            let destinationTv = segue.destination as! IGReport
            destinationTv.room = self.room
            destinationTv.messageId = self.reportMessageId!
        }
    }
 
}

////MARK: - UICollectionView
//extension UICollectionView {
//    func applyChangeset(_ changes: RealmChangeset) {
//        performBatchUpdates({
//            self.insertItems(at: changes.inserted.map { IndexPath(row: 0, section: $0) })
//            self.deleteItems(at: changes.updated.map { IndexPath(row: 0, section: $0) })
//            self.reloadItems(at: changes.deleted.map { IndexPath(row: 0, section: $0) })
//        }, completion: { (completed) in
//            
//        })
//    }
//}


//MARK: - IGMessageCollectionViewDataSource
extension IGMessageViewController: IGMessageCollectionViewDataSource {
    func collectionView(_ collectionView: IGMessageCollectionView, messageAt indexpath: IndexPath) -> IGRoomMessage {
        return messages![indexpath.section]
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if messages != nil {
            return messages!.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages![indexPath.section]
        var isIncommingMessage = true
        var shouldShowAvatar = false
        var isPreviousMessageFromSameSender = false
        var isNextMessageFromSameSender = false
        
        if message.type != .log {
            if messages!.indices.contains(indexPath.section + 1){
                let previousMessage = messages![(indexPath.section + 1)]
                if previousMessage.type != .log && message.authorHash == previousMessage.authorHash {
                    isPreviousMessageFromSameSender = true
                }
            }
            
            if messages!.indices.contains(indexPath.section - 1){
                let nextMessage = messages![(indexPath.section - 1)]
                if message.authorHash == nextMessage.authorHash {
                    isNextMessageFromSameSender = true
                }
            }
        }
        

        if let senderHash = message.authorHash {
            if senderHash == IGAppManager.sharedManager.authorHash() {
                isIncommingMessage = false
            }
        }
        
        if room?.groupRoom != nil {
            shouldShowAvatar = true
        }
        if !isIncommingMessage {
            shouldShowAvatar = false
        }
        
        
        if message.type == .log {
            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: logMessageCellIdentifer, for: indexPath) as! IGMessageLogCollectionViewCell
            let bubbleSize = IGMessageCollectionViewCellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(for: message)
            cell.setMessage(message,
                            isIncommingMessage: true,
                            shouldShowAvatar: false,
                            messageSizes:bubbleSize,
                            isPreviousMessageFromSameSender: false,
                            isNextMessageFromSameSender: false)
            return cell
            
        } else if (message.type == .text && message.forwardedFrom == nil) || (message.forwardedFrom != nil && message.forwardedFrom?.type == .text) {
            
            let cell: TextCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCell.cellReuseIdentifier(), for: indexPath) as! TextCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(for: message)
            cell.setMessage(message,isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            cell.delegate = self
            return cell
            
        } else if (message.type == .image && message.forwardedFrom == nil) || (message.forwardedFrom != nil && message.forwardedFrom?.type == .image) ||
                  (message.type == .imageAndText && message.forwardedFrom == nil) || (message.forwardedFrom != nil && message.forwardedFrom?.type == .imageAndText){
            
            let cell: ImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.cellReuseIdentifier(), for: indexPath) as! ImageCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(for: message)
            cell.setMessage(message,isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            cell.delegate = self
            return cell
            
        } else if (message.type == .video && message.forwardedFrom == nil) || (message.forwardedFrom != nil && message.forwardedFrom?.type == .video) ||
                  (message.type == .videoAndText && message.forwardedFrom == nil) || (message.forwardedFrom != nil && message.forwardedFrom?.type == .videoAndText){
            
            let cell: VideoCell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.cellReuseIdentifier(), for: indexPath) as! VideoCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(for: message)
            cell.setMessage(message,isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            cell.delegate = self
            return cell
            
        } else if (message.type == .gif && message.forwardedFrom == nil) || (message.forwardedFrom != nil && message.forwardedFrom?.type == .gif) ||
                  (message.type == .gifAndText && message.forwardedFrom == nil) || (message.forwardedFrom != nil && message.forwardedFrom?.type == .gifAndText){
            
            let cell: GifCell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCell.cellReuseIdentifier(), for: indexPath) as! GifCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(for: message)
            cell.setMessage(message,isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            cell.delegate = self
            return cell
            
        } else if (message.type == .contact && message.forwardedFrom == nil) || (message.forwardedFrom != nil && message.forwardedFrom?.type == .contact) {
            
            let cell: ContactCell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCell.cellReuseIdentifier(), for: indexPath) as! ContactCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(for: message)
            cell.setMessage(message,isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            cell.delegate = self
            return cell
            
        } else if (message.type == .file && message.forwardedFrom == nil) || (message.forwardedFrom != nil && message.forwardedFrom?.type == .file) ||
                  (message.type == .fileAndText && message.forwardedFrom == nil) || (message.forwardedFrom != nil && message.forwardedFrom?.type == .fileAndText) {
            
            let cell: FileCell = collectionView.dequeueReusableCell(withReuseIdentifier: FileCell.cellReuseIdentifier(), for: indexPath) as! FileCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(for: message)
            cell.setMessage(message,isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            cell.delegate = self
            return cell
            
        } else if (message.type == .voice && message.forwardedFrom == nil) || (message.forwardedFrom != nil && message.forwardedFrom?.type == .voice) {
            
            let cell: VoiceCell = collectionView.dequeueReusableCell(withReuseIdentifier: VoiceCell.cellReuseIdentifier(), for: indexPath) as! VoiceCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(for: message)
            cell.setMessage(message,isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            cell.delegate = self
            return cell
            
        } else if (message.type == .audio && message.forwardedFrom == nil) || (message.forwardedFrom != nil && message.forwardedFrom?.type == .audio) ||
                  (message.type == .audioAndText && message.forwardedFrom == nil) || (message.forwardedFrom != nil && message.forwardedFrom?.type == .audioAndText) {
            
            let cell: AudioCell = collectionView.dequeueReusableCell(withReuseIdentifier: AudioCell.cellReuseIdentifier(), for: indexPath) as! AudioCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(for: message)
            cell.setMessage(message,isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            cell.delegate = self
            return cell
            
        } else {
        
            let cell: IGMessageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: messageCellIdentifer, for: indexPath) as! IGMessageCollectionViewCell
            
            var isIncommingMessage = true
            if let senderHash = message.authorHash {
                if senderHash == IGAppManager.sharedManager.authorHash() {
                    isIncommingMessage = false
                }
            }
            
            
            var shouldShowAvatar = false
            if room?.groupRoom != nil {
                shouldShowAvatar = true
            }
            if !isIncommingMessage {
                shouldShowAvatar = false
            }
            
            
            var isPreviousMessageFromSameSender = false
            var isNextMessageFromSameSender = false
            

            if messages!.indices.contains(indexPath.section + 1){
                let previousMessage = messages![(indexPath.section + 1)]
                if previousMessage.type != .log && message.authorHash == previousMessage.authorHash {
                    isPreviousMessageFromSameSender = true
                }
            }
            
            if messages!.indices.contains(indexPath.section - 1){
                let nextMessage = messages![(indexPath.section - 1)]
                if message.authorHash == nextMessage.authorHash {
                    isNextMessageFromSameSender = true
                }
            }
        
            let bubbleSize = IGMessageCollectionViewCellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(for: message)
            cell.setMessage(message,
                            isIncommingMessage: isIncommingMessage,
                            shouldShowAvatar: shouldShowAvatar,
                            messageSizes:bubbleSize,
                            isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,
                            isNextMessageFromSameSender: isNextMessageFromSameSender)
            cell.delegate = self
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        var shouldShowFooter = false
        
        if let message = messages?[section] {
            if message.shouldFetchBefore {
                shouldShowFooter = true
            } else if section < messages!.count - 1, let previousMessage =  messages?[section + 1] {
                let thisMessageDateComponents     = Calendar.current.dateComponents([.year, .month, .day], from: message.creationTime!)
                let previousMessageDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: previousMessage.creationTime!)
                
                if thisMessageDateComponents.year == previousMessageDateComponents.year &&
                    thisMessageDateComponents.month == previousMessageDateComponents.month &&
                    thisMessageDateComponents.day == previousMessageDateComponents.day
                {
                    
                } else {
                    shouldShowFooter = true
                }
            } else {
                //first message in room -> always show time
                shouldShowFooter = true
            }
        }
        
        if shouldShowFooter {
            return CGSize(width: 35, height: 30.0)
        } else {
            return CGSize(width: 0.001, height: 0.001)//CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableview = UICollectionReusableView()
        if kind == UICollectionElementKindSectionFooter {
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
            
            if let message = messages?[indexPath.section] {
                if message.shouldFetchBefore {
                    header.setText("Loading ...")
                } else {
                    
                    let dayTimePeriodFormatter = DateFormatter()
                    dayTimePeriodFormatter.dateFormat = "MMMM dd"
                    dayTimePeriodFormatter.calendar = Calendar.current
                    let dateString = dayTimePeriodFormatter.string(from: message.creationTime!)
                    header.setText(dateString)
                }
            }
            reusableview = header
        }
        return reusableview
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension IGMessageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = messages![indexPath.section]
        let frame = self.collectionView.layout.sizeCell(for: message).bubbleSize
        
        return CGSize(width: self.collectionView.frame.width, height: frame.height+5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.inputTextView.resignFirstResponder()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let message = messages![indexPath.section]
        if (messages!.count < 20 && lowerAllow) { // HINT: this number(20) should set lower than getMessageLimit(25) for work correct
            lowerAllow = false
            
            let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false", self.room!.id)
            messages = try! Realm().objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties)
            updateObserver()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.fetchRoomHistoryIfPossibleBefore(message: message)
            }
        } else if (messages!.count < 20 || messages!.indices.contains(indexPath.section + 1)) && message.shouldFetchBefore {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.fetchRoomHistoryIfPossibleBefore(message: message, forceGetHistory: true)
            }
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.collectionView.numberOfSections == 0 {
            return
        }
        
        let spaceToTop = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height
        if spaceToTop < self.scrollToTopLimit {
            
            if hasLocal {
                if allowForGetHistoryLocal {
                    allowForGetHistoryLocal = false
                    messages = findAllMessages()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.allowForGetHistoryLocal = true
                    }
                }
            } else {
                let predicate = NSPredicate(format: "roomId = %lld", self.room!.id)
                if let message = try! Realm().objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties).last {
                    if isFirstHistory {
                        let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false", self.room!.id)
                        messages = try! Realm().objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties)
                        updateObserver()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.fetchRoomHistoryIfPossibleBefore(message: message)
                        }
                    } else {
                        self.fetchRoomHistoryIfPossibleBefore(message: message)
                    }
                }
            }
        }
        
        //100 is an arbitrary number. can be anything
        if scrollView.contentOffset.y > 100 {
            self.scrollToBottomContainerView.isHidden = false
        } else {
            if room!.isReadOnly {
                scrollToBottomContainerViewConstraint.constant = -40
            }
            self.scrollToBottomContainerView.isHidden = true
        }
        
        let scrollOffset = scrollView.contentOffset.y;
        if (scrollOffset <= 300){ // reach end of scroll
            isEndOfScroll = true
        } else {
            isEndOfScroll = false
        }
    }
    
    public func fetchRoomHistoryWhenDbIsClear(){
        IGClientGetRoomHistoryRequest.Generator.generate(roomID: self.room!.id, firstMessageID: 0).success({ (responseProto) in
            DispatchQueue.main.async {
                if let roomHistoryReponse = responseProto as? IGPClientGetRoomHistoryResponse {
                    IGClientGetRoomHistoryRequest.Handler.interpret(response: roomHistoryReponse, roomId: self.room!.id)
                }
            }
        }).error({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .clinetGetRoomHistoryNoMoreMessage:
                    self.allowForGetHistory = false
                    break
                case .timeout:
                    self.allowForGetHistory = true
                    self.fetchRoomHistoryWhenDbIsClear()
                    break
                default:
                    self.allowForGetHistory = true
                    break
                }
            }
        }).send()
    }
    
    private func fetchRoomHistoryIfPossibleBefore(message: IGRoomMessage, forceGetHistory: Bool = false) {
        if !message.isLastMessage {
            
            if allowForGetHistory || forceGetHistory {
                allowForGetHistory = false
            
                IGClientGetRoomHistoryRequest.Generator.generate(roomID: self.room!.id, firstMessageID: message.id).success({ (responseProto) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.allowForGetHistory = true
                    }
                    
                    DispatchQueue.main.async {
                        IGFactory.shared.setMessageNeedsToFetchBefore(false, messageId: message.id, roomId: message.roomId)
                        switch responseProto {
                        case let roomHistoryReponse as IGPClientGetRoomHistoryResponse:
                            IGClientGetRoomHistoryRequest.Handler.interpret(response: roomHistoryReponse, roomId: self.room!.id)
                        default:
                            break
                        }
                    }
                }).error({ (errorCode, waitTime) in
                    DispatchQueue.main.async {
                        switch errorCode {
                        case .clinetGetRoomHistoryNoMoreMessage:
                            self.allowForGetHistory = false
                            IGFactory.shared.setMessageIsLastMesssageInRoom(messageId: message.id, roomId: message.roomId)
                            break
                        case .timeout:
                            self.allowForGetHistory = true
                            break
                        default:
                            self.allowForGetHistory = true
                            break
                        }
                    }
                }).send()
            }
        }
    }
}


//MARK: - GrowingTextViewDelegate
extension IGMessageViewController: GrowingTextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.setSendAndRecordButtonStates()
        self.sendTyping()
        typingStatusExpiryTimer.invalidate()
        typingStatusExpiryTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                       target:   self,
                                                       selector: #selector(sendCancelTyping),
                                                       userInfo: nil,
                                                       repeats:  false)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
//        self.sendTyping()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.sendCancelTyping()
    }
    
    func textViewDidChangeHeight(_ height: CGFloat) {
        inputTextViewHeight = height
        setInputBarHeight()
    }
    
    
    func setInputBarHeight() {
        let height = max(self.inputTextViewHeight - 16, 22)
        var inputBarHeight = height + 16.0
        if currentAttachment != nil {
            inputBarAttachmentViewBottomConstraint.constant = inputBarHeight + 8
            inputBarHeight += 36
            inputBarAttachmentView.isHidden = false
        } else {
            inputBarAttachmentViewBottomConstraint.constant = 0.0
            inputBarAttachmentView.isHidden = true
        }
        
        if selectedMessageToEdit != nil {
            inputBarOriginalMessageViewBottomConstraint.constant = inputBarHeight + 8
            inputBarHeight += 36.0
            inputBarOriginalMessageView.isHidden = false
        } else if selectedMessageToReply != nil {
            inputBarOriginalMessageViewBottomConstraint.constant = inputBarHeight + 8
            inputBarHeight += 36.0
            inputBarOriginalMessageView.isHidden = false
        } else if selectedMessageToForwardToThisRoom != nil {
            inputBarOriginalMessageViewBottomConstraint.constant = inputBarHeight + 8
            inputBarHeight += 36.0
            inputBarOriginalMessageView.isHidden = false
        } else {
            inputBarOriginalMessageViewBottomConstraint.constant = 0.0
            inputBarOriginalMessageView.isHidden = true
        }
        
        inputTextViewHeightConstraint.constant = height
        inputBarHeightConstraint.constant = inputBarHeight
        inputBarHeightContainerConstraint.constant = inputBarHeight + 16
//        UIView.animate(withDuration: 0.2) {
//            self.view.layoutIfNeeded()
//        }
        
        UIView.animate(withDuration: 0.2, animations: { 
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            self.setCollectionViewInset()
        })
    }
}

//MARK: - AVAudioRecorderDelegate
extension IGMessageViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        sendCancelRecoringVoice()
        if self.isRecordingVoice {
            self.didFinishRecording(success: flag)
            let filePath = recorder.url
            //discard file if time is too small
            
            //AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:avAudioRecorder.url options:nil];
            //CMTime time = asset.duration;
            //double durationInSeconds = CMTimeGetSeconds(time);
            let asset = AVURLAsset(url: filePath)
            let time = CMTimeGetSeconds(asset.duration)
            if time < 1.0 {
                return
            }
            do {
                let attachment = IGFile(name: filePath.lastPathComponent)
                
                let data = try Data(contentsOf: filePath)
                self.saveAttachmentToLocalStorage(data: data, fileNameOnDisk: filePath.lastPathComponent)
                attachment.fileNameOnDisk = filePath.lastPathComponent
                attachment.size = data.count
                attachment.type = .voice
                self.currentAttachment = attachment
                self.didTapOnSendButton(self.inputBarSendButton)
            } catch {
                //there was an error recording voice
            }
        }
        self.isRecordingVoice = false
    }
}

//MARK: - IGMessageGeneralCollectionViewCellDelegate
extension IGMessageViewController: IGMessageGeneralCollectionViewCellDelegate {
    func didTapAndHoldOnMessage(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell) {
        print(#function)
        let alertC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let copy = UIAlertAction(title: "Copy", style: .default, handler: { (action) in
            self.copyMessage(cellMessage)
        })
        let reply = UIAlertAction(title: "Reply", style: .default, handler: { (action) in
            self.replyMessage(cellMessage)
        })
        let forward = UIAlertAction(title: "Forward", style: .default, handler: { (action) in
            self.selectedMessageToForwardFromThisRoom = cellMessage
            self.performSegue(withIdentifier: "showForwardMessageTable", sender: self)
        })
        let edit = UIAlertAction(title: "Edit", style: .default, handler: { (action) in
            if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }else {
            self.editMessage(cellMessage)
            }
        })
        
        let report = UIAlertAction(title: "Report", style: .default, handler: { (action) in
            self.report(room: self.room!, message: cellMessage)
        })
        
        _ = UIAlertAction(title: "More", style: .default, handler: { (action) in
            for visibleCell in self.collectionView.visibleCells {
                let aCell = visibleCell as! IGMessageGeneralCollectionViewCell
                aCell.setMultipleSelectionMode(true)
            }
        })
        _ = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.deleteMessage(cellMessage)
        })
        let deleteForMe = UIAlertAction(title: "Delete for me", style: .destructive, handler: { (action) in
            self.deleteMessage(cellMessage)
        })
        let roomTitle = self.room?.title != nil ? self.room!.title! : ""
        let deleteForBoth = UIAlertAction(title: "Delete for me and " + roomTitle, style: .destructive, handler: { (action) in
            self.deleteMessage(cellMessage, both: true)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
        })
        
        //Copy
        alertC.addAction(copy)
        
        //Reply
        if !(room!.isReadOnly){
            alertC.addAction(reply)
        }
        
        //Forward
        alertC.addAction(forward)
        
        //Edit
        if cellMessage.authorHash == currentLoggedInUserAuthorHash ||
            (self.room!.type == .channel && self.room!.channelRoom!.role == .owner) ||
            (self.room!.type == .group   && self.room!.groupRoom!.role   == .owner)
        {
            alertC.addAction(edit)
        }
        
        alertC.addAction(report)
        //More (Temporary Disabled)
        //alertC.addAction(more)
        
        
        //Delete
        if cellMessage.authorHash == currentLoggedInUserAuthorHash ||
            (self.room!.type == .channel && self.room!.channelRoom!.role == .owner) ||
            (self.room!.type == .group   && self.room!.groupRoom!.role   == .owner)
        {
            //If user can delete message for all participants
            if (self.room!.type == .chat) &&
                (cellMessage.creationTime != nil) &&
                (Date().timeIntervalSince1970 - cellMessage.creationTime!.timeIntervalSince1970 < 2 * 3600)
            {
                alertC.addAction(deleteForMe)
                alertC.addAction(deleteForBoth)
            } else {
                alertC.addAction(deleteForMe)
            }
        }
        
        alertC.addAction(cancel)
        
        self.present(alertC, animated: true, completion: {
            
        })
    }
    
    func didTapOnAttachment(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell) {
        
        var finalMessage = cellMessage
        var roomMessageLists = self.messagesWithMedia
        
        if cellMessage.forwardedFrom != nil {
            roomMessageLists = self.messagesWithForwardedMedia
            finalMessage = cellMessage.forwardedFrom!
        }
        
        var attachmetVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: finalMessage.attachment!.primaryKeyId!)
        if attachmetVariableInCache == nil {
            let attachmentRef = ThreadSafeReference(to: finalMessage.attachment!)
            IGAttachmentManager.sharedManager.add(attachmentRef: attachmentRef)
            attachmetVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: finalMessage.attachment!.primaryKeyId!)
        }
        
        let attachment = attachmetVariableInCache!.value
        if attachment.status != .ready {
            return
        }
        
        switch finalMessage.type {
        case .image, .imageAndText:
            break
        case .video, .videoAndText:
            if let path = attachment.path() {
                let player = AVPlayer(url: path)
                let avController = AVPlayerViewController()
                avController.player = player
                player.play()
                present(avController, animated: true, completion: nil)
            }
            return
        case .voice , .audio :
            let musicPlayer = IGMusicViewController()
            musicPlayer.attachment = finalMessage.attachment
            self.present(musicPlayer, animated: true, completion: {
            })
            return
        default:
            return
        }
        
        let thisMessageInSharedMediaResult = roomMessageLists.filter("id == \(finalMessage.id)")
        var indexOfThis = 0
        if let this = thisMessageInSharedMediaResult.first {
            indexOfThis = roomMessageLists.index(of: this)!
        }
        
        var photos: [INSPhotoViewable] = Array(roomMessageLists.map { (message) -> IGMedia in
            return IGMedia(message: message, forwardedMedia: false)
        })
        
        let currentPhoto = photos[indexOfThis]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: nil)
        present(galleryPreview, animated: true, completion: nil)
    }
    
    func didTapOnForwardedAttachment(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell) {
        if let forwardedMsgType = cellMessage.forwardedFrom?.type {
        switch forwardedMsgType {
        case .audio , .voice :
            let musicPlayer = IGMusicViewController()
            musicPlayer.attachment = cellMessage.forwardedFrom?.attachment
            self.present(musicPlayer, animated: true, completion: {
            })
            break
        case .video, .videoAndText:
            if let path = cellMessage.forwardedFrom?.attachment?.path() {
                let player = AVPlayer(url: path)
                let avController = AVPlayerViewController()
                avController.player = player
                player.play()
                present(avController, animated: true, completion: nil)
            }
        default:
            break
        }
        }
    }
    
    func didTapOnOriginalMessageWhenReply(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell) {
        
    }
    
    func didTapOnSenderAvatar(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell) {
        if let sender = cellMessage.authorUser {
            self.selectedUserToSeeTheirInfo = sender
            self.performSegue(withIdentifier: "showUserInfo", sender: self)
        }
    }
    
    func didTapOnHashtag(hashtagText: String) {
        
        
    }
    
    func didTapOnMention(mentionText: String) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGClientResolveUsernameRequest.Generator.generate(username: mentionText).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let clientResolvedUsernameResponse as IGPClientResolveUsernameResponse:
                    let clientResponse = IGClientResolveUsernameRequest.Handler.interpret(response: clientResolvedUsernameResponse)
                    
                    switch clientResponse.clientResolveUsernametype {
                    case .user:
                        self.selectedUserToSeeTheirInfo = clientResponse.user
                        self.performSegue(withIdentifier: "showUserInfo", sender: self)
                    case .room:
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let messagesVc = storyBoard.instantiateViewController(withIdentifier: "messageViewController") as! IGMessageViewController
                        self.inputTextView.resignFirstResponder()
                        messagesVc.room = clientResponse.room
                        self.navigationController!.pushViewController(messagesVc, animated:false)

                        break
                    }
                default:
                    break
                }
                self.inputTextView.resignFirstResponder()
                self.hud.hide(animated: true)
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            self.hud.hide(animated: true)
        }).send()
    }
    
    func didTapOnURl(url: URL) {
        var urlString = url.absoluteString
        
        if urlString.contains("https://iGap.net/join") || urlString.contains("http://iGap.net/join") {
            didTapOnRoomLink(link: urlString)
            return
        }
        
        urlString = urlString.lowercased()
        
        if !(urlString.contains("https://")) && !(urlString.contains("http://")) {
            urlString = "http://" + urlString
        }
        if let urlToOpen = URL(string: urlString) {
            UIApplication.shared.openURL(urlToOpen)
        }
        //TODO: handle "igap.net/join"
    }
    func didTapOnRoomLink(link: String) {
        let token = link.chopPrefix(22)
        self.requestToCheckInvitedLink(invitedLink: token)
    }
    
    func joinRoombyInvitedLink(room:IGPRoom, invitedToken: String) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGClientJoinByInviteLinkRequest.Generator.generate(invitedToken: invitedToken).success({ (protoResponse) in
            DispatchQueue.main.async {
                if let _ = protoResponse as? IGPClientJoinByInviteLinkResponse {
                    IGFactory.shared.updateRoomParticipant(roomId: room.igpID, isParticipant: true)
                    let predicate = NSPredicate(format: "id = %lld", room.igpID)
                    if let roomInfo = try! Realm().objects(IGRoom.self).filter(predicate).first {
                        self.openChatAfterJoin(room: roomInfo)
                    }
                }
                self.hud.hide(animated: true)
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                case .clientJoinByInviteLinkForbidden:
                    let alert = UIAlertController(title: "Error", message: "Sorry,this group does not seem to exist.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                    
                case .clientJoinByInviteLinkAlreadyJoined:
                    self.openChatAfterJoin(room: IGRoom(igpRoom: room), before: true)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()

    }
    func requestToCheckInvitedLink(invitedLink: String) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGClinetCheckInviteLinkRequest.Generator.generate(invitedToken: invitedLink).success({ (protoResponse) in
            DispatchQueue.main.async {
                self.hud.hide(animated: true)
                if let clinetCheckInvitedlink = protoResponse as? IGPClientCheckInviteLinkResponse {
                    let alert = UIAlertController(title: "iGap", message: "Are you sure want to join \(clinetCheckInvitedlink.igpRoom.igpTitle)?", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.joinRoombyInvitedLink(room:clinetCheckInvitedlink.igpRoom, invitedToken: invitedLink)
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    alert.addAction(okAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
            
        }).send()
    }
    
    private func openChatAfterJoin(room: IGRoom, before:Bool = false){
        
        var beforeString = ""
        if before {
            beforeString = "before "
        }
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Success", message: "You joined \(beforeString)to \(room.title!)!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            let openNow = UIAlertAction(title: "Open Now", style: .default, handler: { (action) in
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let chatPage = storyboard.instantiateViewController(withIdentifier: "messageViewController") as! IGMessageViewController
                chatPage.room = room
                self.navigationController!.pushViewController(chatPage, animated: true)
            })
            alert.addAction(okAction)
            alert.addAction(openNow)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - IGForwardMessageDelegate
extension IGMessageViewController : IGForwardMessageDelegate {
    func didSelectRoomToForwardMessage(room: IGRoom) {
        if room.id == self.room?.id {
            self.forwardMessage(self.selectedMessageToForwardFromThisRoom!)
            return
        }
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let messagesVc = storyBoard.instantiateViewController(withIdentifier: "messageViewController") as! IGMessageViewController
        self.inputTextView.resignFirstResponder()
        messagesVc.room = room
        messagesVc.selectedMessageToForwardToThisRoom = self.selectedMessageToForwardFromThisRoom
        self.selectedMessageToForwardFromThisRoom = nil
        self.navigationController!.pushViewController(messagesVc, animated:false)
    }
}



//MARK: - StatusBar Tap
extension IGMessageViewController {
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
    func addNotificationObserverForTapOnStatusBar() {
        NotificationCenter.default.addObserver(forName: IGNotificationStatusBarTapped.name, object: .none, queue: .none) { _ in
            if self.collectionView.contentSize.height < self.collectionView.frame.height {
                return
            }
            //1200 is just an arbitrary number. can be anything
            let newOffsetY = min(self.collectionView.contentOffset.y + 1200, self.collectionView.contentSize.height - self.collectionView.frame.height + self.collectionView.contentInset.bottom)
            let newOffsett = CGPoint(x: 0, y: newOffsetY)
            self.collectionView.setContentOffset(newOffsett , animated: true)
        }
    }    
}

//MARK: - Set and cancel current action (typing, ...)
extension IGMessageViewController {
    fileprivate func sendTyping() {
        IGClientActionManager.shared.sendTyping(for: self.room!)
    }
    @objc fileprivate func sendCancelTyping() {
        typingStatusExpiryTimer.invalidate()
        IGClientActionManager.shared.cancelTying(for: self.room!)
    }
    
    fileprivate func sendRecordingVoice() {
        IGClientActionManager.shared.sendRecordingVoice(for: self.room!)
    }
    fileprivate func sendCancelRecoringVoice() {
        IGClientActionManager.shared.sendCancelRecoringVoice(for: self.room!)
    }
    
//    Capturing Image
//    Capturign Video
//    Sending Gif
//    Sending Location
//    Choosing Contact
//    Painting
    
}
extension String {
    func chopPrefix(_ count: Int = 1) -> String {
        return substring(from: index(startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return substring(to: index(endIndex, offsetBy: -count))
    }
}

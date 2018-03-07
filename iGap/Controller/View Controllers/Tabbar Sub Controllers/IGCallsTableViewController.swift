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
import RealmSwift

class IGCallsTableViewController: UITableViewController {
    
    var selectedRowUser : IGRegisteredUser?
    var cellIdentifer = IGCallListTableViewCell.cellReuseIdentifier()
    var callLogList: Results<IGRealmCallLog>!
    var notificationToken: NotificationToken?
    var isLoadingMore: Bool = false
    var numberOfCallLogFetchedInLastRequest: Int = -1
    let CALL_LOG_CONFIG: Int32 = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        let allLogs = try! Realm().objects(IGRealmCallLog.self)
        if !allLogs.isEmpty {
            try! realm.write {
                realm.delete(allLogs)
            }
        }
        
        
        let sortProperties = [SortDescriptor(keyPath: "offerTime", ascending: false)]
        callLogList = try! Realm().objects(IGRealmCallLog.self).sorted(by: sortProperties)
        
        self.tableView.register(IGCallListTableViewCell.nib(), forCellReuseIdentifier: IGCallListTableViewCell.cellReuseIdentifier())
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.view.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.tableView.tableHeaderView?.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        
        self.notificationToken = callLogList!.observe { (changes: RealmCollectionChange) in
            switch changes {
                
            case .initial:
                self.tableView.reloadData()
                break
                
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.endUpdates()
                break
                
            case .error(let err):
                fatalError("\(err)")
                break
            }
        }
        if IGAppManager.sharedManager.isUserLoggiedIn() {
            self.fetchCallLogList()
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.fetchCallLogList),
                                                   name: NSNotification.Name(rawValue: kIGUserLoggedInNotificationName),
                                                   object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.isUserInteractionEnabled = true
    }
    
    
    @objc private func fetchCallLogList() {
        IGSignalingGetLogRequest.Generator.generate(offset: 0, limit: CALL_LOG_CONFIG).success { (responseProtoMessage) in
            DispatchQueue.main.async {
                
                if let signalingResponse = responseProtoMessage as? IGPSignalingGetLogResponse {
                    self.numberOfCallLogFetchedInLastRequest = IGSignalingGetLogRequest.Handler.interpret(response: signalingResponse)
                }
                
            }}.error({ (errorCode, waitTime) in }).send()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callLogList!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: IGCallListTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifer) as! IGCallListTableViewCell
        cell.setCallLog(callLog: callLogList![indexPath.row])
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 82.0, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets.zero

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if IGCall.callPageIsEnable {
            return
        }
        
        selectedRowUser = callLogList![indexPath.row].registeredUser
        self.tableView.isUserInteractionEnabled = false
        
        let storyBoard = UIStoryboard(name: "Main" , bundle:nil)
        let callPage = storyBoard.instantiateViewController(withIdentifier: "IGCallShowing") as! IGCall
        callPage.userId = selectedRowUser!.id
        callPage.isIncommingCall = false
        self.present(callPage, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }
}


extension IGCallsTableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let remaining = scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y)
        if remaining < 100 {
            self.loadMore()
        }
    }
}


extension IGCallsTableViewController {
    func loadMore() {
        if !isLoadingMore && numberOfCallLogFetchedInLastRequest > 0 {
            isLoadingMore = true
            let offset = callLogList!.count
            IGSignalingGetLogRequest.Generator.generate(offset: Int32(offset), limit: CALL_LOG_CONFIG).success { (responseProtoMessage) in
                DispatchQueue.main.async {
                    
                    if let callLog = responseProtoMessage as? IGPSignalingGetLogResponse {
                        self.numberOfCallLogFetchedInLastRequest = IGSignalingGetLogRequest.Handler.interpret(response: callLog)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isLoadingMore = false
                    }
                }
                }.error({ (errorCode, waitTime) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isLoadingMore = false
                    }
                }).send()
        }
    }
}

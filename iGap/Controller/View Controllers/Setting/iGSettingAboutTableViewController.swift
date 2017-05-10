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
class IGSettingAboutTableViewController: UITableViewController , UIGestureRecognizerDelegate {
    
    var index : Int?
    var appstoreWebView : Bool = false
    @IBOutlet weak var appVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backImage = UIImage(named: "IG_Settigns_Bg")
        let backgroundImageView = UIImageView(image: backImage)
        self.tableView.backgroundView = backgroundImageView
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "About")
        navigationItem.navigationController = self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows : Int = 0
        switch section {
        case 0 :
            numberOfRows = 1
        case 1 :
            numberOfRows = 3
        default:
            break
        }
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                UIApplication.shared.openURL(URL(string: "itms://itunes.apple.com/us/app/igap/id1198257696?ls=1&mt=8")!)
            }
        }
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                index = indexPath.row
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToWebPage", sender: self)
            case 1:
                index = indexPath.row
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToWebPage", sender: self)
            case 2:
                index = indexPath.row
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToWebPage", sender: self)
            default:
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToWebPage" {
            let destination = segue.destination as! IGSettingAboutWebViewViewController
            switch index! {
            case 0:
                destination.pageUrl = "https://www.igap.net"
            case 1:
                destination.pageUrl = "https://blog.igap.net"
            case 2:
                destination.pageUrl = "https://support.igap.net"

                
            default:
                break
            }
            
        }
    }
}

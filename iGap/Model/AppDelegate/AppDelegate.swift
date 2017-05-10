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
import Fabric
import Crashlytics
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isNeedToSetNickname : Bool = true
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
//        let config = Realm.Configuration(schemaVersion: try! schemaVersionAtURL(Realm.Configuration.defaultConfiguration.fileURL!) + 1)
//        Realm.Configuration.defaultConfiguration = config
//        
//        _ = try! Realm()
        let config = Realm.Configuration(
            schemaVersion: 6,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                } else if (oldSchemaVersion < 2) {
                    //Logout users. due to the missing of authorHash
                } else if (oldSchemaVersion < 3) {
                    //version 0.0.5 build 290
                } else if (oldSchemaVersion < 4) {
                    //version 0.0.6 build 291
                } else if (oldSchemaVersion < 5) {
                    //version 0.0.7 build 292
                } else if (oldSchemaVersion < 6) {
                    //version 0.0.8 build 293
                }
                
                
        })
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
        
        
        Fabric.with([Crashlytics.self])
        _ = IGDatabaseManager.shared
        _ = IGWebSocketManager.sharedManager
        _ = IGFactory.shared
        UITabBar.appearance().tintColor = UIColor.organizationalColor()
        UserDefaults.standard.setValue(false, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable")
        
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        IGAppManager.sharedManager.setUserUpdateStatus(status: .exactly)
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if !IGAppManager.sharedManager.isUserPreviouslyLoggedIn() {
            logoutAndShowRegisterViewController()
        } 
    }

    func applicationWillTerminate(_ application: UIApplication) {
    
    }
    
    func logoutAndShowRegisterViewController() {
        IGAppManager.sharedManager.clearDataOnLogout()
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGSplashNavigationController")
        self.window?.rootViewController?.present(vc, animated: true, completion: {
            print("showed")
        })
    }
    func showRegistrationSetpProfileInfo() {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let setNicknameVC = storyboard.instantiateViewController(withIdentifier: "RegistrationStepProfileInfo")
        let navigationBar = UINavigationController(rootViewController: setNicknameVC)
        self.window?.rootViewController?.present(navigationBar, animated: true, completion: {
            self.isNeedToSetNickname = false
        })

    }
    
    func showLoginFaieldAlert() {
        //DispatchQueue.main.sync(execute: {
            let badLoginAC = UIAlertController(title: "Login Failed", message: "There was a problem logging you in. Please login again", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.logoutAndShowRegisterViewController()
            })
            badLoginAC.addAction(ok)
            self.window?.rootViewController?.present(badLoginAC, animated: true, completion: {
                print("showed")
            })
        //})
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let statusBarRect = UIApplication.shared.statusBarFrame
        guard let touchPoint = event?.allTouches?.first?.location(in: self.window) else { return }
        
        if statusBarRect.contains(touchPoint) {
            NotificationCenter.default.post(statusBarTappedNotification)
        }
    }
    
}


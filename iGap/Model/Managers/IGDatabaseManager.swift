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

class IGDatabaseManager: NSObject {
    static let shared = IGDatabaseManager()
    
    private var databaseThread: DMThread!
    var realm: Realm {
        return try! Realm()
    }
    
    private override init() {
        super.init()
        databaseThread = DMThread(start: true, queue: nil)
    }
    
    func perfrmOnDatabaseThread(_ block: @escaping ()->()) {
        databaseThread.enqueue {
            block()
        }
    }
    
    func emptyQueue() {
        databaseThread.emptyQueue()
    }
}

//extension IGDatabaseManager {
//    //use this function for unmanaged objects (i.e. without any associated realm object)
//    func add(_ object: Object, update: Bool) {
////        self.perfrmOnDatabaseThread {
////            print(#function + " \(Thread.current) -> \(String(describing: type(of: object)))")
////            
////            if object is IGRoomMessage {
//////                var object2 = IGRoomMessage(value: object)
//////                try! self.realm.write {
//////                    self.realm.add(object2, update: update)
//////                }
////            } else if object is IGContact {
////                
////            } else if object is IGRegisteredUser {
////                
////            } else {
////            
////                try! self.realm.write {
////                    self.realm.add(object, update: update)
////                }
////            }
////        }
//    }
//    
//    //object with an associated realm object sould first be converted to a ThreadSafeRefrece
//    //via let objectRef = ThreadSafeReference(to: object) and then passed to this function 
//    //to use in another realm (i.e. DatabaseManager's realm)
//    func threadSafeAndAdd(_ object: Object, update: Bool) {
////        let objectRef = ThreadSafeReference(to: object)
////        self.perfrmOnDatabaseThread {
////            guard let object = self.realm.resolve(objectRef) else {
////                return // object was deleted
////            }
////            
////            print(#function + " \(String(describing: type(of: object)))")
////            try! self.realm.write {
////                self.realm.add(object, update: update)
////            }
////        }
//    }
//    
//    func delete(_ object: Object) {
////        let objectRef = ThreadSafeReference(to: object)
////        self.perfrmOnDatabaseThread {
////            print(#function + " \(Thread.current))")
////            guard let object = self.realm.resolve(objectRef) else {
////                return // object was deleted
////            }
////            try! self.realm.write {
////                self.realm.delete(object)
////            }
////        }
//    }
//    
//    func write(_ block: @escaping ()->()) {
////        self.perfrmOnDatabaseThread {
////            print(#function + " \(Thread.current))")
//////            try! self.realm.write {
//////                block()
//////            }
////        }
//    }
//    
//    func write2(_ block: @escaping ()->()) {
//        self.perfrmOnDatabaseThread {
//            print(#function + " \(Thread.current))")
//            try! self.realm.write {
//                block()
//            }
//        }
//    }
//    
//    
//    
//    func commit(_ block: @escaping ()->()) {
////        self.perfrmOnDatabaseThread {
////            print(#function + " \(Thread.current))")
////            self.realm.beginWrite()
////            block()
////            try! self.realm.commitWrite()  //this will notify the collection view to update itself
////        }
//    }
//}

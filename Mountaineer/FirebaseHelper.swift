//
//  FirebaseHelper.swift
//  Mountaineer
//
//  Created by Nick Raff on 5/2/16.
//  Copyright © 2016 Nick Raff. All rights reserved.
//

import Foundation
import Firebase

class FirebaseHelper: NSObject {
    let RootRef = Firebase(url: "https://mountaineer.firebaseio.com")
    var sessionClass = SessionsViewController()
    
//    func updateTableView() {
//        
//        let tableRef = RootRef.childByAppendingPath("users/\(RootRef.authData.uid)/sessions")
//        tableRef.queryOrderedByKey().observeEventType(.Value, withBlock: { snapshot in
//            
//            // 2
//            var newSessions = [Session]()
//            
//            // 3
//            for session in snapshot.children {
//                // 4
//                let anotherSession = Session(snapshot: session as! FDataSnapshot)
//                newSessions.append(anotherSession)
//            }
//
//            
//        })
//
//    }
}

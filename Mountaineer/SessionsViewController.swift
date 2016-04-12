//
//  ViewController.swift
//  SkiBum
//
//  Created by Nick Raff on 7/22/15.
//  Copyright (c) 2015 Nick Raff. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseUI
import Mixpanel

class SessionsViewController: UIViewController {
    //create a firebase reference
    let RootRef = Firebase(url: "https://mountaineer.firebaseio.com")
    //create the firebase datasource
    var dataSource: FirebaseTableViewDataSource!
    var mixpanel: Mixpanel!
    var locationStuff = LocationHelper()
    var sessionName: String?
    var addingSession: Bool = true
    
    override func viewDidLoad() {
        
        
        //give the firebase datasource its location
//        dataSource = FirebaseTableViewDataSource(ref: RootRef.childByAppendingPath("users/\(RootRef.authData.uid)/sessions"), cellClass: SessionTableViewCell.self, cellReuseIdentifier: "sessionCell", view: self.sessionsTableView)
        
//        dataSource = FirebaseTableViewDataSource(ref: RootRef.childByAppendingPath("users/\(RootRef.authData.uid)/sessions"), prototypeReuseIdentifier: "sessionCell", view: self.sessionsTableView)
        
//        dataSource = FirebaseTableViewDataSource(ref: RootRef.childByAppendingPath("users/\(RootRef.authData.uid)/sessions"), modelClass: SessionTableViewCell.self, prototypeReuseIdentifier: "sessionCell", view: sessionsTableView)
        
        self.dataSource = FirebaseTableViewDataSource(ref: RootRef.childByAppendingPath("users/\(RootRef.authData.uid)/sessions"), cellClass: SessionTableViewCell.self, cellReuseIdentifier: "sessionCell", view: self.sessionsTableView)
        
//        dataSource = FirebaseTableViewDataSource(ref: RootRef.childByAppendingPath("users/\(RootRef.authData.uid)/sessions"), prototypeReuseIdentifier: "sessionCell", view: sessionsTableView)
        
        
        self.dataSource.populateCellWithBlock {(cell, snap: NSObject) -> Void in
            // Populate cell as you see fit, like as below
            let STVC: SessionTableViewCell = cell as! SessionTableViewCell
            let snapshot: FDataSnapshot = snap as! FDataSnapshot
            
            STVC.textLabel!.font = UIFont(name: "SF-UI-Display-Bold.otf", size: 18)
            STVC.textLabel!.text = snapshot.value.objectForKey("sessionTitle") as? String
//            STVC.detailTextLabel!.text = snapshot.value.objectForKey("dateCreated") as? String
            STVC.imageView!.sendSubviewToBack(STVC.imageView!)
            STVC.imageView!.image = UIImage(named:"cell_bg\(snapshot.value.objectForKey("imageID")!)")
            
            
            STVC.sessionName?.text = snapshot.value.objectForKey("sessionTitle") as? String
//            STVC.createdDate?.text = snapshot.value.objectForKey("dateCreated") as? String
//            STVC.SessionID?.text = snapshot.key
//            STVC.randomImage?.image = UIImage(named:"cell_bg\(snapshot.value.objectForKey("imageID"))")
        }
        
        self.sessionsTableView.dataSource = self.dataSource
        
        mixpanel = Mixpanel.sharedInstance()
        newShredView.hidden = false
        super.viewDidLoad()
        sessionsTableView.dataSource = dataSource
        sessionsTableView.delegate = self
        myNavBar.setTitleVerticalPositionAdjustment(-8, forBarMetrics: .Default)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        sessionsTableView.reloadData()
    }
    
//    override func viewWillAppear(animated: Bool) {
//      sessionsTableView.reloadData()  
//    }
    
    override func viewDidDisappear(animated: Bool) {
        newShredView.hidden = true
    }

    
    @IBOutlet weak var newShredView: UIView!
    @IBOutlet weak var myNavBar: UINavigationBar!
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case "BackAndSave":
        
                print("I take it \(identifier)")
                
            default:
                //println("No one loves \(identifier)")
                mixpanel.track("Add Session Started", properties: ["Recording": "End without data/saving"])
            }
            
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showNewSession") {
            //I think this step might be unnecessary because with the global variable in firebase I'll just query everything based on that, actually keep the steps but set a variable in NewSessionViewController equal to the sessionID
            let sessionViewController = segue.destinationViewController as! NewSessionViewController
            //if the sessionID is not nill then isAddSession = true and set a variable in the NewSessionViewController = sessionID
            
            sessionViewController.isAddSession = self.addingSession
            
        }
        if (segue.identifier == "settings") {
            mixpanel.track("Settings", properties: ["Options": "Opened"])
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var sessionsTableView: UITableView!
 
}

//extension SessionsViewController: UITableViewDataSource {
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("sessionCell", forIndexPath: indexPath) as! SessionTableViewCell //1
//        
//        let row = indexPath.row
//        let session = sessions[row] as Session
//        cell.session = session
//
//        
//        return cell
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if sessions?.count < 1 {
//          newShredView.hidden = false
//        }
//        else {
//          newShredView.hidden = true
//        }
//        return Int(sessions?.count ?? 0)
//    }
//    
//}

extension SessionsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let ref = Firebase(url: "https://mountaineer.firebaseio.com/users/\(RootRef.authData.uid)")
        //get the selected cell as a SessionTableViewCell
        let cellSession = sessionsTableView.cellForRowAtIndexPath(indexPath)! as! SessionTableViewCell
        //check that the cellSession.sessionName is not nil
        if let sessionID = cellSession.SessionID.text {
            //if sessionName is not nil then set the global variable in firebase (currentSession) to the sessionName - should be sessionID in future
            let sessionID = sessionID
            let selectedSession = ["sessionID": sessionID]
            ref.setValue(selectedSession)
        }
        //track event in mixpanel
        mixpanel.track("Old Session", properties: ["Viewing?": "Yes"])
        //perform the segue (be sure to add functionality into the view did load method to load up the correct session
        self.performSegueWithIdentifier("showNewSession", sender: self)
        
        self.addingSession = false
        
    }
    
    // 3
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // 4
    
    //implement delete functionality later
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if (editingStyle == .Delete) {
//            mixpanel.track("Old Session", properties: ["Viewing?": "Deleted"])
//            let session = sessions[indexPath.row] as Object
//            
//            let realm = Realm
//            
//            realm.write() {
//                realm.delete(session)
//            }
//            
//            sessions = realm.objects(Session).sorted("Date", ascending: false)
//        }
        print("Delete")
    }
    
    

}
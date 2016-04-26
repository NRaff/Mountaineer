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
    //var dataSource: FirebaseTableViewDataSource!
    var mixpanel: Mixpanel!
    var locationStuff = LocationHelper()
    var sessionName: String?
    var addingSession: Bool = true
    var sessions = [Session]()
    var selectedSession: Session?
    var sessionUnits:Bool = false
    
    var segueIdentifier = "goBack"
    
    override func viewDidLoad() {
        mixpanel = Mixpanel.sharedInstance()
        newShredView.hidden = false
        super.viewDidLoad()

        myNavBar.setTitleVerticalPositionAdjustment(-8, forBarMetrics: .Default)
    }
    
    override func viewWillAppear(animated: Bool) {
        if RootRef.authData != nil {
            let tableRef = RootRef.childByAppendingPath("users/\(RootRef.authData.uid)/sessions")
            tableRef.queryOrderedByKey().observeEventType(.Value, withBlock: { snapshot in
                
                // 2
                var newSessions = [Session]()
                
                // 3
                for session in snapshot.children {
                    // 4
                    let anotherSession = Session(snapshot: session as! FDataSnapshot)
                    newSessions.append(anotherSession)
                }
                
                // 5
                self.sessions = newSessions
                self.sessionsTableView.reloadData()
            })
        }
        else
        {
            print("logoutSegue performed")
        }

    }
    
    override func viewDidDisappear(animated: Bool) {
        newShredView.hidden = true
    }
    
//    @IBAction func unwindToLoginViewController(segue: UIStoryboardSegue) {
//        if let identifier = segue.identifier {
//            if identifier == "logoutSegue" {
//                print("logoutSegue performed")
//            }
//        }
//    }
    
//    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
//        if segueIdentifier == "goBack" {
//            return true
//        }
//        else {
//            return false
//        }
//    }
    
    
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
            sessionViewController.sessionUnits = self.sessionUnits
            sessionViewController.currentSession = self.selectedSession
            
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

extension SessionsViewController: UITableViewDelegate {

    // MARK: UITableView Delegate methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sessions.count < 1 {
            newShredView.hidden = false
        }
        else {
            newShredView.hidden = true
        }
        return Int(sessions.count ?? 0)
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = sessionsTableView.dequeueReusableCellWithIdentifier("sessionCell") as! SessionTableViewCell!
        let anotherSession = sessions[indexPath.row]
        
        cell.sessionName.text = anotherSession.sessionTitle
        cell.createdDate.text = anotherSession.dateCreated
        cell.randomImage.image = UIImage(named: "cell_bg\(anotherSession.imageID)")
        
        return cell
    }
    
     func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){        
        if (editingStyle == .Delete) {
            mixpanel.track("Old Session", properties: ["Viewing?": "Deleted"])
            // 1
            let session = sessions[indexPath.row]
            // 2
            session.ref?.removeValue()
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedSession = sessions[indexPath.row]
        addingSession = false
        
        //track event in mixpanel
        mixpanel.track("Old Session", properties: ["Viewing?": "Yes"])
        //perform the segue (be sure to add functionality into the view did load method to load up the correct session
        self.performSegueWithIdentifier("showNewSession", sender: self)
        
    }

}
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
import Mixpanel

class SessionsViewController: UIViewController {
// MARK: - Variables and References
    let RootRef = Firebase(url: "https://mountaineer.firebaseio.com")

    var mixpanel: Mixpanel!
    var locationStuff = LocationHelper()
    var sessionName: String?
    var addingSession: Bool = true
    var sessions = [Session]()
    var selectedSession: Session?
    var sessionUnits:Bool = false
    
    var segueIdentifier = "goBack"
    
// MARK: - IBOutlets
    @IBOutlet weak var newShredView: UIView!
    @IBOutlet weak var myNavBar: UINavigationBar!
    @IBOutlet weak var sessionsTableView: UITableView!
    
    
// MARK: - Base Functions
    override func viewDidLoad() {
        mixpanel = Mixpanel.sharedInstance()
        newShredView.hidden = false
        super.viewDidLoad()

        myNavBar.setTitleVerticalPositionAdjustment(-8, forBarMetrics: .Default)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.updateTableView()
    }
    
    override func viewDidDisappear(animated: Bool) {
        newShredView.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
// MARK: - Segue Stuff
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showNewSession") {
            
            let sessionViewController = segue.destinationViewController as! NewSessionViewController
            sessionViewController.isAddSession = self.addingSession
            sessionViewController.sessionUnits = self.sessionUnits
            sessionViewController.currentSession = self.selectedSession
            
        }
        if (segue.identifier == "settings") {
            
            mixpanel.track("Settings", properties: ["Options": "Opened"])
            
        }
    }

}

// MARK: - Firebase Helper Extension
extension SessionsViewController {
    func updateTableView() {
        if RootRef.authData != nil {
            let tableRef = RootRef.childByAppendingPath("users/\(RootRef.authData.uid)/sessions")
            tableRef.queryOrderedByKey().observeEventType(.Value, withBlock: { snapshot in

                var newSessions = [Session]()

                for session in snapshot.children {
                    
                    let anotherSession = Session(snapshot: session as! FDataSnapshot)
                    newSessions.append(anotherSession)
                    
                }
                
                self.sessions = newSessions
                self.sessionsTableView.reloadData()
                
            })
        }
        else
        {
            print("logoutSegue performed")
        }
    }
}

// MARK: - Table View Delegate Extension
extension SessionsViewController: UITableViewDelegate {
    
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

        self.performSegueWithIdentifier("showNewSession", sender: self)
        
    }

}
//
//  NewSessionViewController.swift
//  SkiBum
//
//  Created by Nick Raff on 7/27/15.
//  Copyright (c) 2015 Nick Raff. All rights reserved.
//

import UIKit
//import Realm
//import RealmSwift
import Firebase
import CoreLocation
import Mixpanel

class NewSessionViewController: UIViewController {

    let mixpanel: Mixpanel = Mixpanel.sharedInstance()
    //let RootRef: Firebase = Firebase(url: "https://mountaineer.firebaseio.com")
    let settingsRef: Firebase = Firebase(url: "https://mountaineer.firebaseio.com/users")
    
    var locationInfo = LocationHelper()
    var isAddSession = true
//    var currentSession: Session?
    var sessionUnits: Bool?

    
    var statsTimer: NSTimer?
    var sessionDuration: NSTimer?
    var aveVelocity: NSTimer?
    
    var metricConversionKPH = 3.6
    var metricConversionKM = 0.001
    var imperialConvMPH = 2.23694
    var imperialConvMi = 0.000621371
    var imperialConvFt = 3.28084
    
    var backImageID: Int = 0
    
    //old session vars
    var sessionID: String?
    var thisSessionUnits: Bool?
    var OsessionTitle: String!
    var OsessionTime: String!
    var OimageID: Int!
    var OtopSpeed: Double!
    var OaverageSpeed: Double!
    var OpeakAltitude: Double!
    var OtotalDistance: Double!
    
//    let settings = SettingsViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTrek_tf.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        locationInfo.startedLocation()
        
        //if user is adding a session then display the add fields
        if isAddSession == true {
            
            //choose a random image to display as the background
            backImageID = Int(arc4random_uniform(8) + 1)
            backImage.image = UIImage(named: "detailsbg\(backImageID)")
            
            //hide the current session display objects
            back_btn.hidden = true
            sessionTime.hidden = true
            titleLabel.hidden = true
            end_btn.hidden = true
            
            //color the text field placeholder text
            nameTrek_tf.attributedPlaceholder = NSAttributedString(string:"NAME YOUR SESSION",
                attributes:[NSForegroundColorAttributeName: UIColor.lightTextColor()])
            
            //track the event
            mixpanel.track("Add Session Started", properties: ["Event": "Opened Scene"])
            
        }
            
        //otherwise hide the editable fields and display the recorded topspeed and peak altitude
        else{
            //set the settings variables based on the selected sessions firebase
            settingsRef.queryOrderedByChild("\(settingsRef.authData.uid)").observeEventType(.ChildAdded, withBlock: { snapshot in
                if let units = snapshot.value["sessionUnits"] as? Bool {
                    self.sessionUnits = units
                    print("\(snapshot.key) was \(units)")
                }
                if let sId = snapshot.value["sessionID"] as? String {
                    self.sessionID = sId
                }
                
            })
            
            //set the variable thisSessionUnits to the firebase setting (must have already set the selected sessionID)
            settingsRef.queryOrderedByChild("\(settingsRef.authData.uid)/sessions/\(sessionID)").observeEventType(.ChildAdded, withBlock: { snapshot in
                if let units = snapshot.value["thisSessionUnits"] as? Bool {
                    self.thisSessionUnits = units
                }
                if let sTitle = snapshot.value["sessionTitle"] as? String {
                    self.OsessionTitle = sTitle
                }
                if let sTime = snapshot.value["sessionTime"] as? String {
                    self.OsessionTime = sTime
                }
                if let sImageID = snapshot.value["imageID"] as? Int {
                    self.OimageID = sImageID
                }
                if let sTopSpeed = snapshot.value["topSpeed"] as? Double {
                    self.OtopSpeed = sTopSpeed
                }
                if let sAverageSpeed = snapshot.value["averageSpeed"] as? Double {
                    self.OaverageSpeed = sAverageSpeed
                }
                if let sPeakAltitude = snapshot.value["peakAltitude"] as? Double {
                    self.OpeakAltitude = sPeakAltitude
                }
                if let sTotalDistance = snapshot.value["totalDistance"] as? Double {
                    self.OtotalDistance = sTotalDistance
                }
            })
            
            //hide and unhide things
            unhideNeeded()
            hideUnneeded()
            end_btn.hidden = true
            
            //pull data from the old session to be displayed in the session view objects
            titleLabel.text = OsessionTitle     //currentSession!.sessionTitle
            sessionTime.text  = OsessionTime    //currentSession!.sessionTime
            //select the correct image
            backImage.image = UIImage(named: "detailsbg\(OimageID)")    //UIImage(named: "detailsbg\(currentSession!.imageID)")
            
            //if the current session units are set as imperial...
            if sessionUnits == false {
            topSpeed_lb.text = "\(OtopSpeed) mph"   //String(currentSession!.topSpeed) + " mph"
            peakAltitude_lb.text = "\(OpeakAltitude) ft"    //String(currentSession!.peakAltitude) + " ft"
            totalDistance_lb.text = "\(OtotalDistance) mi"  //String(currentSession!.totalDistance) + " mi"
            currentSpeed_lb.text = "\(OaverageSpeed) mph"   //"\(currentSession!.averageSpeed) mph"
            }
                
            //if the current session units are set as metric...
            else {
                topSpeed_lb.text = "\(OtopSpeed) kph"   //String(currentSession!.topSpeed) + " kph"
                peakAltitude_lb.text = "\(OpeakAltitude) m"     //String(currentSession!.peakAltitude) + " m"
                totalDistance_lb.text = "\(OtotalDistance) km"  //String(currentSession!.totalDistance) + " km"
                currentSpeed_lb.text = "\(OaverageSpeed) kph"   //"\(currentSession!.averageSpeed) kph"
            }
            
            //track this event
            mixpanel.track("Old Session", properties: ["Viewing?": "Opened Old Session"])
        }

       //update the different stats every second
       self.statsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateCurrentStats", userInfo: nil, repeats: true)

}

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    @IBOutlet weak var end_btn: UIButton!
    @IBOutlet weak var totalDistance_lb: UILabel!
    @IBOutlet weak var currentSpeed_lb: UILabel!
    @IBOutlet weak var topSpeed_lb: UILabel!
    @IBOutlet weak var currentAltitude_lb: UILabel!
    @IBOutlet weak var peakAltitude_lb: UILabel!
    @IBOutlet weak var sessionTime: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTrek_tf: UITextField!
    @IBOutlet weak var cancel_btn: UIButton!
    @IBOutlet weak var startNew_btn: UIButton!
    @IBOutlet weak var back_btn: UIButton!
    
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var editView: UIView!
    
    
    func unhideNeeded(){
       back_btn.hidden = false
       titleLabel.hidden = false
       sessionTime.hidden = false
       end_btn.hidden = false
    }
    
    func hideUnneeded(){
        nameTrek_tf.hidden = true
        cancel_btn.hidden = true
        startNew_btn.hidden = true
        editView.hidden = true
    }
    
    
    @IBAction func backCancelButton(sender: AnyObject) {
        //if the user is creating a new session then show the alert with options:
        if isAddSession == true {
        let cancelAlert = UIAlertController(title: "Cancel Session?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        cancelAlert.addAction(UIAlertAction(title: "Save & Exit", style: .Default, handler: { (action: UIAlertAction) in
            //if save and exit is chosen then save the data, track the event, then go back to AllSessions
            self.saveStuff()
            self.mixpanel.track("Back/Cancel Alert", properties: ["Options": "Save Session (Alert)"])
            self.performSegueWithIdentifier("segueToAlert", sender: nil)
        }))
        
        cancelAlert.addAction(UIAlertAction(title: "Keep Shredding!", style: .Default, handler: { (action: UIAlertAction) in
            //if 'keep shredding' is chosen then don't do anything and continue the session
            self.mixpanel.track("Back/Cancel Alert", properties: ["Options": "Continue Session (Alert)"])
            }))
        //show the alert
        presentViewController(cancelAlert, animated: true, completion: nil)
        }
            
        //if the user is viewing an old session then just segue back to the AllSessions view instead of pushing an alert
        else {
            self.performSegueWithIdentifier("segueToAlert", sender: nil)
            mixpanel.track("Old Session", properties: ["Viewing?": "No - Left Session"])
        }
    }
    
    @IBAction func startNewSessionBtn(sender: AnyObject) {
        
        //if the user has given the session a name then...
        if nameTrek_tf.text != "" {
        //track
        mixpanel.track("Add Session Started", properties: ["Recording": "Check Button - OK"])
        hideUnneeded()
            
        //start the timer that asks for the average speed every 5 seconds
        aveVelocity = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "getAverageSpeed", userInfo: nil, repeats: true)
            
        //start the timer that adds updates the UI timer
        sessionDuration = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tripDuration", userInfo: nil, repeats: true)
        titleLabel.text = nameTrek_tf.text
            
        //hide the keyboard
        nameTrek_tf.resignFirstResponder()
        unhideNeeded()
        
        }
        
        //if the user forgot to give the session a name then...
        else {
            //if the user didn't give the session a name, then give this error message
            let alert = UIAlertView()
            alert.title = "Oops!"
            alert.message = "Make sure you've named your trip!"
            alert.addButtonWithTitle("OK")
            alert.show()
            mixpanel.track("Add Session Started", properties: ["Recording": "Check Button - Needs Name"])
        }

    }
    
    @IBAction func endButton(sender: AnyObject) {
        //when 'end' is clicked save all data and segue to AllSessions
        saveStuff()
        self.performSegueWithIdentifier("segueOnEnd", sender: nil)
        mixpanel.track("Back/Cancel Alert", properties: ["Options": "Saved with End"])
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        locationInfo.locationManager.stopUpdatingLocation()
        
        //reset location stuff
        locationInfo.startLocation = nil
        locationInfo.nextLocation = nil
        
        //stop all timers so that stats stop updating
        statsTimer?.invalidate()
        sessionDuration?.invalidate()
        aveVelocity?.invalidate()
    }

}

extension NewSessionViewController: UITextFieldDelegate {
    
    //when the keyboard 'Go' button is tapped...
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        //if the text field is not blank then...
        if nameTrek_tf.text != "" {
            hideUnneeded()
            //start all the timers to update stats
            aveVelocity = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "getAverageSpeed", userInfo: nil, repeats: true)
            sessionDuration = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tripDuration", userInfo: nil, repeats: true)
            titleLabel.text = nameTrek_tf.text
            nameTrek_tf.resignFirstResponder()
            unhideNeeded()
            mixpanel.track("Add Session Started", properties: ["Recording": "Keyboard 'GO' - OK"])
        }
            
        else {
            //if the user didn't give the session a name, then give this error message
            let alert = UIAlertView()
            alert.title = "Oops!"
            alert.message = "Make sure you've named your trip!"
            alert.addButtonWithTitle("OK")
            alert.show()
            mixpanel.track("Add Session Started", properties: ["Recording": "Keyboard 'GO' - Needs Name"])
        }
        return true
    }
    
    //if a user taps outside the text field then hide the keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        nameTrek_tf.resignFirstResponder()
        
    }
}

//MARK: - All Helper Functions

extension NewSessionViewController {
    
    //use this function to save the data
    func saveStuff(){
        
        //if the user is creating a new session and it does have a name
        if isAddSession == true && cancel_btn.hidden == true {
            //init all temp variables
            var sessionID: String
            var imageID: Int
            var sessionTitle: String
            var date: String
            
            var eachSessionUnits: Bool
            var topSpeed: Double
            var peakAltitude: Double
            var totalDistance: Double
            var averageSpeed: Double
            
            var sessionTime: String
            
            //create a new 'Session'
//            currentSession = Session()
            //save the general identification of the session
            let saveRef = settingsRef.childByAppendingPath("\(settingsRef.authData.uid)/sessions").childByAutoId()
            sessionID = saveRef.key
            imageID = backImageID
            sessionTitle = nameTrek_tf.text!
            date = "\(NSDate())"
//            currentSession?.imageID = backImageID
//            currentSession?.sessionTitle = nameTrek_tf.text!
//            currentSession?.Date = NSDate()
            
            //if the user sets units as imperial then...
            if sessionUnits == false {
                eachSessionUnits = false
                topSpeed = locationInfo.getTopSpeed()
                peakAltitude = locationInfo.getPeakAltitude()
                totalDistance = locationInfo.getTotalDistance()
                averageSpeed = locationInfo.getAverageSpeed()
            }
            //if the user sets units as metric
            else
            {
                eachSessionUnits = true
                topSpeed = locationInfo.getTopSpeed()
                peakAltitude = locationInfo.getPeakAltitude()
                totalDistance = locationInfo.getTotalDistance()
                averageSpeed = locationInfo.getAverageSpeed()
            }
            //set the sessionTime string to be the ending timer time
            sessionTime = "TIME ADVENTURING: \(locationInfo.ventureTime)"
            
            //save it all to firebase
            let savedSession = ["sessionID": sessionID, "thisSessionUnits": eachSessionUnits, "imageID": imageID, "sessionTitle": sessionTitle, "dateCreated": date, "topSpeed": topSpeed, "peakAltitude": peakAltitude, "totalDistance": totalDistance, "averageSpeed": averageSpeed, "sessionTime": sessionTime]
            
            saveRef.setValue(savedSession)
            
//            if Session.measureSwitch == false {
//                currentSession?.sessionMeasuredIn = false
//                currentSession?.topSpeed = locationInfo.getTopSpeed()
//                currentSession?.peakAltitude = locationInfo.getPeakAltitude()
//                currentSession?.totalDistance = locationInfo.getTotalDistance()
//                currentSession?.averageSpeed = locationInfo.getAverageSpeed()
//            }
            
            //if the user sets units as metric
//            else {
//                currentSession?.sessionMeasuredIn = true
//                currentSession?.topSpeed = locationInfo.getTopSpeed()
//                currentSession?.peakAltitude = locationInfo.getPeakAltitude()
//                currentSession?.totalDistance = locationInfo.getTotalDistance()
//                currentSession?.averageSpeed = locationInfo.getAverageSpeed()
//            }
            
            //set the sessionTime string to be the ending timer time
//            currentSession?.sessionTime = "TIME ADVENTURING: " + locationInfo.ventureTime
            
            //send it all to realm
//            let realm = Realm
//            realm.write() {
//                realm.add(self.currentSession!)
//            }
        }
    }
    
    
    //this function updates current Altitude, top speed, peak altitude, and total distance
    func updateCurrentStats(){
        //if the session is NOT an old session...
        if isAddSession == true {
            //if units are imperial system...
            if sessionUnits == false {
                //if the CLLocation.Location is not nil
                if locationInfo.locationManager.location != nil {
                    if locationInfo.locationManager.location!.altitude >= 0 {
                        currentAltitude_lb.text = String(round(locationInfo.locationManager.location!.altitude * imperialConvFt * 1000)/1000) + " ft"
                    }
                    else{
                        currentAltitude_lb.text = "0.0 ft"
                    }
                    topSpeed_lb.text = "\(locationInfo.getTopSpeed()) mph"
                    peakAltitude_lb.text = "\(locationInfo.getPeakAltitude()) ft"
                    totalDistance_lb.text = "\(locationInfo.getTotalDistance()) mi"
                }
                else {
                  currentAltitude_lb.text = "- - - -"
                }
            }
            else {
                if locationInfo.locationManager.location != nil {
                    if locationInfo.locationManager.location!.altitude >= 0 {
                        currentAltitude_lb.text = String(round(locationInfo.locationManager.location!.altitude * 100)/100) + " m"
                    }
                    else{
                        currentAltitude_lb.text = "0.0 m"
                    }
                    topSpeed_lb.text = "\(locationInfo.getTopSpeed()) kph"
                    peakAltitude_lb.text = "\(locationInfo.getPeakAltitude()) m"
                    totalDistance_lb.text = "\(locationInfo.getTotalDistance()) km"
                }
                else {
                   currentAltitude_lb.text = "- - - -"
                }
            }
        }
        else {
            if locationInfo.locationManager.location != nil {
                
                if thisSessionUnits == false {
                    currentAltitude_lb.text = String(round(locationInfo.locationManager.location!.altitude * imperialConvFt * 1000)/1000) + " ft"
                }
                else {
                   currentAltitude_lb.text = String(round(locationInfo.locationManager.location!.altitude * 100)/100) + " m"
                }
            }
            else {
                if thisSessionUnits == false {
                    currentAltitude_lb.text = "- - ft"
                }
                else {
                    currentAltitude_lb.text = "- - m"
                }
 
            }
        }
    }
    
    
    func getAverageSpeed(){
        if sessionUnits == false {
        currentSpeed_lb.text = "\(locationInfo.getAverageSpeed()) mph"
        }
        else {
        currentSpeed_lb.text = "\(locationInfo.getAverageSpeed()) kph"
        }
    }
    
    func getAltitudeSkied(){
        //formula to find total ft skiied rather than sitting on the lift
        //use if statements to determine if user is going downhill
            //if user is going downhill then calculate how many feet downhill
            //keep updating the total like total distance
    }
    
    func tripDuration(){
        sessionTime.text = "Adventure Time: \(locationInfo.tripDuration())"
    }
}
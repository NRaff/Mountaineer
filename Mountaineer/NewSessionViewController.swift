//
//  NewSessionViewController.swift
//  SkiBum
//
//  Created by Nick Raff on 7/27/15.
//  Copyright (c) 2015 Nick Raff. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import Mixpanel

class NewSessionViewController: UIViewController {
// MARK: - References
    let mixpanel: Mixpanel = Mixpanel.sharedInstance()
    let RootRef: Firebase = Firebase(url: "https://mountaineer.firebaseio.com/users")
    var updateRef: Firebase?
    var fetchedResumeStats: Bool = false
    
// MARK: - Variables
    var locationInfo = LocationHelper()
    var isAddSession = true
    var currentSession: Session?
    var sessionUnits: Bool = false
    var selectedSession: String?
    var statsTimer: NSTimer?
    var sessionDuration: NSTimer?
    var aveVelocity: NSTimer?
    var resumeTimer: NSTimer?
    var metricConversionKPH = 3.6
    var metricConversionKM = 0.001
    var imperialConvMPH = 2.23694
    var imperialConvMi = 0.000621371
    var imperialConvFt = 3.28084
    var backImageID: Int = 0
    let formatter = NSDateFormatter()
    var resumedSession = false
    
// MARK: - IBOutlets
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
    
    @IBOutlet weak var resume_btn: UIButton!
    
    
// MARK: - Base Functions
    override func viewDidLoad() {
        formatter.dateStyle = NSDateFormatterStyle.FullStyle
        formatter.timeStyle = .ShortStyle
        super.viewDidLoad()
        nameTrek_tf.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        locationInfo.startedLocation()
        RootRef.childByAppendingPath(RootRef.authData.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.sessionUnits = snapshot.value["sessionUnits"] as! Bool
        })
            //if user is adding a session then display the add fields
            self.sessionAppear()
        }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
// MARK: - IBActions
    @IBAction func backCancelButton(sender: AnyObject) {
        //if the user is creating a new session then show the alert with options:
        if isAddSession == true {
            //show the alert
            presentViewController(self.cancelAlert(), animated: true, completion: nil)
        }
            
        //if the user is viewing an old session then just segue back to the AllSessions view instead of pushing an alert
        else {
            //if the ser resumed a session
            if resume_btn.hidden == true {
                presentViewController(self.resumeBackAlert(), animated: true, completion: nil)
            }
            else {
                self.performSegueWithIdentifier("segueToAlert", sender: nil)
                mixpanel.track("Old Session", properties: ["Viewing?": "No - Left Session"])
            }
        }
    }
    
    @IBAction func startNewSessionBtn(sender: AnyObject) {
        
        //if the user has given the session a name then...
        if nameTrek_tf.text != "" {
            //track
            mixpanel.track("Add Session Started", properties: ["Recording": "Check Button - OK"])
            self.hideUnneeded()
                
            //start the timer that asks for the average speed every 5 seconds
            self.aveVelocityTimer()
                
            //start the timer that adds updates the UI timer
            self.startDurationTimer()
       
            //set the title text to the text field text
            titleLabel.text = nameTrek_tf.text
                
            //hide the keyboard
            nameTrek_tf.resignFirstResponder()
            self.unhideNeeded()
        }
        //if the user forgot to give the session a name then...
        else {
            //if the user didn't give the session a name, then give this error message
            presentViewController(self.anotherAlert(), animated: true, completion: nil)

            mixpanel.track("Add Session Started", properties: ["Recording": "Check Button - Needs Name"])
        }

    }
    
    @IBAction func endButton(sender: AnyObject) {
        //when 'end' is clicked save all data and segue to AllSessions
        self.saveStuff()
        self.performSegueWithIdentifier("segueOnEnd", sender: nil)
        mixpanel.track("Back/Cancel Alert", properties: ["Options": "Saved with End"])
    }
    
    @IBAction func resumeButton(sender: AnyObject) {
        self.passVarsBackForResume()
//        repeat {
//            if self.fetchedResumeStats {
//                self.startResumeTimer()
//                self.aveVelocityTimer()
//                self.startDurationTimer()
//            }
//        } while self.fetchedResumeStats == false
        resume_btn.hidden = true
        resumedSession = true
        
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
        resumeTimer?.invalidate()
        
    }

}

// MARK: - UIHelper Extension
extension NewSessionViewController {
    func cancelAlert() -> UIAlertController {
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
        
        return cancelAlert
    }
    
    func anotherAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Oops!", message: "Make sure you've named your trip!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {(action: UIAlertAction!) in
            print("oops message dismissed")
        }))
        
        return alert
    }
    
    func resumeBackAlert() -> UIAlertController {
        let alert = UIAlertController(title: "End Session?", message: "Don't worry you can resume at any time.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Save & Exit", style: .Default, handler: { (action: UIAlertAction) in
            //if save and exit is chosen then save the data, track the event, then go back to AllSessions
            self.saveStuff()
            self.mixpanel.track("Back/Cancel Alert", properties: ["Options": "Save Session (Alert)"])
            self.performSegueWithIdentifier("segueToAlert", sender: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Keep Shredding!", style: .Default, handler: { (action: UIAlertAction) in
            //if 'keep shredding' is chosen then don't do anything and continue the session
            self.mixpanel.track("Back/Cancel Alert", properties: ["Options": "Continue Session (Alert)"])
        }))
        
        return alert
    }
    
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
    
    func aveVelocityTimer() {
    aveVelocity = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(NewSessionViewController.getAverageSpeed), userInfo: nil, repeats: true)
    }
    
    func startDurationTimer() {
    sessionDuration = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(NewSessionViewController.tripDuration), userInfo: nil, repeats: true)
    }
    
    func startUpdateTimer() {
    self.statsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(NewSessionViewController.updateCurrentStats), userInfo: nil, repeats: true)
    }
    
    func startResumeTimer() {
        self.resumeTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(NewSessionViewController.getStatsToLabels), userInfo: nil, repeats: true)
        
    }

}

// MARK: - Text Field Delegate
extension NewSessionViewController: UITextFieldDelegate {
    
    //when the keyboard 'Go' button is tapped...
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        //if the text field is not blank then...
        if nameTrek_tf.text != "" {
            titleLabel.text = nameTrek_tf.text
            hideUnneeded()
            //start all the timers to update stats
            self.aveVelocityTimer()
            self.startDurationTimer()
            nameTrek_tf.resignFirstResponder()
            unhideNeeded()
            mixpanel.track("Add Session Started", properties: ["Recording": "Keyboard 'GO' - OK"])
        }
            
        else {
            //if the user didn't give the session a name, then give this error message
            let alert = UIAlertController(title: "Oops!", message: "Make sure you've named your trip!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {(action: UIAlertAction!) in
                print("oops message dismissed")
            }))
            
            presentViewController(alert, animated: true, completion: nil)
            
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
        //if isAddSession == true && cancel_btn.hidden == true {
            //init all temp variables
            var sessionID: String
            var imageID: Int
            var sessionTitle: String
            var date: String
            
            var eachSessionUnits: Bool
            var topSpeed: Double
            var highAltitude: Double
            var totalDistance: Double
            var averageSpeed: Double
        
            var sessionTime: String

            //save the general identification of the session
            let saveRef = RootRef.childByAppendingPath("\(RootRef.authData.uid)/sessions").childByAutoId()
            
            //set the update reference for resume session
            if isAddSession == false {
            updateRef = currentSession!.ref
            }

            sessionID = saveRef.key
            imageID = backImageID
            sessionTitle = nameTrek_tf.text!
            date = formatter.stringFromDate(NSDate())
            
            //if the user sets units as imperial then...
            if sessionUnits == false {
                eachSessionUnits = false
                topSpeed = locationInfo.getTopSpeed()
                highAltitude = locationInfo.getPeakAltitude()
                totalDistance = locationInfo.getTotalDistance()
                averageSpeed = locationInfo.NewAverageSpeed()
            }
            //if the user sets units as metric
            else
            {
                eachSessionUnits = true
                topSpeed = locationInfo.getTopSpeed()
                highAltitude = locationInfo.getPeakAltitude()
                totalDistance = locationInfo.getTotalDistance()
                averageSpeed = locationInfo.NewAverageSpeed()
            }
            //set the sessionTime string to be the ending timer time
            sessionTime = "TIME ADVENTURING: \(locationInfo.tripDuration().timeString)"
            let sessionSeconds = locationInfo.tripDuration().seconds
            let sessionMinutes = locationInfo.tripDuration().minutes
            let sessionHours = locationInfo.tripDuration().hours
            let sumSpeeds = locationInfo.sumSpeeds
            let averageSpeedCount = locationInfo.averageSpeedCount
            let maxSpeed = locationInfo.maxSpeed!
            let peakAltitude = locationInfo.peakAltitude!
        
            
            //save it all to firebase
            let savedSession = ["sessionID": sessionID, "thisSessionUnits": eachSessionUnits, "imageID": imageID, "sessionTitle": sessionTitle, "dateCreated": date, "topSpeed": topSpeed, "highAltitude": highAltitude, "totalDistance": totalDistance, "averageSpeed": averageSpeed, "sessionTime": sessionTime, "seconds": sessionSeconds, "minutes": sessionMinutes, "hours": sessionHours, "sumSpeeds": sumSpeeds, "averageSpeedCount": averageSpeedCount, "maxSpeed": maxSpeed, "peakAltitude": peakAltitude]
        
            let updatedSession = ["topSpeed": topSpeed, "highAltitude": highAltitude, "totalDistance": totalDistance, "averageSpeed": averageSpeed, "sessionTime": sessionTime, "seconds": sessionSeconds, "minutes": sessionMinutes, "hours": sessionHours, "sumSpeeds": sumSpeeds, "averageSpeedCount": averageSpeedCount, "maxSpeed": maxSpeed, "peakAltitude": peakAltitude]
            
            if resumedSession == false {
            saveRef.setValue(savedSession)
            }
            else {
            updateRef!.updateChildValues(updatedSession as [NSObject : AnyObject])
            }
            

       // }
    }
    
    
    //this function updates current Altitude, top speed, peak altitude, and total distance
    func updateCurrentStats(){
        //if the session is NOT an old session...
        if isAddSession == true {
            //if units are imperial system...
            self.getStatsToLabels()
        }
        else {
            if locationInfo.locationManager.location != nil {
                
                if sessionUnits == false {
                    currentAltitude_lb.text = String(round(locationInfo.locationManager.location!.altitude * imperialConvFt * 1000)/1000) + " ft"
                }
                else {
                   currentAltitude_lb.text = String(round(locationInfo.locationManager.location!.altitude * 100)/100) + " m"
                }
            }
            else {
                if sessionUnits == false {
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
        currentSpeed_lb.text = "\(locationInfo.NewAverageSpeed()) mph"
        }
        else {
        currentSpeed_lb.text = "\(locationInfo.NewAverageSpeed()) kph"
        }
    }
    
    func getAltitudeSkied(){
        //formula to find total ft skiied rather than sitting on the lift
        //use if statements to determine if user is going downhill
            //if user is going downhill then calculate how many feet downhill
            //keep updating the total like total distance
    }
    
    func tripDuration(){
        sessionTime.text = "ADVENTURE TIME: \(locationInfo.tripDuration().timeString)"
    }
    
    func sessionAppear() {
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
            nameTrek_tf.attributedPlaceholder = NSAttributedString(string:"NAME YOUR SESSION", attributes:[NSForegroundColorAttributeName: UIColor.lightTextColor()])
            
            //track the event
            mixpanel.track("Add Session Started", properties: ["Event": "Opened Scene"])
            
        }
            
        //otherwise hide the editable fields and display the recorded topspeed and peak altitude
        else{
            //pass stats back to locationHelper
//            self.passVarsBackForResume()
            resume_btn.hidden = false
            //hide and unhide things
            unhideNeeded()
            hideUnneeded()
            end_btn.hidden = true
            
            self.setCurrentSessionFields()
//            print(currentSession!.averageSpeedArray)
            
            //track this event
            mixpanel.track("Old Session", properties: ["Viewing?": "Opened Old Session"])
        }
        
        //update the different stats every second
        self.startUpdateTimer()
    }
    
    func setCurrentSessionFields() {
        
        //pull data from the old session to be displayed in the session view objects
        titleLabel.text = currentSession!.sessionTitle
        sessionTime.text  = currentSession!.sessionTime
        //select the correct image
        backImage.image = UIImage(named: "detailsbg\(currentSession!.imageID)")
        
        //if the current session units are set as imperial...
        if sessionUnits == false {
            topSpeed_lb.text = String(currentSession!.topSpeed) + " mph"
            peakAltitude_lb.text = String(currentSession!.peakAltitude) + " ft"
            totalDistance_lb.text = String(currentSession!.totalDistance) + " mi"
            currentSpeed_lb.text = "\(currentSession!.averageSpeed) mph"
        }
            
            //if the current session units are set as metric...
        else {
            topSpeed_lb.text = String(currentSession!.topSpeed) + " kph"
            peakAltitude_lb.text = String(currentSession!.peakAltitude) + " m"
            totalDistance_lb.text = String(currentSession!.totalDistance) + " km"
            currentSpeed_lb.text = "\(currentSession!.averageSpeed) kph"
        }
    }
    
    func passVarsBackForResume() {
        //vars for time stuff
        var seconds: Int = 0
        var minutes: Int = 0
        var hours: Int = 0
        var sumSpeeds = 0.0
        var averageSpeedCount = 0.0
        var maxSpeed = 0.0
        var peakAltitude = 0.0
        
        //pass all vars
        if RootRef.authData != nil {
            
            currentSession!.ref?.observeSingleEventOfType(.Value, withBlock: {snapshot in
                seconds = snapshot.value["seconds"] as! Int
                minutes = snapshot.value["minutes"] as! Int
                hours = snapshot.value["hours"] as! Int
                sumSpeeds = snapshot.value["sumSpeeds"] as! Double
                averageSpeedCount = snapshot.value["averageSpeedCount"] as! Double
                maxSpeed = snapshot.value["maxSpeed"] as! Double
                peakAltitude = snapshot.value["peakAltitude"] as! Double
                //pass time and average speed stuff stuff
                self.locationInfo.seconds = seconds
                self.locationInfo.minutes = minutes
                self.locationInfo.hours = hours
                self.locationInfo.sumSpeeds = sumSpeeds
                self.locationInfo.averageSpeedCount = averageSpeedCount
                
                
                //pass topSpeed
                self.locationInfo.maxSpeed = maxSpeed
                
                //pass peakAltitude
                self.locationInfo.peakAltitude = peakAltitude
                
                //pass total distance after conversion back to CoreLocation units (metric)
                if self.sessionUnits == false {
                    self.locationInfo.totalDistance = self.currentSession!.totalDistance/self.locationInfo.imperialConvMi
                }
                else {
                    self.locationInfo.totalDistance = self.currentSession!.totalDistance/self.locationInfo.metricConversionKM
                }
                self.fetchedResumeStats = true
                if self.fetchedResumeStats {
                    self.startResumeTimer()
                    self.aveVelocityTimer()
                    self.startDurationTimer()
                }
            })
        }
    }
    
    func getStatsToLabels() {
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
}
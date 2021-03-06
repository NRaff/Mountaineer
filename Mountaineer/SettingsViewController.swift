//
//  SettingsViewController.swift
//  SkiBum
//
//  Created by Nick Raff on 8/4/15.
//  Copyright (c) 2015 Nick Raff. All rights reserved.
//

import UIKit
import Mixpanel
import Firebase
import FirebaseUI

class SettingsViewController: UIViewController {
// MARK: Variables & References
    let RootRef: Firebase = Firebase(url: "https://mountaineer.firebaseio.com")
    let usersRef: Firebase = Firebase(url: "https://mountaineer.firebaseio.com/users")
    let mixpanel: Mixpanel = Mixpanel.sharedInstance()
    var metric: Bool = false
    
    var emailAlertField: UITextField?
    var passwordAlertField: UITextField?
    var oldPasswordAlertField: UITextField?
    

// MARK: IBOutlets
    @IBOutlet weak var measureSwitch: UISegmentedControl!
    
    @IBOutlet weak var settingsNavBar: UINavigationBar!
    
    @IBOutlet weak var doneItem: UIBarButtonItem!

// MARK: IBActions

    
    @IBAction func logout_btn(sender: AnyObject) {
        
    }
    
    @IBAction func measureSwitchEvent(sender: AnyObject) {
        if measureSwitch.selectedSegmentIndex == 0 {
            metric = true
            mixpanel.track("Settings", properties: ["Options": "Metric is Selected"])
        }
        else {
            metric = false
            mixpanel.track("Settings", properties: ["Options": "Imperial is Selected"])
        }
        print("\(metric) idk")
    }
    
    @IBAction func changePassword_btn(sender: AnyObject) {
        self.presentViewController(self.resetPasswordAlert(), animated: true, completion: nil)
        
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func resetPasswordAlert() -> UIAlertController {
        let resetAlert = UIAlertController(title: "Reset Password", message: "Please enter your email and password.", preferredStyle: UIAlertControllerStyle.Alert)
        resetAlert.addTextFieldWithConfigurationHandler { textField -> Void in
            self.emailAlertField = textField
            self.emailAlertField?.placeholder = "Email"
        }
        
        resetAlert.addTextFieldWithConfigurationHandler { textField -> Void in
            self.oldPasswordAlertField = textField
            self.oldPasswordAlertField?.placeholder = "Old Password"
            self.oldPasswordAlertField?.secureTextEntry = true
        }
        
        resetAlert.addTextFieldWithConfigurationHandler{ textField -> Void in
            self.passwordAlertField = textField
            self.passwordAlertField?.placeholder = "New Password"
            self.passwordAlertField?.secureTextEntry = true
        }
        
        
        resetAlert.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.Default, handler: { action -> Void in
            let email = self.emailAlertField!.text!
            let oldPass = self.oldPasswordAlertField!.text!
            let newPass = self.passwordAlertField!.text!
            
            self.changePassword(email, oldPass: oldPass, newPass: newPass)
        }))
        
        return resetAlert
    }
    
    func PassChangeSuccessAlert() -> UIAlertController {
        let successAlert = UIAlertController(title: "Success!", message: "You've successfully changed your password.", preferredStyle: UIAlertControllerStyle.Alert)
        
        successAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        return successAlert
        
    }
    
    func PassChangeErrorAlert() -> UIAlertController {
        let errorAlert = UIAlertController(title: "Oops...", message: "There was an error changing your password. Make sure you entered the correct email and old password, then try again.", preferredStyle: UIAlertControllerStyle.Alert)
        
        errorAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        return errorAlert
    }
    
    func changePassword(email: String, oldPass: String, newPass: String){
        self.RootRef.changePasswordForUser(email, fromOld: oldPass, toNew: newPass) { (ErrorType) -> Void in
            if ErrorType != nil {
                self.presentViewController(self.PassChangeErrorAlert(), animated: true, completion: nil)
                print("there was an error")
            }
            else {
                self.presentViewController(self.PassChangeSuccessAlert(), animated: true, completion: nil)
                print("Password changed successfully")
            }
        }
    }
    
// MARK: Base Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usersRef.queryOrderedByChild("\(usersRef.authData.uid)/sessionUnits").observeEventType(.ChildAdded, withBlock: { snapshot in
            if let sessionUnits = snapshot.value["sessionUnits"] as? Bool {
                if sessionUnits
                {
                    self.measureSwitch.selectedSegmentIndex = 0
                    print("metric is selected")
                }
                else
                {
                    self.measureSwitch.selectedSegmentIndex = 1
                    print("imperial is selected")
                }
            }
        })
       
        settingsNavBar.setTitleVerticalPositionAdjustment(-13, forBarMetrics: .Default)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
// MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let sessionsController = SessionsViewController()
        if segue.identifier == "goBack" {
            sessionsController.segueIdentifier = "goBack"
            let NewSession = SessionsViewController()
            NewSession.sessionUnits = metric
            usersRef.childByAppendingPath("\(usersRef.authData.uid)").updateChildValues(["sessionUnits": metric])
            print(metric)
            
        }
        else {
            sessionsController.segueIdentifier = "logoutSegue"
            print("logged out segue")
        }

    }

}

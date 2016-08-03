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
    @IBAction func changePassword_btn(sender: AnyObject) {
        self.presentViewController(self.resetPasswordAlert(), animated: true, completion: nil)
    }
    
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
    
    func resetPasswordAlert() -> UIAlertController {
        let resetAlert = UIAlertController(title: "Reset Password", message: "Please enter your email and password.", preferredStyle: UIAlertControllerStyle.Alert)
        resetAlert.addTextFieldWithConfigurationHandler { textField -> Void in
            self.emailAlertField = textField
            self.emailAlertField?.placeholder = "Email"
        }
        
        resetAlert.addTextFieldWithConfigurationHandler { textField -> Void in
            self.oldPasswordAlertField = textField
            self.oldPasswordAlertField?.placeholder = "Old Password"
        }
        
        resetAlert.addTextFieldWithConfigurationHandler{ textField -> Void in
            self.passwordAlertField = textField
            self.passwordAlertField?.placeholder = "New Password"
        }
        
        
        resetAlert.addAction(UIAlertAction(title: "Go", style: .Default, handler: {(action: UIAlertAction) in
            self.updatePassword()
        }))
        
        return resetAlert
    }
    
    func updatePassword(){
        
        let emailTextField = resetPasswordAlert().textFields![0]
        let oldPassField = resetPasswordAlert().textFields![1]
        let newPassField = resetPasswordAlert().textFields![2]
        
        RootRef.changePasswordForUser(emailTextField.text, fromOld: oldPassField.text, toNew: newPassField.text, withCompletionBlock: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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

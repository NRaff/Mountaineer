//
//  CreateAccountViewController.swift
//  Mountaineer
//
//  Created by Nick Raff on 3/20/16.
//  Copyright © 2016 Nick Raff. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class CreateAccountViewController: UIViewController {
    
    var emailAlertField: UITextField?
    var passwordAlertField: UITextField?
    var oldPasswordAlertField: UITextField?
    
    var activityIndicatorView: WaitingIndicatorView!
    
    let rootRef: Firebase = Firebase(url: "https://mountaineer.firebaseio.com")

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.placeholderUI()
        emailText.delegate = self
        passwordText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccount_btn(sender: AnyObject) {
        self.activityIndicatorView = WaitingIndicatorView(title: "Just a second...", center: self.view.center)
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        
        self.activityIndicatorView.startAnimating()
        self.loginToFirebase()
        self.activityIndicatorView.stopAnimating()
    }
    
    @IBAction func resetPassword_btn(sender: AnyObject) {
        self.resetPassword()
//        self.presentViewController(self.resetPasswordAlert(), animated: true, completion: nil)
//        print("button pressed")
    }
}

//MARK: - UIHelper Extension
extension CreateAccountViewController {
    
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
        
        
        resetAlert.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.Default, handler: { action -> Void in
            let email = self.emailAlertField!.text!
            let oldPass = self.oldPasswordAlertField!.text!
            let newPass = self.passwordAlertField!.text!
            
            self.rootRef.changePasswordForUser(email, fromOld: oldPass, toNew: newPass, withCompletionBlock: nil)
        }))
        
        return resetAlert
    }
    
    func placeholderUI() {
        emailText.attributedPlaceholder = NSAttributedString(string:"EMAIL", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordText.attributedPlaceholder = NSAttributedString(string: "PASSWORD", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
    func createEnterInfoAlert() -> UIAlertController {
        let createUserAlert = UIAlertController(title: "Oops!", message: "There was an error logging in. Check that all fields are filled out, then give it another shot.", preferredStyle: UIAlertControllerStyle.Alert)
        
        createUserAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
        }))
        
        return createUserAlert
    }
    
    func createConnectionErrorAlert() -> UIAlertController {
        let connectionAlert = UIAlertController(title: "Oops!", message: "There was an error logging in. Check that your email and password are correct, then try again. Also make sure that you are connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
        
        connectionAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
        }))
        
        return connectionAlert
    }
    //configure text fields for reset password alert

    
}

//MARK: - Firebase Extension
extension CreateAccountViewController {
    
    func loginToFirebase() {
        let email = emailText.text
        let password = passwordText.text
        if email != "" && password != "" {
            rootRef.authUser(email, password: password) { (error, authData) -> Void in
                if error != nil
                {
                    self.presentViewController(self.createConnectionErrorAlert(), animated: true, completion: nil)
                    print("There was an error while logging in")
                }
                else
                {
                    self.performSegueWithIdentifier("createAccountToAllSessionsSegue", sender: nil)
                    print("successfully logged in")
                }
            }
        }
        else
        {
            self.presentViewController(createEnterInfoAlert().self, animated: true, completion: nil)
            print("Need to enter login info")
        }
    }
    
    func resetPassword() {
        let email = emailText.text
        rootRef.resetPasswordForUser(email, withCompletionBlock: {(error) -> Void in
            if error != nil
            {
                print("reset password error")
            }
            else
            {
               print("successful password reset")
            }
        })
    }
    
}

// MARK: - Text Field Delegate
extension CreateAccountViewController: UITextFieldDelegate {
    
    //when the keyboard 'Go' button is tapped...
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == UIReturnKeyType.Next {
            passwordText.becomeFirstResponder()
        }
        else
        {
            textField.resignFirstResponder()
            
            self.activityIndicatorView = WaitingIndicatorView(title: "Just a second...", center: self.view.center)
            self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
            
            self.activityIndicatorView.startAnimating()
            self.loginToFirebase()
            self.activityIndicatorView.stopAnimating()
        }
        
        return true
    }
    
    //if a user taps outside the text field then hide the keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
    }
}


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
    
    var tempEmail: UITextField?
    
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
    
    @IBAction func forgotPassword_btn(sender: AnyObject) {
        self.presentViewController(self.sendTempPasswordAlert(), animated: true, completion: nil)
    }
}

//MARK: - UIHelper Extension
extension CreateAccountViewController {
    
    func sendTempPasswordAlert() -> UIAlertController {
        let sendTemp = UIAlertController(title: "Send Temporary Password", message: "Enter your email and we'll send you a temporary password.", preferredStyle: UIAlertControllerStyle.Alert)
        sendTemp.addTextFieldWithConfigurationHandler { textField -> Void in
            self.tempEmail = textField
            self.tempEmail?.placeholder = "Email"
        }
        
        sendTemp.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.Default, handler: { action -> Void in
            let email = self.tempEmail!.text!
            self.resetPassword(email)
        }))
        
        sendTemp.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        return sendTemp
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
    
    func resetPassword(email: String) {
        let email = email
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


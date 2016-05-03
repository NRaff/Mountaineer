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
        self.loginToFirebase()
    }
    
}

//MARK: - UIHelper Extension
extension CreateAccountViewController {
    
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
            self.loginToFirebase()
        }
        
        return true
    }
    
    //if a user taps outside the text field then hide the keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
    }
}


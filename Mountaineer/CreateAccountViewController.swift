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
//    @IBOutlet weak var homeMountainText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailText.attributedPlaceholder = NSAttributedString(string:"EMAIL", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordText.attributedPlaceholder = NSAttributedString(string: "PASSWORD", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        emailText.delegate = self
        passwordText.delegate = self
        
        print("create account view loaded")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccount_btn(sender: AnyObject) {
        self.loginToFirebase()
    }


    func loginToFirebase() {
        let email = emailText.text
        let password = passwordText.text
        if email != "" && password != "" {
            rootRef.authUser(email, password: password) { (error, authData) -> Void in
                if error != nil
                {
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
            let createUserAlert = UIAlertController(title: "Oops!", message: "There was an error logging in. Check that all fields are filled out, then give it another shot.", preferredStyle: UIAlertControllerStyle.Alert)
            
            createUserAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
                print("message dismissed")
            }))
            
            self.presentViewController(createUserAlert.self, animated: true, completion: nil)
            print("Need to enter login info")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CreateAccountViewController: UITextFieldDelegate {
    
    //when the keyboard 'Go' button is tapped...
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //        textField.resignFirstResponder()
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


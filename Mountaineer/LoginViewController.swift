//
//  LoginViewController.swift
//  Mountaineer
//
//  Created by Nick Raff on 3/20/16.
//  Copyright © 2016 Nick Raff. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class LoginViewController: UIViewController {
    let rootRef: Firebase = Firebase(url: "https://mountaineer.firebaseio.com")
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login_btn(sender: AnyObject) {
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
                    print("successfully logged in")
                    self.performSegueWithIdentifier("loggedInAllSessionsSegue", sender: nil)
                }
            }
        }
        else
        {
            print("Need to enter login info")
        }
        
    }

    @IBAction func createAccount_btn(sender: AnyObject) {
        self.performSegueWithIdentifier("createAccountSegue", sender: nil)
        print("create account segue was performed")
    }
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
            if let identifier = segue.identifier {
                if identifier == "cancelledCreateAccountSegue" {
                    print("unwind to login screen without creating an account")
                }
            }
        }

 
   /* // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginToAllSessions"
        {
           
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
*/

}

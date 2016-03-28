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


    @IBOutlet weak var fullNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var homeMountainText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("create account view loaded")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccount_btn(sender: AnyObject) {
        if fullNameText.text != "" && emailText.text != "" && passwordText.text != "" && homeMountainText.text != ""
            {
                let fullName = fullNameText.text
                let email = emailText.text
                let password = passwordText.text
                let homeMountain = homeMountainText.text

                rootRef.createUser(email, password: password,
                    withValueCompletionBlock: { error, result in
                        if error != nil
                        {
                            print("There was an error creating the account")
                        }
                        else
                        {
                            let uid = result["uid"] as? String
                            print("Successfully created user account with uid: \(uid!)")
                            self.rootRef.authUser(email, password: password) { (error, authData) -> Void in
                                if error != nil
                                {
                                    print("There was an error while logging in")
                                }
                                else
                                {
                                    print("successfully logged in")
                                    let newUser = ["fullName": fullName!, "email": email!, "homeMountain": homeMountain!]
                                    
                                    let usersRef = self.rootRef.childByAppendingPath("users/\(self.rootRef.authData.uid)")
                                    
                                    usersRef.setValue(newUser)
                                    
                                    self.performSegueWithIdentifier("createAccountToAllSessionsSegue", sender: nil)
                                }
                            }
                        }
                })
                
//                var newUser = ["fullName": fullName!, "email": email!, "homeMountain": homeMountain!]
//                
//                if let usersRef = rootRef.childByAppendingPath("users/\(rootRef.authData.uid)") {
//                    usersRef.setValue(newUser)
//                }
//                else{
//                    print("usersRef was nil")
//                }

        }
        else
        {
            print("A field was not filled out")
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

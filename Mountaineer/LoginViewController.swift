//
//  LoginViewController.swift
//  Mountaineer
//
//  Created by Nick Raff on 3/20/16.
//  Copyright © 2016 Nick Raff. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    let rootRef: Firebase = Firebase(url: "https://mountaineer.firebaseio.com")
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var HomeMountianText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailText.attributedPlaceholder = NSAttributedString(string:"EMAIL", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordText.attributedPlaceholder = NSAttributedString(string: "PASSWORD", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        nameText.attributedPlaceholder = NSAttributedString(string: "NAME", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        HomeMountianText.attributedPlaceholder = NSAttributedString(string: "HOME MOUNTAIN", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])

        
        // Setup delegates
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        // Attempt to sign in silently, this will succeed if
        // the user has recently been authenticated
        GIDSignIn.sharedInstance().signInSilently()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        rootRef.observeAuthEventWithBlock { (authData) -> Void in
            // 2
            if authData != nil {
                // 3
                self.performSegueWithIdentifier("loggedInAllSessionsSegue", sender: nil)
            }
            else {
                self.emailText.text = ""
                self.passwordText.text = ""
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login_btn(sender: AnyObject) {
        self.performSegueWithIdentifier("createAccountSegue", sender: nil)
        print("create account segue was performed")
    }

    @IBAction func createAccount_btn(sender: AnyObject) {

        if nameText.text != "" && emailText.text != "" && passwordText.text != "" && HomeMountianText.text != ""
        {
            let fullName = nameText.text
            let email = emailText.text
            let password = passwordText.text
            let homeMountain = HomeMountianText.text
            
            rootRef.createUser(email, password: password, withValueCompletionBlock: { error, result in
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
                            let creationErrorAlert = UIAlertController(title: "Uh oh...", message: "There was an error creating your account. Make sure you're connected and try again.", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            creationErrorAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
                                print("message dismissed")
                            }))
                            
                            print("There was an error while logging in \(error)")
                            self.presentViewController(creationErrorAlert, animated: true, completion: nil)
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
            
        }
            
        else
        {
            //create alert presentation
            let createUserAlert = UIAlertController(title: "Oops!", message: "There was an error creating your account. Check that all fields are filled out, then give it another shot.", preferredStyle: UIAlertControllerStyle.Alert)
            
            createUserAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
                print("message dismissed")
            }))
            
            self.presentViewController(createUserAlert.self, animated: true, completion: nil)
            print("A field was not filled out")
        }
        
    }
    
    @IBOutlet weak var loginGoogle_btn: UIButton!
    
    @IBAction func loginWithGoogle_btn(sender: AnyObject) {
       authenticateWithGoogle(loginGoogle_btn)
    }

    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
            if let identifier = segue.identifier {
                if identifier == "cancelledCreateAccountSegue" {
                    print("unwind to login screen without creating an account")
                }
                else
                {
                    print("logoutSegue performed")
                }
            }

        }
    
    @IBAction func unwindToLoginViewController(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            if identifier == "logoutSegue" {
                rootRef.unauth()
                print("logoutSegue performed")
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

    // MARK: - Google Stuff
    
    // Wire up to a button tap
    func authenticateWithGoogle(sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        rootRef.unauth()
    }
    // Implement the required GIDSignInDelegate methods
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
            if (error == nil) {
                // Auth with Firebase
                rootRef.authWithOAuthProvider("google", token: user.authentication.accessToken, withCompletionBlock: { (error, authData) in
                    // User is logged in!
                })
            } else {
                // Don't assert this error it is commonly returned as nil
//                let googleErrorAlert = UIAlertController(title: "Uh oh...", message: "There was an error connecting with google. Make sure you're connected then try again.", preferredStyle: UIAlertControllerStyle.Alert)
//                
//                googleErrorAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
//                    print("message dismissed")
//                }))
                
                print("\(error.localizedDescription)")
            }
    }
    // Implement the required GIDSignInDelegate methods
    // Unauth when disconnected from Google
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
        withError error: NSError!) {
            rootRef.unauth();
    }
}


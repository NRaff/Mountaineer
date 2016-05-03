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
// MARK: Firebase Root Ref
    let rootRef: Firebase = Firebase(url: "https://mountaineer.firebaseio.com")
    let unitsSetting = false
    
// MARK: IBOutlets
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var HomeMountianText: UITextField!
    
    @IBOutlet weak var loginGoogle_btn: UIButton!
    
// MARK: Base Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.placeHolderUI()
        self.setDelegates()
        // Attempt to sign in silently, this will succeed if the user has recently been authenticated
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.checkLoginStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// MARK: IBActions
    @IBAction func login_btn(sender: AnyObject) {
        self.performSegueWithIdentifier("createAccountSegue", sender: nil)
    }

    @IBAction func createAccount_btn(sender: AnyObject) {
        self.createFirebaseAccount()
    }

    @IBAction func loginWithGoogle_btn(sender: AnyObject) {
       authenticateWithGoogle(loginGoogle_btn)
    }

// MARK: Unwind Segues
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
                signOut()
                print("logoutSegue performed")
            }
        }
    }
    

}

//MARK: - Firebase Helper Extension
extension LoginViewController {
    
    func checkLoginStatus(){
        rootRef.observeAuthEventWithBlock { (authData) -> Void in
            
            if authData != nil {
                self.performSegueWithIdentifier("loggedInAllSessionsSegue", sender: nil)
            }
            else {
                self.setFieldsBlank()
            }
        }
    }
    
    func createFirebaseAccount() {
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
                    self.presentViewController(self.creationErrorAlert(), animated: true, completion: nil)
                }
                else
                {
                    let uid = result["uid"] as? String
                    print("Successfully created user account with uid: \(uid!)")
                    self.rootRef.authUser(email, password: password) { (error, authData) -> Void in
                        if error != nil
                        {
                            print("There was an error while logging in \(error)")
                            self.presentViewController(self.creationErrorAlert(), animated: true, completion: nil)
                        }
                        else
                        {
                            print("successfully logged in")
                            let newUser = ["fullName": fullName!, "email": email!, "homeMountain": homeMountain!, "sessionUnits": "false"]
                            
                            let usersRef = self.rootRef.childByAppendingPath("users/\(self.rootRef.authData.uid)")
                            
                            usersRef.setValue(newUser)
                            
                            self.performSegueWithIdentifier("loggedInAllSessionsSegue", sender: nil)
                        }
                    }
                }
            })
            
        }
            
        else
        {
            //create alert presentation
            
            
            self.presentViewController(self.createUserAlert(), animated: true, completion: nil)
            print("A field was not filled out")
        }
        
    }
    
    func googleSignIn() {
    let settings = ["sessionUnits": self.unitsSetting]
    let userName = rootRef.authData.providerData["displayName"]
    let userInfo = ["sessionUnits": unitsSetting, "fullName": userName!]
        
    let usersRef = self.rootRef.childByAppendingPath("users/\(self.rootRef.authData.uid)")
        
    usersRef.setValue(userInfo)
    }
    
}

//MARK: - UIHelper Extension
extension LoginViewController {
    
    func placeHolderUI() {
        emailText.attributedPlaceholder = NSAttributedString(string:"EMAIL", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordText.attributedPlaceholder = NSAttributedString(string: "PASSWORD", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        nameText.attributedPlaceholder = NSAttributedString(string: "NAME", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        HomeMountianText.attributedPlaceholder = NSAttributedString(string: "HOME MOUNTAIN", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
    func setDelegates(){
        emailText.delegate = self
        passwordText.delegate = self
        nameText.delegate = self
        HomeMountianText.delegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func setFieldsBlank(){
        self.emailText.text = ""
        self.passwordText.text = ""
        self.HomeMountianText.text = ""
        self.nameText.text = ""
    }
    
    func createUserAlert() -> UIAlertController {
        let createUserAlert = UIAlertController(title: "Oops!", message: "There was an error creating your account. Check that all fields are filled out, then give it another shot.", preferredStyle: UIAlertControllerStyle.Alert)
        
        createUserAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
            print("message dismissed")
        }))
        
        return createUserAlert
    }
    
    func creationErrorAlert() -> UIAlertController {
        let creationErrorAlert = UIAlertController(title: "Uh oh...", message: "There was an error creating your account. Make sure you're connected and try again.", preferredStyle: UIAlertControllerStyle.Alert)
        
        creationErrorAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
            print("message dismissed")
        }))
        
        return creationErrorAlert
    }
    
}

// MARK: - Google Extension
extension LoginViewController {
    
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
                    // User is logged in
                    self.googleSignIn()
                })
            } else {
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

// MARK: - Text Delegate Extension
extension LoginViewController: UITextFieldDelegate {
    
    //when the keyboard 'Go' button is tapped...
    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
        if textField.returnKeyType == UIReturnKeyType.Next {
            if textField == nameText {
                emailText.becomeFirstResponder()
            }
            if textField == emailText {
                passwordText.becomeFirstResponder()
            }
            if textField == passwordText {
                HomeMountianText.becomeFirstResponder()
            }
        }
        else
        {
            textField.resignFirstResponder()
            self.createFirebaseAccount()
        }
        
        return true
    }
    
    //if a user taps outside the text field then hide the keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        nameText.resignFirstResponder()
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
        HomeMountianText.resignFirstResponder()
        
    }
}



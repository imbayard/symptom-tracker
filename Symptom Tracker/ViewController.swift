//
//  ViewController.swift
//  Symptom Tracker
//
//  Created by Bayard Eton on 9/8/20.
//  Copyright © 2020 Bayard Eton. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseDatabase

// Typical user flow:
//         Login --> Dashboard --> Symptom Tracker --> Dashboard --> Data page (with API)
//         Login --> Dashboard --> Data page (with API)
// Segues:
//         Login --> Dashboard
//         Data --> Dashboard
//         Symptom Tracker --> Dashboard
//         Dashboard --> Symptom Tracker
//         Dashboard --> Data page

class ViewController: UIViewController, GIDSignInDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error)
            return
        }
        print(user.profile.email) // Instead of printing we want to send this to database
        performSegue(withIdentifier: "Login_To_Dash", sender: ViewController())
    }
}

class SymptomTracker_ViewController: UIViewController {
    
    //Could pull from database and check if user has logged symptoms for the day already
    
    // Create database reference
    var refSymptomDb: DatabaseReference!
    // References to the symptom segment sliders in HomePage_ViewController
    @IBOutlet weak var cough_switch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        refSymptomDb = Database.database().reference().child("symptoms")
    }
    
    // The 'on click' function triggered after user presses submit

    @IBAction func submitSymptoms(_ sender: UIButton) {
        addSymptoms()
    }
    
    
    // Record the symptoms in the database
    func addSymptoms() {
        // Need to find some way of ensuring an account can only record symptoms once per day
        // Research user privileges, account privileges, etc with firebase
        let key = refSymptomDb.childByAutoId().key
        let symptoms = [
            "key": key,
            "cough": cough_switch.isOn,
            ] as [String : Any]
        print(symptoms)
        refSymptomDb.child(key ?? "abc").setValue(symptoms)
        
        // Symptoms:
        //     Fever (100 deg)
        //     Cough
        //     Shortness of breath / difficulty breathing
        //     Sore throat
        //     New loss of taste or smell
        //     Vomiting
        //     Severe fatigue
        //     Severe muscle aches
        
        // We want to
        //            1) Pull from database and get current number of "Cough", "Fever", etc
        //            2) Pull from user input and add the values to the database values
        //               i.e. if User enters yes for cough, the cough value gets +1
        //            3) Push the new value back to the database
        //            4) (Maybe?) Error check to see that the new value is correct
        
    }
    
}

class HomePage_ViewController: UIViewController {
    
    //Need to move code from here --> Another View Controller called "Symptom Tracker"
    

}


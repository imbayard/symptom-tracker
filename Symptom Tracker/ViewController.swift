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
import Foundation

// Typical user flow:
//         Login --> Dashboard --> Symptom Tracker --> Dashboard --> Data page (with API)
//         Login --> Dashboard --> Data page (with API)
// Segues:
//         Login --> Dashboard (covered on sign in)
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
            guard let myError = error else { return }
            print(myError)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                            accessToken: authentication.accessToken)
        // Sign in to firebase
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("firebase sign in error")
                print(error)
                return
            }
            guard let email = user.profile.email else { return }
            print("User is signed in", email)
        }
        performSegue(withIdentifier: "Login_To_Dash", sender: ViewController())
    }
}

class SymptomTracker_ViewController: UIViewController {
    
    //Could pull from database and check if user has logged symptoms for the day already
    
    // Create database reference
    var refSymptomDb: DatabaseReference!
    
    // References to the symptom switches
    @IBOutlet weak var cough_switch: UISwitch!
    @IBOutlet weak var fever_switch: UISwitch!
    
    
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
        
        // Get numerical value for a symptom
        let cough = cough_switch.isOn ? 1:0
        let fever = fever_switch.isOn ? 1:0
        
        // Set symptoms here (prep for sending to firebase)
        let symptoms = [
            "cough": cough,
            "fever": fever,
            ] as [String : Any]
        
        // Print to console to see if formatted correctly
        print(symptoms)
        
        // Uncomment this when we want to send a response to firebase
        // refSymptomDb.child(key!).setValue(symptoms)
        
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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
}

class StatsView_ViewController: UIViewController {
    @IBOutlet weak var global_cases_label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let semaphore = DispatchSemaphore (value: 0)
        
        // Create URL object
        guard let url = URL(string: "https://api.covid19api.com/summary") else {
            print ("Error creating URL")
            return
        }
        
        // Create request for API
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
    
}


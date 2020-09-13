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
    var databaseHandle: DatabaseHandle!
    
    // References to the symptom switches
    @IBOutlet weak var cough_switch: UISwitch!
    @IBOutlet weak var fever_switch: UISwitch!
    @IBOutlet weak var shortness_of_breath_switch: UISwitch!
    @IBOutlet weak var sore_throat_switch: UISwitch!
    @IBOutlet weak var loss_taste_smell_switch: UISwitch!
    @IBOutlet weak var vomiting_switch: UISwitch!
    @IBOutlet weak var severe_fatigue_switch: UISwitch!
    @IBOutlet weak var severe_muscle_aches_switch: UISwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        refSymptomDb = Database.database().reference().child("symptoms")
    }
    
    // The 'on click' function triggered after user presses submit
    @IBAction func clickSubmit(_ sender: Any) {
        setRealtimeSymptoms()
        
        performSegue(withIdentifier: "After-Submit", sender: ViewController())
        return
    }
    
    func setRealtimeSymptoms() {
        
        // Get the current database values
        databaseHandle = refSymptomDb?.child("Symptoms").observe(.value, with: { (snapshot) in
            let snapshotValue = snapshot.value as! [String:AnyObject]

            // Update the cough symptom value
            let cough = snapshotValue["cough"] as! Int
            let fever = snapshotValue["fever"] as! Int
            let shortness_of_breath = snapshotValue["shortness of breath"] as! Int
            let sore_throat = snapshotValue["sore throat"] as! Int
            let loss_taste_smell = snapshotValue["loss of taste or smell"] as! Int
            let vomiting = snapshotValue["vomiting"] as! Int
            let severe_fatigue = snapshotValue["severe fatigue"] as! Int
            let severe_muscle_aches = snapshotValue["severe muscle aches"] as! Int
            
            self.addSymptoms(cough: cough, fever: fever, shortness_of_breath: shortness_of_breath,
                sore_throat: sore_throat, loss_taste_smell: loss_taste_smell,
                vomiting: vomiting, severe_fatigue: severe_fatigue, severe_muscle_aches: severe_muscle_aches)
            })
        return
    }
    
    // Record the symptoms in the database
    func addSymptoms(cough: Int, fever: Int, shortness_of_breath: Int, sore_throat: Int, loss_taste_smell: Int, vomiting: Int, severe_fatigue: Int, severe_muscle_aches: Int) {
        // Need to find some way of ensuring an account can only record symptoms once per day
        // Research user privileges, account privileges, etc with firebase
    
        // Get numerical value for a symptom
        let cough_updated = cough + (cough_switch.isOn ? 1:0)
        let fever_updated = fever + (fever_switch.isOn ? 1:0)
        let shortness_of_breath_updated = shortness_of_breath + (shortness_of_breath_switch.isOn ? 1:0)
        let sore_throat_updated = sore_throat + (sore_throat_switch.isOn ? 1:0)
        let loss_taste_smell_updated = loss_taste_smell + (loss_taste_smell_switch.isOn ? 1:0)
        let vomiting_updated = vomiting + (vomiting_switch.isOn ? 1:0)
        let severe_fatigue_updated = severe_fatigue + (severe_fatigue_switch.isOn ? 1:0)
        let severe_muscle_aches_updated = severe_muscle_aches + (severe_muscle_aches_switch.isOn ? 1:0)
        
        // Set symptoms here (prep for sending to firebase)
        let symptoms = [
            "cough": cough_updated,
            "fever": fever_updated,
            "shortness of breath": shortness_of_breath_updated,
            "sore throat": sore_throat_updated,
            "loss of taste or smell": loss_taste_smell_updated,
            "vomiting": vomiting_updated,
            "severe fatigue": severe_fatigue_updated,
            "severe muscle aches": severe_muscle_aches_updated,
            ] as [String : Any]
        
        refSymptomDb.child("Symptoms").setValue(symptoms)
        resetSymptoms()
        return
    }
    func resetSymptoms(){
        cough_switch.setOn(false, animated: false)
        fever_switch.setOn(false, animated: false)
        shortness_of_breath_switch.setOn(false, animated: false)
        sore_throat_switch.setOn(false, animated: false)
        loss_taste_smell_switch.setOn(false, animated: false)
        vomiting_switch.setOn(false, animated: false)
        severe_fatigue_switch.setOn(false, animated: false)
        severe_muscle_aches_switch.setOn(false, animated: false)
    }
    
}

class HomePage_ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
}

class StatsView_ViewController: UIViewController {
    
    var refSymptomDb: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    
    // Outlets for symptom stats
    @IBOutlet weak var cough_number: UILabel!
    @IBOutlet weak var fever_number: UILabel!
    @IBOutlet weak var breath_number: UILabel!
    @IBOutlet weak var throat_number: UILabel!
    @IBOutlet weak var taste_number: UILabel!
    @IBOutlet weak var vomiting_number: UILabel!
    @IBOutlet weak var fatigue_number: UILabel!
    @IBOutlet weak var aches_number: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        refSymptomDb = Database.database().reference().child("symptoms")
        loadSymptoms()
    }

    func loadSymptoms() {
        databaseHandle = refSymptomDb?.child("Symptoms").observe(.value, with: { (snapshot) in
                let snapshotValue = snapshot.value as! [String:AnyObject]

                // Update the symptom values
                let cough = snapshotValue["cough"] as! Int
                let fever = snapshotValue["fever"] as! Int
                let shortness_of_breath = snapshotValue["shortness of breath"] as! Int
                let sore_throat = snapshotValue["sore throat"] as! Int
                let loss_taste_smell = snapshotValue["loss of taste or smell"] as! Int
                let vomiting = snapshotValue["vomiting"] as! Int
                let severe_fatigue = snapshotValue["severe fatigue"] as! Int
                let severe_muscle_aches = snapshotValue["severe muscle aches"] as! Int
                
                // Set the labels
                self.cough_number.text = String(cough)
                self.fever_number.text = String(fever)
                self.breath_number.text = String(shortness_of_breath)
                self.throat_number.text = String(sore_throat)
                self.taste_number.text = String(loss_taste_smell)
                self.vomiting_number.text = String(vomiting)
                self.fatigue_number.text = String(severe_fatigue)
                self.aches_number.text = String(severe_muscle_aches)
        })
        return
    }
    func apiCall() {
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


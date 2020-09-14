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
    var refUserDb: DatabaseReference!
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
    @IBOutlet weak var valid_submission: UISwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        refSymptomDb = Database.database().reference().child("symptoms")
        refUserDb = Database.database().reference().child("users")
    }
    
    // The 'on click' function triggered after user presses submit
    @IBAction func clickSubmit(_ sender: Any) {
        guard let user = Auth.auth().currentUser?.displayName else {
            print("No user")
            return
        }
        let dateObj = Date().description
        let dateComps = dateObj.components(separatedBy: " ")
        let date = dateComps.first!
        
        if valid_submission.isOn {
        refUserDb.child(date).child(user).setValue(true)
        setRealtimeSymptoms()
        performSegue(withIdentifier: "After-Submit", sender: ViewController())
        return
        } else { return }
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
            let entry_count = snapshotValue["total entries"] as! Int
            
            self.addSymptoms(cough: cough, fever: fever, shortness_of_breath: shortness_of_breath,
                sore_throat: sore_throat, loss_taste_smell: loss_taste_smell,
                vomiting: vomiting, severe_fatigue: severe_fatigue, severe_muscle_aches: severe_muscle_aches,
                entry_count: entry_count)
            })
        return
    }
    
    // Record the symptoms in the database
    func addSymptoms(cough: Int, fever: Int, shortness_of_breath: Int, sore_throat: Int, loss_taste_smell: Int, vomiting: Int, severe_fatigue: Int, severe_muscle_aches: Int, entry_count: Int) {
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
        let entry_count_updated = entry_count + (valid_submission.isOn ? 1:0)
        
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
            "total entries": entry_count_updated,
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
        valid_submission.setOn(false, animated: false)
    }
    
}

class HomePage_ViewController: UIViewController {
    
    var refSymptomDb: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    @IBOutlet weak var error_msg: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        refSymptomDb = Database.database().reference().child("users")
    }
    
    @IBAction func logSymptoms(_ sender: Any) {
        guard let user = Auth.auth().currentUser?.displayName else {
            print("No user")
            return
        }
        let dateObj = Date().description
        let dateComps = dateObj.components(separatedBy: " ")
        let date = dateComps.first!
        
        databaseHandle = refSymptomDb?.child(date).observe(.value, with: { (snapshot) in
            if (snapshot.value as! NSDictionary)[user] != nil{
                self.error_msg.text = "You Already Logged Symptoms Today"
                print("Should show")
            } else {
                self.performSegue(withIdentifier: "Log-Symptoms", sender: HomePage_ViewController())
            }
        })
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
    
    @IBOutlet weak var cough_percent: UILabel!
    @IBOutlet weak var fever_percent: UILabel!
    @IBOutlet weak var breath_percent: UILabel!
    @IBOutlet weak var throat_percent: UILabel!
    @IBOutlet weak var taste_percent: UILabel!
    @IBOutlet weak var vomiting_percent: UILabel!
    @IBOutlet weak var fatigue_percent: UILabel!
    @IBOutlet weak var aches_percent: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        refSymptomDb = Database.database().reference().child("symptoms")
        loadSymptoms()
        apiCall()
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
                let total_entries = snapshotValue["total entries"] as! Float
                
                // Set the numbers
                self.cough_number.text = String(cough)
                self.fever_number.text = String(fever)
                self.breath_number.text = String(shortness_of_breath)
                self.throat_number.text = String(sore_throat)
                self.taste_number.text = String(loss_taste_smell)
                self.vomiting_number.text = String(vomiting)
                self.fatigue_number.text = String(severe_fatigue)
                self.aches_number.text = String(severe_muscle_aches)
            
                // Set the percentages
                self.cough_percent.text = String(format: "%.2f", ((Float(cough)/total_entries)*100))
                self.fever_percent.text = String(format: "%.2f", ((Float(fever)/total_entries)*100))
                self.breath_percent.text = String(format: "%.2f", ((Float(shortness_of_breath)/total_entries)*100))
                self.throat_percent.text = String(format: "%.2f", ((Float(sore_throat)/total_entries)*100))
                self.taste_percent.text = String(format: "%.2f", ((Float(loss_taste_smell)/total_entries)*100))
                self.vomiting_percent.text = String(format: "%.2f", ((Float(vomiting)/total_entries)*100))
                self.fatigue_percent.text = String(format: "%.2f", ((Float(severe_fatigue)/total_entries)*100))
                self.aches_percent.text = String(format: "%.2f", ((Float(severe_muscle_aches)/total_entries)*100))
        })
        return
    }
    @IBOutlet weak var total_global_label: UILabel!
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
            // Begin getting data
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
              guard let data = data else {
                print(String(describing: error))
                return
              }
              // Serialize JSON object
              guard let parsed = try? JSONSerialization.jsonObject(with: data, options: []) else { return }
                // Begin parsing
                guard let global = parsed as? [String: Any] else {
                    print("couldn't parse")
                    return
                }
                // Get next level of data
                let global_data = global["Global"]
                guard let parsed_global = global_data as? [String: Any] else {
                    print("couldn't parse global")
                    return
                }
              // Get and set the total confirmed cases count
              let total_confirmed = parsed_global["TotalConfirmed"] as! Int
              
              self.total_global_label.text = String(total_confirmed)
              semaphore.signal()
            }
            task.resume()
            semaphore.wait()
        }
}


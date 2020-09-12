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
        print(user.profile.email)
        performSegue(withIdentifier: "Homepage", sender: ViewController())
    }
}

class HomePage_ViewController: UIViewController {
    // Create database reference
    var refSymptomDb: DatabaseReference!
    // References to the symptom segment sliders in HomePage_ViewController
    @IBOutlet weak var CoughSymptom: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    // The 'on click' function triggered after user presses submit
    @IBAction func SubmitSymptoms(_ sender: UIButton) {
        addSymptoms()
    }
    
    // Record the symptoms in the database
    func addSymptoms() {
        //let key = refSymptomDb.childByAutoId().key
        let symptoms = [
            //"Cough": CoughSymptom.titleForSegment(at: CoughSymptom.selectedSegmentIndex),
            "Cough": CoughSymptom.selectedSegmentIndex
        ]
        print(symptoms)
        
        // We want to
        //            1) Pull from database and get current number of "Cough", "Fever", etc
        //            2) Pull from user input and add the values to the database values
        //               i.e. if User enters yes for cough, the cough value gets +1
        //            3) Push the new value back to the database
        //            4) (Maybe?) Error check to see that the new value is correct
    }
}


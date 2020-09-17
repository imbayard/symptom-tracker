README

Covid Tracking App (Database is in Firebase Realtime Database https://console.firebase.google.com/project/symptom-tracker-d565c/database/symptom-tracker-d565c/data)

End to end user flows:
    User logs into the application and enters into the Welcome page. User clicks the Symptom Tracker button and the Symptom Check page appears as the user has not filled out their symptoms for that current day. User fills out their present symptoms and clicks Submit. Welcome page reappears and the user can now check the Covid-19 stats by clicking the See Stats button. User clicks the Back Home button to get back to the Welcome page. The user will not be able to click the Symptom Tracker button again until the next day is present, an error message appearing in the meantime. 

View Controllers:
    ViewController
        The first page the user sees (log-in page)
    Methods:
        sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    Segues:
        ViewController —> HomePage

   HomePage
        Holds “See Stats” and “Log Symptoms” Buttons
    Methods:
        logSymptoms(sender: Any)
            Checks if User has already logged symptoms
            Prints error if already logged
            Performs segue if not logged yet
    Segues:
        HomePage —> SymptomTracker
        HomePage —> StatsView

   SymptomTracker
        Where user can log symptoms for the day
    Methods:
        clickSubmit(sender: Any)
            Begins the chain of functions to log symptoms
            Tells database that the user has logged symptoms today
            Sends user back to homepage after completion of submission
        setRealtimeSymptoms()
            Pulls the current symptom numbers from the database
            Calls addSymptoms
        addSymptoms()
            Updates current symptom numbers with values from user input
            Updates database with those values
            Calls resetSymptoms()
        resetSymptoms()
            Resets all switches to ‘off’
    Segues:
        SymptomTracker —> HomePage

   StatsView
        Where user can see all current symptom numbers
        User can also see total global cases (updated daily)
        Methods:
            loadSymptoms()
                Sets the labels to show current symptom numbers / percentages
            apiCall()
                Makes the API call and parses the data
                Updates the label with the total confirmed cases tally
            Segues: 
                StatsView —> HomePage

	

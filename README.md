README

Covid Tracking App

End to end user flows:
	eg. User logs in, goes to log symptoms, then checks stats

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

	

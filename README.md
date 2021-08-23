# LocationTracker
This app will help track the location of the user and post the location details to backend services with a simple API call.

I have used URLSession to handle API Calls and Mapped JSON response to my CODABLE MODEL. All the codable models are tested with UNIT test with mock data.

I have used MVVM Architecture and cleanly designed the Location Tracking Feature, where TrackerViewController talks to ViewModel to update the VC and ViewModel talks to NetworkManager, Which has a generic function to return the JSON as codable models. And once the Async Api call is done ViewModel will let the VC know about the changes and proper alert messages will be shown to the user.

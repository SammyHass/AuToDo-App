// This is the root page of the app. When the app loads, this is the first file that has an effect. It is used to check whether the user is logged in and to direct the user to the correct page according to whether they are logged in. 

// import requirements.
import "package:flutter/material.dart";
import "login_page.dart";
import "auth.dart";
import "home_page.dart";

// Create a stateful widget so that the page can adapt to its environment. i.e. whether or not the user is logged in.
class RootPage extends StatefulWidget {
	RootPage({this.auth}); // Get auth data required to get the user logged in with the persistent system.
	final BaseAuth auth;
	@override
	State<StatefulWidget> createState() => new _RootPageState(); // Run _RootPageState which will check what page the user should be carried to next.
}

enum AuthStatus {
	notSignedIn,
	signedIn
}


class _RootPageState extends State<RootPage> { // Create a state that the RootPage can run in order to check whether the user is logged in.

	AuthStatus authStatus = AuthStatus.notSignedIn; // Default status is not signed in.

	@override
	void initState() {
    super.initState();

    widget.auth.currentUser().then((userId) {
    	setState(() { // check if there is a user session active, if there is, log them in and refresh the page to send them to homepage.
    	  authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
    	});
    });
  }

  void _signedIn() {
		setState(() {
		  authStatus = AuthStatus.signedIn;
		});
  }

  void _signedOut() {
	  setState(() {
		  authStatus = AuthStatus.notSignedIn;
	  });
  }

	@override
	Widget build(BuildContext context) { // create the stateful widget to build page structures
		switch (authStatus) {
			case AuthStatus.notSignedIn: // if not signed in
				return new LoginPage( // build login page
						auth: widget.auth,
						onSignedIn: _signedIn,
				);
			case AuthStatus.signedIn: //if signed in
				return new HomePage( // build home pages
					auth: widget.auth,
					onSignedOut: _signedOut,
				);
		}
  }
}
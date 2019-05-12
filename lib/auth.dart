import "dart:async";
import "package:firebase_auth/firebase_auth.dart";
import "helper.dart" as helper;

class User { // create user class which will act as a temporary place to keep data whilst server interactions are happening - this  speeds everything up.
		String uid;
		String firstName;
		String lastName;
		String email;
		Map lists;

		void update(helper.Todo todo, Function  after) { // create update method, to add a task to the user object.
			lists[todo.category].add({ // add task to a particular list selected with NLP
				"uid": todo.uid,
				"title": todo.title,
				"description": todo.description,
				"date": todo.date,
				"priority": todo.priority,
			});
			after();
		}

}
abstract class BaseAuth { // creates superclass to hold methods for login, sign in, register, sign out and currentUser (get data about user)
	Future<String> signInWithEmailAndPassword(String email, String password);
	Future<String> createUserWithEmailAndPassword(String email, String password, String first, String last);
	Future<String> currentUser();
	Future<void> signOut();
	User liveUser;
}

class Auth implements BaseAuth { // create sub class, inherited from BaseAuth
	User liveUser = new User(); // create an instance of user class that will store data from liveUser.
	final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // create an instance of FirebaseAuth in order to use the firebase authenticator.

	Future<String> signInWithEmailAndPassword(String email, String password) async { // method that will sign a user in using their email and password
		FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password); // use firebase to authenticate user.
		Map loginReq = await helper.getUserInfo(user.uid); // get the user's from the server.
		// below is storing user data within liveUser object.
		liveUser.firstName = loginReq["firstName"];
		liveUser.lastName = loginReq["lastName"];
		liveUser.uid = user.uid;
		liveUser.lists = loginReq["lists"];
		return user.uid; // return the  unique identifier of the current user.
	}

	Future<String> createUserWithEmailAndPassword(String email, String password, String first, String last) async { // method that will register a user with firebase and the server.
		FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password); // create a new user  with firebase
		Map registerReq = await helper.register(user.uid, first, last); // send request to server to add new user object.
		// below is storing user data within liveUser object.
		liveUser.firstName = registerReq["firstName"];
		liveUser.lastName = registerReq["lastName"];
		liveUser.uid = user.uid;
		liveUser.lists = registerReq["lists"];

		return user.uid;
	}

	Future<String> currentUser() async { // method to get current user data
		try {
			FirebaseUser user = await _firebaseAuth.currentUser(); // get the public data held by firebase about this user.
			print(user);
			if (user != null) {
				Map loginReq = await helper.getUserInfo(user.uid); // get user data from server
				// below is storing user data within liveUser object
				liveUser.firstName = loginReq["firstName"];
				liveUser.lastName = loginReq["lastName"];
				liveUser.uid = user.uid;
				liveUser.lists = loginReq["lists"];
				return user.uid;
			} else {
				return null;
			}

		} catch (e) {
			return null;
		}

	}
	Future<void> signOut() async { // method to sign out the user
		return _firebaseAuth.signOut(); // use firebase to sign out.
	}
}
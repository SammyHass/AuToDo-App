/// this file builds the UI for the user to login, and sends data to the server (and firebase) in order to authenticate the user and log them in.
/// In addition, this file also validates user input.

import "package:flutter/material.dart";
import "helper.dart" as helper;
import "package:firebase_auth/firebase_auth.dart";
import "auth.dart";

/// isEmail checks whether the argument 'em' is an email using a regex string.
bool isEmail(String em) { 
  String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = new RegExp(p);
  return regExp.hasMatch(em);
}

/// Creates the stateful widges, LoginPage, this is stateful so that it can update to alert the user of bad inputs.
class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onSignedIn}); // Build login page using the auth instructions given to it by root_page, home_page and auth (required to send requests to firebase).
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType {
  login,
  register
}

final loginFailedSnackbar = SnackBar(content: Text('Incorrect Email or Password'), duration: new Duration(seconds: 2),); // create snackbar (bar at bottom), which is showed if the user has an incorrect login, only shows if data was sent to server and no user was found.
final registerFailedSnackbar = SnackBar(content: Text("Seems like a user already has that email"), duration: new Duration(seconds: 2),); // create snackbar, which is showed if the user attempts to create an account and the server finds that such an account already exists.


class _LoginPageState extends State<LoginPage> { // create the initial State for the login page to hold.
  final formKey = new GlobalKey<FormState>(); // get the form key of the login/register form so that data can be collected from the form.
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _email; // create private variable for email to be held.
  String _password; // create private variable for password to be held.
  String _first; // create private variable for first name to be held.
  String _last; // create private variable for last name to be held.
  FormType _formType = FormType.login; // default form type on this page is login, therefore, login loads first.
  bool validateAndSave() {
    final form = formKey.currentState; // gets current state of form, i.e. all the values stored.
    if (form.validate()) { // validates form data.
      form.save(); // saves the current state of the form.
      return true; // success
    } else {
      return false; // fail
    }
  }


  void validateAndSubmit() async { // create validateAndSubmit function, which is to be run asynchronously.
    if (validateAndSave()) { // checks if validate and save worked, i.e. has the user entered valid data.
      try {
        if (_formType == FormType.login) { // if the form is of type login.
          String userId = await widget.auth.signInWithEmailAndPassword(_email, _password); // use auth package (in auth.dart) to sign in the user.
          print("Signed in: $userId");
        } else { // if form type is register
          String userId = await widget.auth.createUserWithEmailAndPassword(_email, _password, _first, _last); // use auth package to register the user.
          print("Registered user: $userId");
        }
        widget.onSignedIn();
      } catch (e) { // an error is called if the above code fails, therefore, must be enclosed within try-catch.
        if (_formType == FormType.login) { // if the login fails (no user with credentials)
          _scaffoldKey.currentState.showSnackBar(loginFailedSnackbar); // show fail snackbar for login
        }
        if (_formType == FormType.register) { // if the register fails
          _scaffoldKey.currentState.showSnackBar(registerFailedSnackbar); // show snackbar for register
          formKey.currentState.reset(); // reset the form and clear values.
        }
        print("Error: $e"); // log out the error (for debugging)
      }
    }
  }

  void moveToLogin() { // change state to login. (if user is on register page and clicks login button, this is called)
    formKey.currentState.reset(); // clear form
    setState(() { // refresh this page 
      _formType = FormType.login; // switch to login form
    });
  }
  void moveToRegister() { // change state to register. (if user is on login page and clicks register button, this is called)
    formKey.currentState.reset(); // clear form
    setState(() { // refresh page
      _formType = FormType.register; // switch to register form
    });
  }
  @override
  Widget build(BuildContext context) { // build the UI for this page.
    List<Widget> buildInputs() { // method to build inputs required for both login and register.
      return [new TextFormField( // create a text field to hold email
        decoration: new InputDecoration(labelText: "Email"), // add placeholder
        validator: (value) => !isEmail(value) ? "Must be an email" : null, // validate if email is valid.
        onSaved: (value) => _email = value, // put value of this field into private _email variable to be sent to server (happens on save).
      ),
      new TextFormField( // create a text field to hold password
        decoration: new InputDecoration(labelText: "Password"), // add placeholder
        obscureText: true, // make password hashed out from view during input.
        validator: (value) => value.length <= 6 ? "Password must be at least 6 characters long" : null, // validate password is more than 6 digits long.
        onSaved: (value) => _password = value, // put value of this field into private _password variable to be sent to server.
      )];
    }

    List<Widget> buildExtra() { // method to build any addition input fields, either state may require.
      if (_formType == FormType.register) { // if page is in register state
        return [new TextFormField(  // create first name field
          decoration: new InputDecoration(labelText: "First Name"),
          validator: (value) => value.isEmpty ? "Field can't be empty." : null, // run prescence check on field.
          onSaved: (value) => _first = value // save first name into _first variable.
        ),
        new TextFormField( // create last name field
            decoration: new InputDecoration(labelText: "Last Name"), 
            validator: (value) => value.isEmpty ? "Field can't be empty." : null, // run prescence check on field.
            onSaved: (value) => _last = value // save last name into _last variable.
        )];
      } else { // if page is in login state
        return [new Container()]; // do not build any inputs.
      }
    }

    List<Widget> buildSubmitButtons() { // method to build submit buttons.
      if (_formType == FormType.login) { // if state is login
        return [new Container( margin: EdgeInsets.all(15)), new FlatButton( //  create button for holding login submit button.
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: new Text("Login",
                  style: new TextStyle(fontSize: 20.0, color: Colors.white))),
          onPressed: validateAndSubmit, // when button is pressed, attempt to login the user.
          color: Colors.blueAccent,
          shape: StadiumBorder(),
        ),
        new FlatButton( // create move to register button.
          onPressed: moveToRegister, // switch state to register when pressed.
          child: new Text("Don't have an account? Sign Up"),
        )
        ];
      } else { // if state is on register.
        return [new Container( margin: EdgeInsets.all(15)), new FlatButton( // build submit button for registration form.
          child: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: new Text("Create Account", style: new TextStyle(fontSize: 20.0, color: Colors.white))),
          onPressed: validateAndSubmit, // submit registration form when pressed.
          color: Colors.redAccent
        ),
        new FlatButton( // create move to login button.
          onPressed: moveToLogin,  // switch state to login when pressed.
          child: new Text("Already have an account? Login"),
        ),
        ];
      }
    }
    return new Scaffold( // build page using methods declared above
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("Todo"),
        elevation: 0.0,
      ),
      body: new Container( // create the body of the page.
          padding: EdgeInsets.all(16.0),
          child: new Form( // create the form
            key: formKey, // use form key declared above.
            child: new ListView(
              children: buildExtra() + buildInputs() + buildSubmitButtons(), // put the form together.
            )
          )
      )
    );


  }
}
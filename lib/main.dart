// this file runs when app is opened, this will load the app.
import "package:flutter/material.dart";
import "auth.dart";
import "root_page.dart";

void main() {  // runs when app is opened from user's home screen.
  runApp(new MyApp()); // build the app
}

class MyApp extends StatelessWidget { //  build the app initially as a stateless widget
  @override
  Widget build(BuildContext context) { // build the UI for the user as the app is loading
    return new MaterialApp( // return a new app.
      title: "Todo",
      theme: new ThemeData(
        primarySwatch: Colors.blue,

      ),
      home: new RootPage(auth: new Auth()) // run the root_page once the app has loaded.
    );
  }
}

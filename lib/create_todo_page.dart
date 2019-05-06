/// This file contains 'scaffolding' code to create a task page.
/// In addition, it shows and validates the new task form.     

import "package:flutter/material.dart";
import "auth.dart";
import "home_page.dart";
import 'package:intl/intl.dart';
import "helper.dart";

// Creates Page as a Stateful Widget in order so that it can adapt to the users actions
class CreateTodoPage extends StatefulWidget { 
	final BaseAuth auth;
	CreateTodoPage({this.auth}); // Use the auth.dart package in order to authenticate the user when they submit their task.

	_CreateTodoPageState createState() => _CreateTodoPageState();

}

class _CreateTodoPageState extends State<CreateTodoPage> { // declares a state of the stateful widget declared above
	DateTime _date = new DateTime.now().add(new Duration(hours: 24)); // Get current date and time
	TimeOfDay _time = new TimeOfDay.now();
	// private variables for form values to occupy.
	int _priority = 0; 
	String _title;
	String _desc;

	void _handleRadioValueChange(int value) { // method to handle the changing of the radio buttons (priority input)
		setState(() {
			_priority = value;
		});
	}
	Future<Null> _selectDate(BuildContext context) async { // method to build a date picker
		final DateTime picked = await showDatePicker(
				context: context,
				initialDate: _date,
				firstDate: DateTime.now(),
				lastDate: new DateTime(2022)
		);
		if (picked != null) {
			print("Date Selected ${_date.toString()}");
			setState(() {
				_date = new DateTime(picked.year, picked.month, picked.day, _time.hour, _time.minute); // date selected stored in a priv variable.
			});
		}
	}

	Future<Null> _selectTime(BuildContext context) async { // method to build time picker
		final TimeOfDay picked = await showTimePicker(
				context: context,
				initialTime: _time
		);
		if (picked != null) {
			print("Date Selected ${_time.toString()}");
			print("${_time.hour} + ${_time.minute}");
			setState(() {
				_time = picked;
				_date = new DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute); // time selected stored in a priv variable.
			});
		}
	}

	bool validateAndSave() { // validates the input of the forms.
		final form = formKey.currentState; // use the form key to get the inputs.
		if (form.validate()) { // runs validate methods attached to each input
			form.save(); // saves values in form so that they can be submitted to the server.
			return true; // successful validation
		} else {
			return false; // failure to validate inputs

		}
	}

	void validateAndSubmit() async { // method to send new task to the server.
		if (validateAndSave()) { // only if data valid
			Todo todo = new Todo(widget.auth.liveUser.uid, _title, _desc, _date.toString(), _priority, "errands"); // create an instance of the task class to hold user input.
			print(todo.title); 
			todo.pushToServer(); // send the task to server to be stored in the database.
			widget.auth.liveUser.update(todo); // update the current state of the app to reflect the changes happening server-side.
			Navigator.pop( // Go back to the homepage.
				context,
				MaterialPageRoute(builder: (context) => HomePage(auth: widget.auth)),
			); 
		}
	}



	List<Widget> buildInputs() { // method to build scaffolding for inputs.
		return [
			new TextFormField( // create input for title of task
					decoration: new InputDecoration(labelText: "Title", icon: new Icon(Icons.title)),
					validator: (value) => value.length < 3 ? "Title must be longer than three characters": null,
					onSaved: (value) => _title = value,
			),
			new TextFormField( // create multiline input for description of task
					keyboardType: TextInputType.multiline,
					decoration: new InputDecoration(labelText: "Description", icon: Icon(Icons.description)),
					onSaved: (value) => _desc = value,
			),
			new Container( // blank space
				padding: EdgeInsets.all(10),
			),
			new Container( // create date and time inputs.
				child: new Row(crossAxisAlignment: CrossAxisAlignment.start,
					mainAxisAlignment: MainAxisAlignment.center, 
					children: <Widget>[ 
						new FlatButton(child: new Text("Due Date", style: new TextStyle(color: Colors.white)), onPressed: () {
							_selectDate(context);
						}, color: Colors.redAccent, shape: StadiumBorder(), padding: EdgeInsets.symmetric(horizontal: 55),),
						new Container(
							padding: EdgeInsets.all(5),
						),
						new FlatButton(child: new Text("Due Time", style: new TextStyle(color: Colors.white),), onPressed: () {
							_selectTime(context);
						}, color: Colors.green, shape: StadiumBorder() ,padding: EdgeInsets.symmetric(horizontal: 55),),
			])),
			new Container(padding: EdgeInsets.all(10)),
			new Text("Due ${dateFormatter.format(_date)}", textAlign: TextAlign.center, textScaleFactor: 1.4, style: TextStyle(fontWeight: FontWeight.bold),), // show user the date and time they entered.
			new Container(padding: EdgeInsets.all(10)),
			new Row(
				mainAxisAlignment: MainAxisAlignment.center,
				children: <Widget>[ // create radio buttons and label for priority input.
					new Container(
						child: new Text("Priority", textScaleFactor: 1.4, style: TextStyle(fontWeight: FontWeight.bold),),
						padding: const EdgeInsets.symmetric(vertical: 20),
					),
					// radio button for low priority (green)
					new Radio(
						value: 0,
						groupValue: _priority,
						onChanged: _handleRadioValueChange,
						activeColor: Colors.green,
					),
					// radio button for medium priority (amber)
					new Radio(
						value: 1,
						groupValue: _priority,
						onChanged: _handleRadioValueChange,
						activeColor: Colors.amber,
					),
					// radio button for high priority (red)
					new Radio(
						value: 2,
						groupValue: _priority,
						onChanged: _handleRadioValueChange,
						activeColor: Colors.redAccent,
					)
				],
			),
			// submit button to validate inputs and then submit them to the server.
			new RaisedButton(onPressed: validateAndSubmit, color: Colors.blueAccent, shape: StadiumBorder(), child: Text("Go!", style: new TextStyle(color: Colors.white)))
		];
	}
	final formKey = new GlobalKey<FormState>(); // create a form key so that inputs can be collected.
	@override
	Widget build(BuildContext context) { // build the widgets on this page
		return new Scaffold(
				appBar: new AppBar( // create title bar
					title: new Text("Create New Task"),
				),
				body: new Container( // build the inputs
					padding: EdgeInsets.all(16.0),
						child: new Form(
								key: formKey, // use the generated form key
								child: new Column(
									crossAxisAlignment: CrossAxisAlignment.stretch,
									children: buildInputs(), // use the buildInputs method to build the inputs.
								)
						)
				)
		);
	}
}




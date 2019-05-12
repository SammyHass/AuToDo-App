/// This file contains 'scaffolding' code to create a task page.
/// In addition, it shows and validates the new task form.     

import "package:flutter/material.dart";
import "auth.dart";
import "home_page.dart";
import "helper.dart";
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';


// Creates Page as a Stateful Widget in order so that it can adapt to the users actions
class CreateTodoPage extends StatefulWidget { 
	final BaseAuth auth;
	CreateTodoPage({this.auth}); // Use the auth.dart package in order to authenticate the user when they submit their task.

	_CreateTodoPageState createState() => _CreateTodoPageState();

}

class _CreateTodoPageState extends State<CreateTodoPage> { // declares a state of the stateful widget declared above
	DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
	TimeOfDay _selectedTime = TimeOfDay.fromDateTime(DateTime.now().add(Duration(days: 1)));
	static const platform = const MethodChannel('todo.sammyhass.io/ML');
	String _category = "work";

	Future<void> _getTaskPrediction(String title) async {
		String category;
		try {
			category = await platform.invokeMethod("getTaskPrediction", <String, String>{"title": title});
		} on PlatformException catch (e) {
			category = category;
			print("Could connect" + e.toString());
		}

		setState(() {
			_category = category;
		});
	}

	// private variables for form values to occupy.
	int _priority = 0; 
	String _title;
	String _desc;

	void _handleRadioValueChange(int value) { // method to handle the changing of the radio buttons (priority input)
		setState(() {
			_priority = value;
		});
	}

	bool _alert = false;
	Future<void> _selectDate(BuildContext context) async { // method to build a date picker
		_alert = true;
		final DateTime picked = await showDatePicker(
				context: context,
				initialDate: _selectedDate,
				firstDate: DateTime.now().subtract(Duration(days: 1)),
				lastDate: new DateTime(2022)
		);
		if (picked != null && picked != _selectedDate) {
			setState(() {
					_selectedDate = picked;
			});
		}
	}

	Future<void> _selectTime(BuildContext context) async { // method to build time picker
		final TimeOfDay picked = await showTimePicker(
				context: context,
				initialTime: _selectedTime,
		);
		if (picked != null && picked != _selectedTime) {
			setState(() {
					_selectedTime = picked;
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
			await _getTaskPrediction(_title);
			Todo todo = new Todo(widget.auth.liveUser.uid, _title, _desc, dateFormatter.format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute)), _priority, _category); // create an instance of the task class to hold user input.
			await todo.pushToServer(() {
				  widget.auth.currentUser().then((String res) {
						  Navigator.pushAndRemoveUntil(
								  context,
								  MaterialPageRoute(
										  builder: (context) => HomePage(auth: widget.auth)
								  ),
								  (_) => false

						  );

				  });
			}); // update the current state of the app to reflect the changes happening server-side.
		}
	}



Form buildInputs() { // method to build scaffolding for inputs.
		return new Form(
			key: formKey, // use the generated form key
			child: new ListView(
				children: [			new TextFormField( // create input for title of task
					decoration: new InputDecoration(labelText: "Title", icon: new Icon(Icons.title)),
					validator: (value) => value.length < 3 ? "Title must be longer than three characters": null,

					onSaved: (value) => _title = value,
				),
				Container(padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0)),
				new TextFormField( // create  multiline input for description of task
					maxLines: null,
					keyboardType: TextInputType.multiline,
					maxLengthEnforced: true,
					decoration: new InputDecoration(hintText: "Description", icon: Icon(Icons.description)),
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
								print(_selectedTime.hour + _selectedTime.periodOffset);
								_selectDate(context);
							}, color: Colors.redAccent, shape: StadiumBorder(), padding: EdgeInsets.symmetric(horizontal: 20),),
							new Container(
								padding: EdgeInsets.all(5),
							),
							new FlatButton(child: new Text("Due Time", style: new TextStyle(color: Colors.white),), onPressed: () {
								_selectTime(context); print(_selectedTime.period);
							}, color: Colors.green, shape: StadiumBorder() ,padding: EdgeInsets.symmetric(horizontal: 20),),
						])),
				new Container(padding: EdgeInsets.all(10)),
				new Text("Due ${timeago.format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute), allowFromNow: true)}", textAlign: TextAlign.center, textScaleFactor: 1.4, style: TextStyle(fontWeight: FontWeight.bold)), // show user the date and time they entered.
				new Container(padding: EdgeInsets.only(bottom: 6),),
				new Text(dateFormatter.format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute)), textScaleFactor: 1, textAlign: TextAlign.center,),
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
				], // use the buildInputs method to build the inputs.
			)
		);

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
						child: buildInputs()
				)
		);
	}
}




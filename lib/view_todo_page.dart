// This file creates the page that will show the user details of their task.
// The page will be built when the suer clicks on a certain task


import "package:flutter/material.dart";
import "auth.dart";
import "home_page.dart";
import 'package:intl/intl.dart';
import "helper.dart" as helper;
import 'package:flutter/cupertino.dart';

class ViewTodoPage extends StatefulWidget { // create a stateful widget so that the view todo page can adapt to any task the user has.
	final BaseAuth auth;
	final String todoId;
	final String todoCat;
	ViewTodoPage({this.auth, this.todoId, this.todoCat}); // this page requires auth, and the id and category of the task so that it can show that task.

	_ViewTodoPageState createState() => _ViewTodoPageState();

}

class _ViewTodoPageState extends State<ViewTodoPage> { // create a state for the view todo page.

	int pageState = 0; // declare pageState as 0, if pageState is 1, the task being viewed is being deleted.


	Widget build(BuildContext context) { // build the UI of this page.
		var thisTodo = widget.auth.liveUser.lists[widget.todoCat].singleWhere((todo) => todo["id"] == widget.todoId); // locate the todo within the user object
		List<Widget> getContents() { // method to generate the widgets with data about the task.
			var formatter = new DateFormat("dd/mm/yyyy hh:mm");
			List<MaterialColor> iconColors = [Colors.green, Colors.amber, Colors.red];
			var priorityIconColour = iconColors[thisTodo["priority"]];
			if (pageState == 0) { // if in edit mode.
				return [ // create the widgets to show task.
							new Center(child: new Column(children: <Widget>[
								new Text(
								thisTodo["title"],
									textAlign: TextAlign.center,
									textScaleFactor: 2,
								), // shows the title of the task

							new Container(
								padding: EdgeInsets.symmetric(vertical: 5), // adds some vertical space.
							),
							new Row( // shows the description of the task
									children: [
										new Text(
											thisTodo["description"],
										),
									]
							),
							new Container( // make some vertical space between description and the due date.
								padding: EdgeInsets.symmetric(vertical: 5),
							),
							new Row(
									children: [ // show due date and time
										new Text(
											"Due ${thisTodo["date"]}",
											style: new TextStyle(fontWeight: FontWeight.bold),
										),
									]
							),
							new Row(
									children: [
										new CupertinoButton(onPressed: () { //create a button that deletes the task.
												setState(() {
													Navigator.pop(
														context,
														MaterialPageRoute(builder: (context) => HomePage(auth: widget.auth)),

													); // on press, this button deletes this task from the server and redirects the user back to the home page.
												// remove the task
											});
												helper.deleteTodo(widget.auth.liveUser.uid, thisTodo["id"], widget.todoCat);
												widget.auth.liveUser.lists[widget.todoCat].removeWhere((todo) => todo["id"] == thisTodo["id"]);
										}, child: Text("Delete This Task"))
									]
							)]
			))];
			} else { // if in delete task mode. i.e. user pressed delete button.
				print(thisTodo);
				return [
					Center( // create a confirm box to ask the user if they are sure they want to delete the task.
						child: Column(
							children: <Widget>[
								Text("Delete the task '${thisTodo["title"]}'?"), // show text asking if task should be deleted.
								CupertinoButton( // confirm deletion button
									child: Text("Mark Done"),
									onPressed: () async {
										print(widget.todoCat);
										helper.deleteTodo(widget.auth.liveUser.uid, thisTodo["id"], widget.todoCat);
										widget.auth.liveUser.lists[widget.todoCat].removeWhere((todo) => todo["id"] == thisTodo["id"]);
										Navigator.pop(
											context,
											MaterialPageRoute(builder: (context) => HomePage(auth: widget.auth)),
										); // on press, this button deletes this task from the server and redirects the user back to the home page.
									},
									color: Colors.red,
								),
							],
						),
					)

				];
			}
		}
		return new Scaffold(
			appBar: new AppBar( // create title bar for the page.
				title: new Text("Task", textAlign: TextAlign.left),
			),
			body: new Container( 
			padding: EdgeInsets.all(16.0),
				child: new ListView(
						children: getContents() // run getContents to build the widgets for this page using the uid of the task.
					)
			),
		);
	}

}
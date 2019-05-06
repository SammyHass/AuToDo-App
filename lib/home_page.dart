/// this file builds the home page, which is shown if the user is logged in.
import "package:flutter/material.dart";
import "auth.dart";
import "helper.dart" as helper;
import "create_todo_page.dart";
import "view_todo_page.dart";



class HomePage extends StatefulWidget { // create stateful widget for home page. This is so that all new tasks can be stored.
	final BaseAuth auth;
	final VoidCallback onSignedOut;
	HomePage({this.auth, this.onSignedOut}); // build the page using the auth package (auth.dart)

	_HomePageState createState() => _HomePageState(); // load the initial state for this page 

}
	class _HomePageState extends State<HomePage> { // The initial state for this page.
		List<Widget> getTasks() { // method to get and show all tasks.
			List<Widget> widgets = []; // list that will hold all widgets generated within this function. will contain the tasks and list title.
			Map lists = widget.auth.liveUser.lists; // get the lists from the user object.
			lists.forEach((category, list) { // go through all lists
				print(lists[category]);
				widgets.add( // push the widget holding the category title to the widgets list.
					Center(child: Text(
						category,
						style: TextStyle(
								fontWeight: FontWeight.bold,),
								textScaleFactor: 2,)
					),
				);
				widgets.add( // add some vertical space to seperate out each element.
					Container(padding: EdgeInsets.symmetric(vertical: 16))
				);
				for (int i = 0; i < lists[category].length; i++) { // iterate over each task in this list.
					print(lists[category][i]["title"]);
					Color priorityIconColour;
					print(lists[category][i]["priority"]);
					List<MaterialColor> iconColors = [Colors.green, Colors.amber, Colors.red];
					priorityIconColour = iconColors[lists[category][i]["priority"]];
					widgets.add( // add button with title of this task in colour dependent on priority level. Button link to view task page.
							Container(
								child:
								FlatButton(
										onPressed: ()  {
											Navigator.push(
												context,
												MaterialPageRoute(builder: (context) => ViewTodoPage(auth: widget.auth, todoCat: category, todoId: widget.auth.liveUser.lists[category][i]["id"])),
											);
										},
										splashColor: Colors.blue,

										child: Center(
											child: Row(
												children: [
													Icon(
														Icons.priority_high,
														color: priorityIconColour,
													),
													Text(
														lists[category][i]["title"],
														textScaleFactor: 1.2, style: TextStyle(color: Colors.black), textAlign: TextAlign.center,
													),
												]
											),
										),
								),
								width: double.infinity,
							),
					);
				}
			});
			return widgets; // return the list created containing widgets to add.
		}
		void _signOut() async { // sign out method, attached to button.
			try {
				await widget.auth.signOut();
				widget.onSignedOut(); // user will be signed out and redirected to login page.
			} catch (e) {
				print(e);
			}
		}

		@override
		Widget build(BuildContext context) { // build the UI of page.
			return new Scaffold(
					appBar: new AppBar( // create top bar.
						title: new Text("Welcome, ${widget.auth.liveUser.firstName}!", textAlign: TextAlign.left),
						actions: <Widget>[
							new RotatedBox(quarterTurns: 2, child: IconButton(onPressed: _signOut, icon: new Icon(Icons.exit_to_app)))
						],
					),
					body: new Container( // build body of page.
						padding: EdgeInsets.all(16.0),
						child: new SingleChildScrollView(
							child: new Column(
								children: getTasks() // get all tasks from server.
							)
						),
					),
				floatingActionButton: FloatingActionButton( // create add task button.
					onPressed: ()  {
						Navigator.push(
							context,
							MaterialPageRoute(builder: (context) => CreateTodoPage(auth: widget.auth,)), // on pressed, send user to create task page.
						);
					},
					tooltip: "Add Todo",
					child: Icon(Icons.add),
				),
					floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
			);
		}
	}

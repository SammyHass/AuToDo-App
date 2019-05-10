/// this file builds the home page, which is shown if the user is logged in.
import "package:flutter/material.dart";
import "auth.dart";
import "helper.dart" as helper;
import "create_todo_page.dart";
import "view_todo_page.dart";
import 'package:timeago/timeago.dart' as timeago;


class HomePage extends StatefulWidget { // create stateful widget for home page. This is so that all new tasks can be stored.
	final BaseAuth auth;
	final VoidCallback onSignedOut;
	HomePage({this.auth, this.onSignedOut}); // build the page using the auth package (auth.dart)

	_HomePageState createState() => _HomePageState(); // load the initial state for this page 

}

	abstract class ListItem {} // The base class for the different types of items the List can contain

// A ListItem that contains data to display a category
	class Category implements ListItem { // Create list item
		final String category;
		Category(this.category);
	}

// A ListItem that contains data to display a Task
class Task implements ListItem {
		final String title;
		final String id;
		final int  priority;
		final String category;
		String till;
		Task(this.title, this.till, this.id, this.priority, this.category);
	}
	class _HomePageState extends State<HomePage> { // The initial state for this page.
		dynamic getTasks() { // method to get and show all tasks.
			Map lists = widget.auth.liveUser.lists; // get the lists from the user object.
			if (lists == null) {
				lists = Map();
			}
			List<ListItem> items = []; // List for all widgets to build
			lists.forEach((category, list) {
				items.add(Category(category)); // Making the category into a widget
				list.forEach((item) {
					items.add(Task(item["title"], timeago.format(helper.dateFormatter.parse(item["date"]), allowFromNow: true), item["uid"], item["priority"], category));
				});

			});



			return new ListView.builder(
				// Let the ListView know how many items it needs to build
				itemCount: items.length,
				// Provide a builder function. This is where the magic happens! We'll
				// convert each item into a Widget based on the type of item it is.
				itemBuilder: (context, index) {
					final item = items[index];
					if (item is Category) {
						return ListTile(
							title: new Text(
								item.category,
								style: Theme.of(context).textTheme.headline,
							),
						);
					} else if (item is Task) {
						return Card(
							child: ListTile(
							title: Text(
								item.title,
							),
								subtitle: Text(
										item.till
								),
								leading: Icon(
									Icons.adjust,
									color: [Colors.green, Colors.amber, Colors.red][item.priority],
								),
							onTap: () {
								Navigator.push(context, MaterialPageRoute(
										builder: (context) => ViewTodoPage(auth: widget.auth, todoCat: item.category, todoId: item.id)
								));
							},

						)
						);}
				},
			);

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
						title: new Text("Welcome${widget.auth.liveUser.firstName != null ? " " + widget.auth.liveUser.firstName : ""}!", textAlign: TextAlign.left),
						actions: <Widget>[
							new RotatedBox(quarterTurns: 2, child: IconButton(onPressed: _signOut, icon: new Icon(Icons.exit_to_app)))
						],
					),
					body: new Container( // build body of page.
						padding: EdgeInsets.all(16.0),
								child: getTasks() // get all tasks from server
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

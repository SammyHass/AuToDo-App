/// this file builds the home page, which is shown if the user is logged in.
import "package:flutter/material.dart";
import "auth.dart";
import "helper.dart" as helper;
import "create_todo_page.dart";
import "view_todo_page.dart";
import 'package:timeago/timeago.dart' as timeago;
import 'package:rounded_modal/rounded_modal.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';




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
		DateTime date;
		String description;
		Task(this.title, this.till, this.id, this.priority, this.category, this.date, this.description);
	}

	class _HomePageState extends State<HomePage> {
		// The initial state for this page.
		dynamic getTasks() {
			// method to get and show all tasks.
			Map lists = widget.auth.liveUser
				.lists; // get the lists from the user object.
			if (lists == null) {
				lists = Map();
			}
			List<Task> items = []; // List for all widgets to build
			lists.forEach((category, list) {
				list.forEach((item) {
					items.add(Task(
						item["title"],
						timeago.format(
							helper.dateFormatter.parse(item["date"]), allowFromNow: true),
						item["id"],
						item["priority"],
						category,
						helper.dateFormatter.parse(item["date"]),
						item["description"]));
					print(item["date"]);
				});
			});
			items.sort((a, b) => a.date.compareTo(b.date));

			if (items.isEmpty) {
				return LiquidPullToRefresh(showChildOpacityTransition: true, child: ListView(children: <Widget>[ListTile(title: Text("No Tasks", textScaleFactor: 1.5), subtitle: Text("Add a task to get started."))]), onRefresh: () async{
					await widget.auth.currentUser(); // update list
					items = [];
					setState(() {
						getTasks();
					});
				});
			}
			return LiquidPullToRefresh(onRefresh: () async {
				await widget.auth.currentUser(); // update list
				items = [];
				setState(() {
					getTasks();

				});
			}, child:
				ListView.builder(padding: EdgeInsets.all(16),
				// Let the ListView know how many items it needs to build
				itemCount: items.length,
				// Provide a builder function. This is where the magic happens! We'll
				// convert each item into a Widget based on the type of item it is.
				itemBuilder: (context, index) {
					final item = items[index];
					if (item is Task) {
						return Dismissible(
							key: Key(item.id),
							background: Container(color: Colors.green,
								alignment: AlignmentDirectional(0.2, 0.0),
								child: ListTile(trailing: Icon(Icons.done),)),
							// We also need to provide a function that tells our app
							// what to do after an item has been swiped away.
							onDismissed: (direction) {
								// Remove the item from our data source.
								setState(() {
									helper.deleteTodo(
										widget.auth.liveUser.uid, item.id, item.category);
									 widget.auth.liveUser.lists[item.category].removeWhere((
										todo) => todo["id"] == item.id);
								});


								// Then show a snackbar!
								Scaffold.of(context).showSnackBar(
									SnackBar(content: Text("${item.title} was marked as done!")));
							},
							child: Card(
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.all(Radius.circular(25)),),
								child: ListTile(
									title: Text(
										item.title,
									),
									subtitle: Text(
										item.till
									),
									trailing: Text(item.category),
									leading: Icon(
										Icons.adjust,
										color: [Colors.green, Colors.amber, Colors.red][item
											.priority],
									),
									onTap: () {
										return showRoundedModalBottomSheet(
											context: context, builder: (BuildContext context) {
											return new Center(
												child: Container(
													padding: EdgeInsets.all(16),

												child: Column(
													children: <Widget>[
														Text(item.title, textAlign: TextAlign.center,
															textScaleFactor: 2,
															style: TextStyle(fontWeight: FontWeight.normal),),
														Padding(padding: EdgeInsets.symmetric(
															vertical: 10, horizontal: 0),),
														Text(helper.dateFormatter.format(item.date),
															textAlign: TextAlign.center,),
														Padding(padding: EdgeInsets.symmetric(
															vertical: 10, horizontal: 0),),
														Row(mainAxisAlignment: MainAxisAlignment.center,
															children: [Text(item.category + " | "), Icon(
																Icons.adjust,
																color: [Colors.green, Colors.amber, Colors.red
																][item.priority],
															),
															]),
														Container(margin: EdgeInsets.all(10),
															child: Text(item.description,
																textAlign: item.description.length > 40
																	? TextAlign.left
																	: TextAlign.center),),
													],
												)
											));
											});
									})
							)
						);
					};
				})
			);
		}
		void _signOut() async {
			// sign out method, attached to button.
			try {
				await widget.auth.signOut();
				widget
					.onSignedOut(); // user will be signed out and redirected to login page.
			} catch (e) {
				print(e);
			}
		}

		@override
		Widget build(BuildContext context) {
			// build the UI of page.
			return Scaffold(
				appBar: new AppBar( // create top bar.
					elevation: 0.0,
					title: new Text("Todo", textAlign: TextAlign.left),
					actions: <Widget>[
						new RotatedBox(quarterTurns: 2,
							child: IconButton(
								icon: new Icon(Icons.exit_to_app), onPressed: () {
								showDialog(context: context,
									barrierDismissible: false,
									builder: (BuildContext context) {
										return new SimpleDialog(
											title: new Text('Log Out?'),
											children: <Widget>[
												SimpleDialogOption(
													child: new Text('Yes'),
													onPressed: () {
														Navigator.pop(context);
														_signOut();
													},
												),
												new SimpleDialogOption(
													child: new Text('No'),
													onPressed: () {
														Navigator.pop(context);
													},
												)
											],
										);
									});
							}))
					],
				),
				body: Container( // build body of page.
					child: getTasks() // get all tasks from server
				),

				floatingActionButton: FloatingActionButton( // create add task button.
					onPressed: () {
						Navigator.push(
							context,
							MaterialPageRoute(builder: (context) =>
								CreateTodoPage(auth: widget
									.auth,)), // on pressed, send user to create task page.
						);
					},
					tooltip: "Add Todo",
					child: Icon(Icons.add),
				),
				floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
			);
		}
	}
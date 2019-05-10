// this file includes 'helper' methods that speed up processes, in addition it holds methods that allow interactions with the server.
import "package:dio/dio.dart";
import "package:intl/intl.dart";
import 'dart:math';


Dio dio = new Dio();

DateFormat dateFormatter = new DateFormat("HH:mm MMM d, yyyy"); // create a date formatter, which will accept dates as strings and push out date types.

const String API_BASE = "https://todo.sammyhass.io/api"; // string constant which holds the route that the api should be requested to.

Future<String> newTodo(uid, title, desc, date, priority, category) async { // function to create a new task.

  String randomIdDec = Random().nextInt(1000000000).toRadixString(16); // generates random ID for the current task by creating a random hex number.

  await dio.post("$API_BASE/todo",data:{"uid": uid,"todoId": randomIdDec, "title": title, "desc": desc, "date": date, "category": category, "priority": priority}); // send a post request to the server to create the task.

  return randomIdDec; // return task id.
}

Future<Map> deleteTodo(uid, todoId, cat) async { // delete task function
  Response res;
  print("$uid $todoId $cat");
  res = await dio.delete("$API_BASE/todo?uid=$uid&todoId=$todoId&category=$cat"); // send delete request to the server a task
  return res.data;
}

Future<Null> editTodo(uid, todoId, title, description, date, priority) async { // edit task function
  Response res;
  res = await dio.put("$API_BASE/todo/", data: {"uid": uid, "todoId": todoId}); // send a put (edit) request to server to edit a task.
  // (Not yet active as edit task not yet implemented)

}


Future<Map> register(uid, first, last) async { // create register function which sends request to server, used after firebase responds
  Response res;
  res = await dio.post("$API_BASE/register",data:{"uid": uid, "first": first, "last": last}); // send post request with user's details to server.
  return res.data;
}

Future<Map> getUserInfo(uid) async { // get user info from server function
  Response res;
  res = await dio.get("$API_BASE/$uid/login"); // send get request to server to retrieve user details.
  return res.data;
}
// create todo class for storing general data
class Todo {
  String title;
  String description;
  String date;
  int priority;
  String id;
  String uid;
  String category;
  Todo(String uid, String title, String desc, String date, int priority, String category) { // initializer for todo class
    this.title = title;
    this.description = desc;
    this.date = date;
    this.priority = priority;
    this.uid = uid;
    this.category = category;
  }

  Future<Todo> pushToServer(Function after) { // method to push a task to the server.
    return newTodo(this.uid, this.title, this.description, this.date, this.priority, this.category).then((res) { // push task to the server.
      return after();
    });
  }
}

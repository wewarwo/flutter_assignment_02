import 'package:flutter/material.dart';
import 'package:flutter_assignment_02/DB.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => listScreen(),
        "/add": (context) => addNote(),
      },
    );
  }
}

class listScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return listScreenState();
  }
}

class listScreenState extends State<listScreen> {
  int _state = 0;
  static CRUD todo = CRUD();
  List<Todo> task = [];
  List<Todo> complete = [];
  @override
  Widget build(BuildContext context) {
    final List button = <Widget>[
      IconButton(
        icon: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "/add");
        },
      ),
      IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          for (var item in complete) {
            await todo.delete(item.id);
          }
          setState(() {
            complete = [];
          });
        },
      ),
    ];

    return DefaultTabController(
      length: 2,
      initialIndex: _state,
      child: Scaffold(
          appBar: AppBar(
            title: Text("Todo"),
            actions: <Widget>[_state == 0 ? button[0] : button[1]],
          ),
          bottomNavigationBar: BottomNavigationBar(
              currentIndex: _state,
              items: [
                BottomNavigationBarItem(
                  icon: new Icon(Icons.format_list_bulleted),
                  title: Text("Task"),
                ),
                BottomNavigationBarItem(
                  icon: new Icon(Icons.done_all),
                  title: Text("Complete"),
                ),
              ],
              onTap: (index) {
                setState(() {
                  _state = index;
                });
              }),
          body: _state == 0
              ? Container(
                  child: FutureBuilder<List<Todo>>(
                      future: todo.getAll(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Todo>> snapshot) {
                        task = [];

                        if (snapshot.hasData) {
                          for (var items in snapshot.data) {
                            if (items.done == false) {
                              task.add(items);
                            }
                          }

                          return task.length != 0
                              ? ListView.builder(
                                  itemCount: task.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Todo item = task[index];
                                    return ListTile(
                                      title: Text(item.title),
                                      trailing: Checkbox(
                                        onChanged: (bool value) async {
                                          setState(() {
                                            item.done = value;
                                          });
                                          todo.update(item);
                                        },
                                        value: item.done,
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Text("No data found.."),
                                );
                        } else {
                          return Center(
                            child: Text("No data found.."),
                          );
                        }
                      }),
                )
              : Container(
                  child: FutureBuilder<List<Todo>>(
                      future: todo.getAll(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Todo>> snapshot) {
                        complete = [];
                        if (snapshot.hasData) {
                          for (var items in snapshot.data) {
                            if (items.done == true) {
                              complete.add(items);
                            }
                          }

                          return complete.length != 0
                              ? ListView.builder(
                                  itemCount: complete.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Todo item = complete[index];
                                    return ListTile(
                                      title: Text(item.title),
                                      trailing: Checkbox(
                                        onChanged: (bool value) async {
                                          setState(() {
                                            item.done = value;
                                          });
                                          todo.update(item);
                                        },
                                        value: item.done,
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Text("No data found.."),
                                );
                        } else {
                          return Center(
                            child: Text("No data found.."),
                          );
                        }
                      }),
                )),
    );
  }
}

class addNote extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return addNoteState();
  }
}

class addNoteState extends State<addNote> {
  final _formkey = GlobalKey<FormState>();
  final myController = TextEditingController();
  CRUD todo = CRUD();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Subject"),
      ),
      body: Form(
        key: _formkey,
        child: ListView(
          children: <Widget>[
            TextFormField(
                decoration: InputDecoration(
                  labelText: "Subject",
                ),
                controller: myController,
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please fill subject";
                  }
                }),
            RaisedButton(
              child: Text("Save"),
              onPressed: () async {
                _formkey.currentState.validate();
                if (myController.text.length > 0) {
                  await todo.open("todo.db");
                  Todo data = Todo();
                  data.title = myController.text;
                  data.done = false;
                  await todo.insert(data);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

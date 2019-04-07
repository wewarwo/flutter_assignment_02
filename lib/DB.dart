import 'package:sqflite/sqflite.dart';

final String todoTable = "todo";
final String columnId = "id";
final String columnTitle = "title";
final String columnDone = "done";

class Todo {
  int id;
  String title;
  bool done;

  Todo();
  Todo.formMap(Map<String, dynamic> map) {
    this.id = map[columnId];
    this.title = map[columnTitle];
    this.done = map[columnDone] == 1;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      columnTitle: title,
      columnDone: done == true ? 1 : 0,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  @override
  String toString() {
    return '${this.id}, ${this.title}, ${this.done}';
  }
}

class CRUD {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
      create table $todoTable (
        $columnId integer primary key autoincrement,
        $columnTitle text not null,
        $columnDone integer not null
      )
      ''');
    });
  }

  Future<Todo> insert(Todo todo) async {
    todo.id = await db.insert(todoTable, todo.toMap());
    return todo;
  }

  Future<Todo> getTodo(int id) async {
    List<Map<String, dynamic>> maps = await db.query(todoTable,
        columns: [columnId, columnTitle, columnDone],
        where: '$columnId = ?',
        whereArgs: [id]);
    maps.length > 0 ? new Todo.formMap(maps.first) : null;
  }

  Future<int> delete(int id) async {
    return await db.delete(todoTable, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Todo todo) async {
    return db.update(todoTable, todo.toMap(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future<List<Todo>> getAll() async {
    await this.open("todo.db");
    var res =
        await db.query(todoTable, columns: [columnId, columnTitle, columnDone]);
    List<Todo> todoList =
        res.isNotEmpty ? res.map((c) => Todo.formMap(c)).toList() : [];
    return todoList;
  }

  Future close() async => db.close();
}

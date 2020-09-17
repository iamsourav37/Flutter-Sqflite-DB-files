import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'Todo.dart';
import 'dart:developer';

class DatabaseHelper {
  final String _dbName = "todo.db";
  final String _tableName = "my_todo";
  final int _dbVersion = 1;
  static DatabaseHelper _databaseHelper; // singleton
  static Database _database; // singleton

// column name
  String _colId = "id";
  String _colTitle = "title";
  String _colDescription = "description";
  String _colDate = "date";
  String _colPriority = "priority";

  DatabaseHelper._privateConstructor(); // private constructor

  factory DatabaseHelper() {
    // singleton default constructor
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._privateConstructor();
      log("1st log. DatabaseHelper constructor invoked, instance first time created : $_databaseHelper");
    }
    log("1st log. DatabaseHelper constructor invoked, instance returned : $_databaseHelper");

    return _databaseHelper;
  }

  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = await _createDatabase();
      log("2nd log. getDatabase method invoked, database instance first time created : $_database");
    }
    log("2nd log. getDatabase method invoked, database instance returned : $_database");

    return _database;
  }

  Future<Database> _createDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, this._dbName);
    return await openDatabase(path,
        version: this._dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    String sqlQuery = """
        CREATE TABLE $_tableName(
          $_colId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_colTitle TEXT NOT NULL,
          $_colDescription TEXT,
          $_colDate TEXT,
          $_colPriority INTEGER
        )
    
    """;
    await db.execute(sqlQuery);
  }

  // insert a row

  Future<int> insert(Todo todo) async {
    Database db = await this._getDatabase();
    var result = await db.insert(this._tableName, todo.toMap());
    log("On DB Helper insert method, result is $result");
    return result;
  }

// update a row
  Future<int> update(Todo todo) async {
    Database db = await this._getDatabase();
    var result = await db.update(this._tableName, todo.toMap(),
        where: "id = ?", whereArgs: [todo.id]);
    log("On DB Helper update method, result is $result");

    return result;
  }

// delete a row
  Future<int> delete(Todo todo) async {
    Database db = await this._getDatabase();
    var result =
        await db.delete(this._tableName, where: "id = ?", whereArgs: [todo.id]);
    log("On DB Helper delete method, result is $result");

    return result;
  }

  // get all rows as map
  Future<List<Map<String, dynamic>>> _getAllRowsAsMapList() async {
    Database db = await this._getDatabase();
    var result = await db.query(this._tableName, orderBy: '$_colPriority ASC');
    return result;
  }

// get all rows as Todo List to display in the UI
  Future<List<Todo>> getAllRowsAsTodoList() async {
    // List<Todo> todoList = List<Todo>(); // optional
    List<Todo> todoList = [];
    var todoMapList = await this._getAllRowsAsMapList();
    int count = todoMapList.length;

    for (int i = 0; i < count; i++) {
      todoList.add(Todo.fromMapObject(todoMapList[i]));
    }
    log("On DB Helper getAllRowsAsTodoList method, list is $todoList");
    return todoList;
  }
}

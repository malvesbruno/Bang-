import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('bangApp.db');
    return _db!;
  }

  static Future<Database> _initDB(String filePath) async {
    final path = join(await getDatabasesPath(), filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
   
await db.execute('''
  CREATE TABLE jogador (
    id TEXT PRIMARY KEY,              
  mute INTEGER NOT NULL DEFAULT 0,   
  qtVitoria INTEGER NOT NULL DEFAULT 0,
  qtDerrota INTEGER NOT NULL DEFAULT 0,
  qtEmpate INTEGER NOT NULL DEFAULT 0,
  qtGold INTEGER NOT NULL DEFAULT 0,
  amigos TEXT,                       
  avataresComprados TEXT,           
  revolveresComprados TEXT,
  gamertag TEXT,
  avatar TEXT
  )
''');

    // Crie outras tabelas aqui: atividades, stats, amigos etc.
  }

  static Future<void> insert(String table, Map<String, dynamic> data) async {
  final db = await database;
  await db.insert(
    table,
    data,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  static Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  static Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }
}

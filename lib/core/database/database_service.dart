import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'captus.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  static Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE,
        name TEXT,
        password TEXT,
        role TEXT,
        university TEXT,
        career TEXT,
        semester INTEGER,
        bio TEXT,
        avatarUrl TEXT
      )
    ''');

    // Courses table
    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        name TEXT,
        code TEXT,
        teacherId TEXT,
        teacherName TEXT,
        colorIndex INTEGER,
        progress REAL,
        pendingActivities INTEGER,
        studentCount INTEGER,
        description TEXT,
        schedule TEXT,
        userId TEXT
      )
    ''');

    // Tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        priority TEXT,
        status TEXT,
        dueDate TEXT,
        courseId TEXT,
        courseName TEXT,
        subjectName TEXT,
        groupId TEXT,
        createdAt TEXT,
        completed INTEGER,
        userId TEXT
      )
    ''');

    // Subtasks table
    await db.execute('''
      CREATE TABLE subtasks (
        id TEXT PRIMARY KEY,
        taskId TEXT,
        title TEXT,
        completed INTEGER,
        FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    // Events table (Calendar)
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        date TEXT,
        type TEXT,
        colorIndex INTEGER,
        courseId TEXT,
        userId TEXT
      )
    ''');

    // Groups table
    await db.execute('''
      CREATE TABLE groups (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        memberCount INTEGER,
        isJoined INTEGER,
        createdAt TEXT,
        userId TEXT
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT,
        icon TEXT,
        color TEXT,
        userId TEXT
      )
    ''');

    // Statistics table
    await db.execute('''
      CREATE TABLE statistics (
        userId TEXT PRIMARY KEY,
        totalTasksCompleted INTEGER,
        totalHoursStudied REAL,
        currentStreak INTEGER,
        bestStreak INTEGER,
        lastActiveDate TEXT
      )
    ''');

    // Assignments table (snake_case compatible with Supabase)
    await db.execute('''
      CREATE TABLE assignments (
        id TEXT PRIMARY KEY,
        course_id TEXT,
        teacher_id TEXT,
        title TEXT,
        description TEXT,
        start_date TEXT,
        due_date TEXT,
        created_at TEXT,
        type TEXT,
        max_grade REAL,
        requires_file INTEGER,
        FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    // Assignment Targets table (for assigning to specific groups/students)
    await db.execute('''
      CREATE TABLE assignment_targets (
        id TEXT PRIMARY KEY,
        assignment_id TEXT,
        target_type TEXT, -- 'group' or 'student'
        target_id TEXT,
        FOREIGN KEY (assignment_id) REFERENCES assignments (id) ON DELETE CASCADE
      )
    ''');

    // Submissions table (snake_case compatible with Supabase)
    await db.execute('''
      CREATE TABLE submissions (
        id TEXT PRIMARY KEY,
        assignment_id TEXT,
        student_id TEXT,
        file_url TEXT,
        content TEXT,
        submitted_at TEXT,
        status TEXT,
        grade REAL,
        feedback TEXT,
        FOREIGN KEY (assignment_id) REFERENCES assignments (id) ON DELETE CASCADE
      )
    ''');
  }

  // ── Generic CRUD helpers ──────────────────────────────────────────────────

  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> query(String table,
      {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    final db = await database;
    return await db.query(table,
        where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  static Future<int> update(String table, Map<String, dynamic> data,
      {required String where, required List<dynamic> whereArgs}) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  static Future<int> delete(String table,
      {required String where, required List<dynamic> whereArgs}) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
}

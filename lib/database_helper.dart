import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// database table and column names
const String databaseName = 'Word-Puzzle.db';
const String tableCategories = 'categories';
const String tableWords = 'words';

const String columnCategory = 'category';
const String columnTime = 'time';
const String columnWord = 'word';

// Data model class for categories
class ACategory {
  String category;
  String time;

  ACategory(this.category, {this.time = '00:00'});

  ACategory.fromMap(Map<dynamic, dynamic> map)
      : category = map[columnCategory],
        time = map[columnTime];

  Map<String, dynamic> toMap() {
    return {
      columnCategory: category,
      columnTime: time,
    };
  }

  ACategory.withTime(this.category, this.time) {
    this.category = category;
    this.time = time;
  }
}

// Data model class for words
class AWord {
  String category;
  String word;

  AWord(this.category, this.word);

  AWord.fromMap(Map<dynamic, dynamic> map)
      : category = map[columnCategory],
        word = map[columnWord];

  Map<String, dynamic> toMap() {
    return {
      columnCategory: category,
      columnWord: word,
    };
  }
}

// Singleton class to manage the database
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, databaseName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCategories (
        $columnCategory TEXT PRIMARY KEY,
        $columnTime TEXT DEFAULT '0.0s'
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableWords (
        $columnCategory TEXT NOT NULL,
        $columnWord TEXT NOT NULL
      )
    ''');
  }

  Future<bool> databaseExists(String path) =>
      databaseFactory.databaseExists(path);

  Future<int> initializeDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, databaseName);
    bool exists = await databaseExists(path);

    if (exists) return 0;

    print("Initializing database");
    Database db = await database;
    await db.rawDelete('DELETE FROM $tableCategories');
    await db.rawDelete('DELETE FROM $tableWords');

    List<String> categories = [
      'Face',
      'Fruits',
      'Vegetables',
      'Colors',
      'Occupations',
      'Musical Instruments',
      'Flowers',
      'Bar',
      'Bathroom',
      'House',
      'Makeup',
      'Family'
    ];

    List<List<String>> words = [
      [
        'hair',
        'skin',
        'eyebrow',
        'eyelash',
        'ear',
        'nose',
        'mole',
        'lip',
        'chin',
        'forehead',
        'temple',
        'eye',
        'cheek',
        'nostril',
        'mouth'
      ],
      [
        'orange',
        'lime',
        'lemon',
        'apricot',
        'watermelon',
        'grapes',
        'raspberry',
        'blackberry',
        'strawberry',
        'grapefruit',
        'peach',
        'plum',
        'mango',
        'banana',
        'papaya'
      ],
      [
        'corn',
        'green bean',
        'lettuce',
        'cucumber',
        'zucchini',
        'pumpkin',
        'pepper',
        'carrot',
        'asparagus',
        'potato',
        'onion',
        'artichoke',
        'radish',
        'broccoli',
        'celery'
      ],
      [
        'red',
        'blue',
        'green',
        'yellow',
        'orange',
        'purple',
        'teal',
        'pink',
        'gray',
        'white',
        'black',
        'brown'
      ],
      [
        'lawyer',
        'accountant',
        'scientist',
        'teacher',
        'pilot',
        'doctor',
        'actress',
        'dancer',
        'musician',
        'photographer',
        'painter',
        'librarian',
        'receptionist',
        'travel agent',
        'journalist'
      ],
      [
        'piano',
        'saxophone',
        'guitar',
        'violin',
        'viola',
        'harp',
        'cello',
        'french horn',
        'tuba',
        'drum',
        'trumpet',
        'keyboard',
        'mandolin',
        'bass',
        'flute'
      ],
      [
        'lily',
        'flowers',
        'carnation',
        'tulip',
        'orchid',
        'gladiolus',
        'daisy',
        'acacia',
        'chrysanthemum',
        'iris',
        'rose',
        'freesia',
        'gerbera'
      ],
      [
        'martini',
        'cocktail',
        'wine',
        'beer',
        'gin',
        'whiskey',
        'scotch',
        'rum'
      ],
      [
        'sink',
        'bathtub',
        'shower',
        'shower head',
        'toilet',
        'toilet brush',
        'drain',
        'sponge',
        'deodorant',
        'mouthwash',
        'toothpaste',
        'toothbrush',
        'aftershave',
        'soap',
        'bubble bath'
      ],
      [
        'window',
        'front door',
        'chimney',
        'roof',
        'sidewalk',
        'gutter',
        'dormer window',
        'shutter',
        'porch',
        'shingle',
        'balcony',
        'foyer',
        'doorbell',
        'handrail',
        'staircase'
      ],
      [
        'hair dye',
        'eyeshadow',
        'mascara',
        'eyeliner',
        'blusher',
        'foundation',
        'lipstick',
        'lip gloss',
        'face powder',
        'tweezers',
        'mirror',
        'concealer',
        'brush',
        'lip liner'
      ],
      [
        'grandmother',
        'grandfather',
        'mother',
        'father',
        'uncle',
        'aunt',
        'brother',
        'sister',
        'son',
        'daughter',
        'cousin',
        'grandson',
        'granddaughter',
        'niece',
        'nephew'
      ],
    ];

    for (String category in categories) {
      await db.insert(tableCategories, ACategory(category).toMap());
    }

    for (int i = 0; i < words.length; i++) {
      for (String word in words[i]) {
        await db.insert(
            tableWords,
            AWord(categories[i], word.toUpperCase().replaceAll(" ", ""))
                .toMap());
      }
    }
    return 1;
  }

  Future<void> dropTables() async {
    Database db = await database;
    await db.execute('DROP TABLE IF EXISTS $tableCategories');
    await db.execute('DROP TABLE IF EXISTS $tableWords');
  }

  Future<int> insertCategory(ACategory category) async {
    Database db = await database;
    return await db.insert(tableCategories, category.toMap());
  }

  Future<ACategory?> queryCategory(String category) async {
    Database db = await database;
    List<Map> maps = await db.query(
      tableCategories,
      columns: [columnCategory, columnTime],
      where: '$columnCategory = ?',
      whereArgs: [category],
    );
    if (maps.isNotEmpty) {
      return ACategory.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ACategory>> getAllCategories() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableCategories);
    return List.generate(maps.length, (i) {
      return ACategory.fromMap(maps[i]);
    });
  }

  Future<List<AWord>> getWords(String category) async {
    final Database db = await database;
    List<Map> maps = await db.query(
      tableWords,
      columns: [columnCategory, columnWord],
      where: '$columnCategory = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) {
      return AWord.fromMap(maps[i]);
    });
  }

  Future<int> getCategoryCount() async {
    Database db = await database;
    return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $tableCategories')) ??
        0;
  }

  Future<int> getAllWordsCount() async {
    Database db = await database;
    return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $tableWords')) ??
        0;
  }

  Future<int> deleteCategory(String category) async {
    final db = await database;
    return await db.delete(
      tableCategories,
      where: '$columnCategory = ?',
      whereArgs: [category],
    );
  }

  Future<int> updateBestTime(String category, int seconds) async {
    final db = await database;
    ACategory? previousCategory = await queryCategory(category);
    if (previousCategory != null) {
      int lastSeconds = int.parse(previousCategory.time.split(':')[1]) +
          int.parse(previousCategory.time.split(':')[0]) * 60;
      if (lastSeconds > seconds || lastSeconds == 0) {
        String mm = (seconds ~/ 60).toString().padLeft(2, '0');
        String ss = (seconds % 60).toString().padLeft(2, '0');
        return await db.update(
          tableCategories,
          ACategory.withTime(category, "$mm:$ss").toMap(),
          where: '$columnCategory = ?',
          whereArgs: [category],
        );
      }
    }
    return 0;
  }
}

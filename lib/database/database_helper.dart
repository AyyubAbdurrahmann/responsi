import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mahasiswa.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mahasiswa.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print('Database path: $path');
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mahasiswa (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nim TEXT NOT NULL UNIQUE,
        nama TEXT NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS mahasiswa');
      await _createDB(db, newVersion);
    }
  }

  Future<int> insertMahasiswa(Mahasiswa mahasiswa) async {
    final db = await database;
    print('Inserting mahasiswa: ${mahasiswa.nim}, ${mahasiswa.nama}');
    final result = await db.insert('mahasiswa', mahasiswa.toMap());
    print('Insert result: $result');
    return result;
  }

  Future<List<Mahasiswa>> getAllMahasiswa() async {
    final db = await database;
    final result = await db.query('mahasiswa', orderBy: 'nim ASC');
    return result.map((json) => Mahasiswa.fromMap(json)).toList();
  }

  Future<Mahasiswa?> getMahasiswaByNim(String nim) async {
    final db = await database;
    print('Querying mahasiswa by NIM: $nim');
    final result = await db.query(
      'mahasiswa',
      where: 'nim = ?',
      whereArgs: [nim],
    );
    print('Query result: $result');
    if (result.isNotEmpty) {
      return Mahasiswa.fromMap(result.first);
    }
    return null;
  }

  Future<int> deleteMahasiswa(int id) async {
    final db = await database;
    return await db.delete('mahasiswa', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}

import "package:sqflite/sqflite.dart";
import "package:path/path.dart";

final String contatoTable = "contatoTable";
final String idColumn = "idColumn";
final String nomeColumn = "nomeColumn";
final String emailColumn = "emailColumn";
final String telefoneColumn = "telefoneColumn";
final String imgColumn = "imgColumn";

class ContatoHelper {
  static final ContatoHelper _instance = ContatoHelper.internal();

  factory ContatoHelper() => _instance;

  ContatoHelper.internal();

  Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contatos.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $contatoTable($idColumn  INTEGER PRIMARY KEY, $nomeColumn TEXT,$emailColumn TEXT, $telefoneColumn TEXT, $imgColumn TEXT)",
      );
    });
  }

  Future<Contato> salvaContato(Contato contato) async {
    Database? dbContato = await db;
    contato.id = await dbContato?.insert(contatoTable, contato.toMap());
    return contato;
  }

  Future<Contato?> getContato(int id) async {
    Database? dbContato = await db;
    List<Map> maps = await dbContato!.query(contatoTable,
        columns: [idColumn, emailColumn, telefoneColumn, nomeColumn, imgColumn],
        where: "$idColumn=?",
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Contato.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deletaContato(int id) async {
    Database? dbContato = await db;
    return await dbContato!
        .delete(contatoTable, where: "$idColumn=?", whereArgs: [id]);
  }

  Future<int> updateContato(Contato contato) async {
    Database? dbContato = await db;
    return await dbContato!.update(contatoTable, contato.toMap(),
        where: "$idColumn=?", whereArgs: [contato.id]);
  }

  Future<List<Contato>> getAllContatos() async {
    Database? dbContato = await db;
    List listMap = await dbContato!.rawQuery('SELECT * FROM $contatoTable');
    List<Contato> listContato = [];
    for (Map m in listMap) {
      listContato.add(Contato.fromMap(m));
    }
    return listContato;
  }

  Future<int?> getNumber() async {
    Database? dbContato = await db;
    return Sqflite.firstIntValue(
        await dbContato!.rawQuery("SELECT COUNT (*) FROM $contatoTable"));
  }

  Future close() async {
    Database? dbContato = await db;
    dbContato!.close();
  }
}

class Contato {
  int? id;
  String? nome;
  String? email;
  String? telefone;
  String? img;
  Contato();

  Contato.fromMap(Map map) {
    id = map[idColumn];
    nome = map[nomeColumn];
    email = map[emailColumn];
    telefone = map[telefoneColumn];
    img = map[imgColumn];
  }
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nomeColumn: nome,
      emailColumn: email,
      telefoneColumn: telefone,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contato(id:$id, nome:$nome,telefone:$telefone,email:$email,img:$img)";
  }
}

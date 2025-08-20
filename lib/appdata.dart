import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';

class AppData {
  static const String jogadorIdKey = "jogador_unico_id";
  static String? _cachedId;

  static int mute = 0;
  static int qtVitoria = 0;
  static int qtDerrota = 0;
  static int qtEmpate = 0;
  static int qtGold = 0;
  static List<String> amigos = [];
  static List<String> avataresComprados = [];
  static List<String> revolveresComprados = [];
  static String gamertag = '';
  static String currentAvatar = '';

  static Future<String> getJogadorId() async {
    if (_cachedId != null) return _cachedId!;

    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(jogadorIdKey);

    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(jogadorIdKey, id);
    }

    _cachedId = id;
    return id;
  }

  static Future<void> initJogador() async {
    final id = await getJogadorId();
    final db = await DBHelper.database;
    final result = await db.query('jogador', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) {
      await db.insert('jogador', {
        'id': id,
        'mute': 0,
        'qtVitoria': 0,
        'qtDerrota': 0,
        'qtEmpate': 0,
        'qtGold': 0,
        'amigos': jsonEncode([]),
        'avataresComprados': jsonEncode([]),
        'revolveresComprados': jsonEncode([]),
        'gamertag': '',
        'currentAvatar': ''
      });
    }

    final data = await db.query('jogador', where: 'id = ?', whereArgs: [id]);

  if (data.isNotEmpty) {
    final jogador = data.first;
    mute = int.tryParse(jogador['mute']?.toString() ?? '0') ?? 0;
    qtVitoria = int.tryParse(jogador['qtVitoria']?.toString() ?? '0') ?? 0;
    qtDerrota = int.tryParse(jogador['qtDerrota']?.toString() ?? '0') ?? 0;
    qtEmpate = int.tryParse(jogador['qtEmpate']?.toString() ?? '0') ?? 0;
    qtGold = int.tryParse(jogador['qtGold']?.toString() ?? '0') ?? 0;
    amigos = List<String>.from(jsonDecode(jogador['amigos']?.toString() ?? '[]'));
    avataresComprados = List<String>.from(jsonDecode(jogador['avataresComprados']?.toString() ?? '[]'));
    revolveresComprados = List<String>.from(jsonDecode(jogador['revolveresComprados']?.toString() ?? '[]'));
    gamertag = jogador['gamertag']?.toString() ??'';
    currentAvatar = jogador['currentAvatar']?.toString() ?? '';
    
  }
  }

  static Future<void> salvartudo() async {
  final db = await DBHelper.database;
  await db.update(
    'jogador',
    {
      'qtVitoria': qtVitoria,
      'qtDerrota': qtDerrota,
      'qtEmpate': qtEmpate,
      'qtGold': qtGold,
      'amigos': jsonEncode(amigos),
      'avataresComprados': jsonEncode(avataresComprados),
      'revolveresComprados': jsonEncode(revolveresComprados),
      'gamertag': gamertag,
      'currentAvatar': currentAvatar


    },
    where: 'id = ?',
    whereArgs: [await getJogadorId()],
  );
}

  static Future<void> salvarEstatisticas() async {
  final db = await DBHelper.database;
  await db.update(
    'jogador',
    {
      'qtVitoria': qtVitoria,
      'qtDerrota': qtDerrota,
      'qtEmpate': qtEmpate,
    },
    where: 'id = ?',
    whereArgs: [await getJogadorId()],
  );
}

static Future<void> salvarGamertag() async {
  final db = await DBHelper.database;
  await db.update(
    'jogador',
    {
      'gamertag': gamertag,
    },
    where: 'id = ?',
    whereArgs: [await getJogadorId()],
  );
}



  static Future<Map<String, dynamic>?> getJogadorData() async {
    final id = await getJogadorId();
    final db = await DBHelper.database;
    final result = await db.query('jogador', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> toggleMute() async {
    final data = await getJogadorData();
    if (data != null) {
      final novoMute = data['mute'] == 1 ? 0 : 1;
      await DBHelper.insert('jogador', {
        ...data,
        'mute': novoMute,
      });
    }
  }

  static Future<void> adicionarVitoria() async {
    final data = await getJogadorData();
    if (data != null) {
      int vitorias = data['qtVitoria'] ?? 0;
      await DBHelper.insert('jogador', {
        ...data,
        'qtVitoria': vitorias + 1,
      });
    }
  }

  // Outras funções semelhantes para derrota, empate, gold etc.
}

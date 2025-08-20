import 'package:bang/appdata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;

Future<Map<String, dynamic>?> pegarDadosJogador(String uid) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      // Retorna só os campos que precisamos
      return {
        'gamertag': doc['gamertag'],
        'currentAvatar': doc['currentAvatar'],
      };
    }
  } catch (e) {
    print("Erro ao pegar dados do jogador $uid: $e");
  }
  return null;
}

Future<void> pegarTodosDadosJogador(String uid) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      AppData.qtDerrota = doc['qtDerrota'] ?? 0;
      AppData.qtEmpate = doc['qtEmpate'] ?? 0;
      AppData.qtVitoria = doc['qtVitoria'] ?? 0;
      AppData.qtGold = doc['qtGold'] ?? 0;
      AppData.amigos = List<String>.from(doc['amigos'] ?? []);
      AppData.avataresComprados = List<String>.from(doc['avataresComprados'] ?? []);
      AppData.currentAvatar = doc['currentAvatar'] ??'';
      AppData.gamertag = doc['gamertag'] ?? '';
      AppData.revolveresComprados = List<String>.from(doc['revolveresComprados'] ?? []);
    }
  } catch (e) {
    print("Erro ao pegar dados do jogador $uid: $e");
  }
}

Future<void> atualizarDadosJogador(String uid, Map<String, dynamic> novosDados) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(novosDados);
  } catch (e) {
    print("Erro ao atualizar dados do jogador $uid: $e");
  }
}
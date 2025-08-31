import 'package:bang/appdata.dart';
import 'package:bang/services/getUserInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';


// nesse arquivo temos funções que enviam convites e do duelo

final db = FirebaseDatabase.instance.ref(); // cria variável da database



// enviar convite para duelo para amigo
Future<String> enviarConvite(String destinatarioId,) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final conviteRef = db.child('convites').child(destinatarioId).push();
  final conviteId = conviteRef.key!;

  await conviteRef.set({
    'remetenteId': userId,
    'remetenteName': AppData.gamertag,
    'status': 'pendente',
    'criadoEm': ServerValue.timestamp,
  });

  return conviteId;
}

// envia convite de amizade
Future<String> enviarConviteAmizade(String destinatarioId,) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final conviteRef = db.child('convitesAmizade').child(destinatarioId).push();
  final conviteId = conviteRef.key!;

  await conviteRef.set({
    'remetenteId': userId,
    'remetenteName': AppData.gamertag,
    'status': 'pendente',
    'criadoEm': ServerValue.timestamp,
  });

  return conviteId;
}
 
//ouve convite de duelo de amigos
void ouvirConvites(String meuId, Function(String conviteID ,Map<String, dynamic> convite)? onConviteRecebido) {
   final convitesRef = db.child('convites').child(meuId);
  convitesRef.onChildAdded.listen((event) {
    if (event.snapshot.value != null) {
      final convite = Map<String, dynamic>.from(event.snapshot.value as Map);
      final conviteId = event.snapshot.key;
      onConviteRecebido!(conviteId! ,convite);
    }
  });
}

//ouve convite de amizade de user
void ouvirConvitesAmizade(String meuId, Function(String conviteID ,Map<String, dynamic> convite)? onConviteRecebido) {
   final convitesRef = db.child('convitesAmizade').child(meuId);
  convitesRef.onChildAdded.listen((event) {
    if (event.snapshot.value != null) {
      final convite = Map<String, dynamic>.from(event.snapshot.value as Map);
      final conviteId = event.snapshot.key;
      onConviteRecebido!(conviteId! ,convite);
    }
  });
}


// recebe todos os convites de amizade
Future<List<Map<String, dynamic>>> getAllConvitesAmizade(String meuId) async {
  try {
    final convitesRef = await db.child('convitesAmizade').child(meuId).get();

    if (!convitesRef.exists) {
      return []; // nenhum convite
    }

    final Map<dynamic, dynamic> convitesMap = convitesRef.value as Map<dynamic, dynamic>;

    // transformar em lista de mapas
    final convites = convitesMap.entries.map((entry) {
      return {
        "id": entry.key,
        ...Map<String, dynamic>.from(entry.value),
      };
    }).toList();

    return convites;
  } catch (e) {
    print("Erro ao buscar convites de amizade: $e");
    return [];
  }
}


// aceita convite de duelo
Future<void> aceitarConvite(String meuId, String conviteId, Map convite, String remetenteId) async {
  final conviteRef = db.child('convites').child(meuId).child(conviteId);
  final dueloRef = db.child('duelos').push();
  await dueloRef.set({
    'jogador1': remetenteId,
    'jogador2': meuId,
    'status': 'em_andamento',
    'inicio': DateTime.now().toIso8601String(),
    'jogador1SacouBT': 0,
    'jogador2SacouBT': 0,
    'jogador1Time': 0,
    'jogador2Time': 0,
  });
  await conviteRef.update({'status': 'aceito'});

  // Aqui você pode fazer a lógica após aceitar, tipo iniciar jogo, notificar remetente, etc
}

// aceita convite de amizade
Future<void> aceitarConviteAmizade(
  String meuId,
  String conviteId,
  String remetenteId,
) async {
  try {
    final meuRef = firestore.collection('users').doc(meuId);
    final remetenteRef = firestore.collection('users').doc(remetenteId);

    // Pegar amigos atuais do destinatário
    final meuSnapshot = await meuRef.get();
    List<dynamic> meusAmigos = [];
    if (meuSnapshot.exists) {
      final data = meuSnapshot.data() as Map<String, dynamic>;
      meusAmigos = List<dynamic>.from(data['amigos'] ?? []);
    }

    // Pegar amigos atuais do remetente
    final remetenteSnapshot = await remetenteRef.get();
    List<dynamic> amigosRemetente = [];
    if (remetenteSnapshot.exists) {
      final data = remetenteSnapshot.data() as Map<String, dynamic>;
      amigosRemetente = List<dynamic>.from(data['amigos'] ?? []);
    }

    // Adicionar IDs (se não existir ainda)
    if (!meusAmigos.contains(remetenteId)) {
      meusAmigos.add(remetenteId);
    }
    if (!amigosRemetente.contains(meuId)) {
      amigosRemetente.add(meuId);
    }

    // Salvar de volta no Firestore
    await meuRef.update({'amigos': meusAmigos});
    await remetenteRef.update({'amigos': amigosRemetente});

    // Remover o convite aceito
    await db.child("convitesAmizade/$meuId/$conviteId").remove();

    print("✅ Amizade entre $meuId e $remetenteId criada com sucesso");
  } catch (e) {
    print("❌ Erro ao aceitar convite de amizade: $e");
  }
}


// rejeitar convite de amizade
Future<void> rejeitarConviteAmizade(String meuId, String conviteId)async{
  await db.child("convitesAmizade/$meuId/$conviteId").remove();
}


// aguardas resposta de convite de duelo
void aguardarResposta(String amigoId, String conviteId, Function(String status, String id, String conviteId) onMudouStatus) {
  final conviteRef = db.child('convites').child(amigoId).child(conviteId);
  
  conviteRef.onValue.listen((event) {
    if (event.snapshot.value != null) {
      final dados = Map<String, dynamic>.from(event.snapshot.value as Map);
      final status = dados['status'] ?? 'pendente';
      onMudouStatus(status, amigoId, conviteId);
    }
  });
}

// ouvir campo inimigo
void ouvirCampoInimigo({
  required bool jogador1,
  required String duelId,
  required String campoBase,
  required Function(int valor) onMudouStatus,
}) {
  final campoInimigo = jogador1
      ? "jogador2$campoBase"
      : "jogador1$campoBase";

  db.child('duelos').child(duelId).child(campoInimigo).onValue.listen((event) {
    if (event.snapshot.value != null) {
      onMudouStatus(event.snapshot.value as int);
    }
  });
}

// escuta o fim do Duelo
void EscutarFimDuelo({
  required bool jogador1,
  required String duelId,
}) {
  bool p1Finalizou = false;
  bool p2Finalizou = false;

  void verificarFinalizacao() {
    if (p1Finalizou && p2Finalizou) {
      try{
      db.child('duelos').child(duelId).remove();
      } catch(e){
        (){};
      }
    }
  }

  db.child('duelos').child(duelId).child('finalizouP1').onValue.listen((event) {
    if (event.snapshot.value != null) {
      p1Finalizou = true;
      verificarFinalizacao();
    }
  });

  db.child('duelos').child(duelId).child('finalizouP2').onValue.listen((event) {
    if (event.snapshot.value != null) {
      p2Finalizou = true;
      verificarFinalizacao();
    }
  });
}

// adicionar meu tempo no duelo
Future<void> adicionarMeuTempo(bool jogador1, String duelId, int tempo) async{
  final conviteRef = db.child('duelos').child(duelId);
  if (jogador1){
   await conviteRef.update({'jogador1Time': tempo});
} else{
  await conviteRef.update({'jogador2Time': tempo});
}
}

// adiciona saquei antes da hora no duelo
Future<void> saqueiBT(bool jogador1, String duelId) async{
  final conviteRef = db.child('duelos').child(duelId);
  if (jogador1){
   await conviteRef.update({'jogador1SacouBT': 1});
} else{
  await conviteRef.update({'jogador2SacouBT': 1});
}
}



// rejeitar convite duelo
Future<void> rejeitarConvite(String meuId, String conviteId) async {
  final conviteRef = db.child('convites').child(meuId).child(conviteId);
  await conviteRef.update({'status': 'recusado'});
}

// finaliza duelo
Future<void> finalizarDuelo(jogador1, duelId) async{
  final conviteRef = db.child('duelos').child(duelId);
  if (jogador1){
   await conviteRef.update({'finalizouP1': true});
} else{
  await conviteRef.update({'finalizouP2': true});
}
}

// busca duelo
Future<Map<String, dynamic>?> pegarDuelo(String player1Id, String player2Id) async {
  final duelosRef = db.child('duelos');

  // Primeiro, pegamos todos os duelos em que jogador1 é player1Id
  final snapshot = await duelosRef.orderByChild('jogador1').equalTo(player1Id).get();

  if (snapshot.exists) {
    final duelos = Map<String, dynamic>.from(snapshot.value as Map);

    // Procurar algum duelo onde jogador2 seja player2Id
    for (var entry in duelos.entries) {
      final duelo = Map<String, dynamic>.from(entry.value);
      print('Duelo:' '$duelo');
      if (duelo['jogador2'] == player2Id) {
        return {'id': entry.key, 'duelo': duelo};
      }
    }
  }

  // Caso não encontre, pode tentar o inverso: player1 = player2Id e player2 = player1Id
  final snapshotInverso = await duelosRef.orderByChild('jogador1').equalTo(player2Id).get();
  if (snapshotInverso.exists) {
    final duelos = Map<String, dynamic>.from(snapshotInverso.value as Map);

    for (var entry in duelos.entries) {
      final duelo = Map<String, dynamic>.from(entry.value);
      print('Duelo:' '$duelo');
      if (duelo['jogador2'] == player1Id) {
        return {'id': entry.key, 'duelo': duelo};
      }
    }
  }

  // Não encontrou nenhum duelo
  return null;
}

//entra na fila aleatória para achar duelo online
Future<void> entrarFilaAleatoria(String uid, String gamertag) async {
  final filaRef = db.child('filaDuelos').child(uid);
  await filaRef.set({
    'gamertag': gamertag,
    'timestamp': ServerValue.timestamp,
  });
}

// tentar combinar duelista 
Future<Map<String, String?>> tentarCombinarDuelista(String meuUid) async {
  final filaRef = db.child('filaDuelos');
  final snapshot = await filaRef.get();

  if (!snapshot.exists) return {'dueloId': null, 'oponente': null};

  final fila = Map<String, dynamic>.from(snapshot.value as Map);

  // Remove meu próprio UID da lista de candidatos
  fila.remove(meuUid);

  if (fila.isEmpty) return {'dueloId': null, 'oponente': null};

  // Escolher aleatoriamente um oponente
  final oponentUid = fila.keys.toList()..shuffle();
  final escolhido = oponentUid.first;

  // Criar duelo
  final dueloRef = db.child('duelos').push();
  await dueloRef.set({
    'jogador1': meuUid,
    'jogador2': escolhido,
    'status': 'em_andamento',
    'inicio': DateTime.now().toIso8601String(),
    'jogador1SacouBT': 0,
    'jogador2SacouBT': 0,
    'jogador1Time': 0,
    'jogador2Time': 0,
  });

  // Remover ambos da fila
  await filaRef.child(meuUid).remove();
  await filaRef.child(escolhido).remove();

  return {'dueloId': dueloRef.key, 'oponente': escolhido};
}

// sair da lista
Future<void> sairDaLista(String uid) async {
  final filaRef = db.child('filaDuelos').child(uid);
  filaRef.remove();
}


//deletar o convite de duelo
Future<void> deletarConvite(String oponenteId, String conviteId) async {
  final conviteRef = db.child('convites').child(oponenteId).child(conviteId);
  conviteRef.remove();
}




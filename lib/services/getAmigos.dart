import 'package:cloud_firestore/cloud_firestore.dart';


// Pega os dados dos amigos do user
Future<List<Map<String, dynamic>>> getAmigosData(List<String> amigosIds) async {
  final firestore = FirebaseFirestore.instance; // cria a variável da database
  List<Map<String, dynamic>> amigosData = []; // cria uma lista para popular com amigos depois

  // Quebra em blocos de até 10
  for (var i = 0; i < amigosIds.length; i += 10) {
    final chunk = amigosIds.sublist(
      i,
      i + 10 > amigosIds.length ? amigosIds.length : i + 10,
    );

    final querySnapshot = await firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: chunk)
        .get();

    amigosData.addAll(
      querySnapshot.docs.map((doc) {
        return {
          "id": doc.id, // Aqui pegamos o UUID
          ...doc.data(), // E aqui os dados
        };
      }).toList(),
    );
  }

  return amigosData;
}

// pega o dados de todos os users
Future<List<Map<String, dynamic>>> getTodosData() async {
  try {
    final firestore = FirebaseFirestore.instance; // cria a variável da database
    final querySnapshot = await firestore.collection('users').get();

    return querySnapshot.docs.map((doc) {
      return {
        "id": doc.id,
        ...doc.data(),
      };
    }).toList();
  } catch (e, st) {
    print('⚠️ Erro ao pegar todos os usuários: $e\n$st');
    return []; // retorna lista vazia em caso de erro
  }
}


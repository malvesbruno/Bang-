import 'dart:math';

class Duelo {
  String jogador1;
  String? jogador2; // pode ser null se for bye

  Duelo({required this.jogador1, this.jogador2});
}

List<Duelo> gerarPartidasCampeonato(List<String> jogadores) {
  if (jogadores.length < 3 || jogadores.length > 8) {
    throw Exception('Número de jogadores inválido. Deve ser entre 3 e 8.');
  }

  // Embaralhar a lista para sorteio aleatório
  jogadores.shuffle(Random());

  List<Duelo> duelos = [];
  int i = 0;

  while (i < jogadores.length) {
    String jogador1 = jogadores[i];
    String? jogador2;

    // Se restarem 3 jogadores, cria um duelo e deixa o último com bye
    if (i + 1 == jogadores.length - 1) {
      jogador2 = jogadores[i + 1];
      duelos.add(Duelo(jogador1: jogador1, jogador2: jogador2));
      duelos.add(Duelo(jogador1: jogadores[i + 2], jogador2: null)); // bye
      break;
    } else if (i + 1 < jogadores.length) {
      jogador2 = jogadores[i + 1];
      duelos.add(Duelo(jogador1: jogador1, jogador2: jogador2));
      i += 2;
    } else {
      // Se número ímpar, último jogador recebe bye
      duelos.add(Duelo(jogador1: jogador1, jogador2: null));
      i++;
    }
  }

  return duelos;
}
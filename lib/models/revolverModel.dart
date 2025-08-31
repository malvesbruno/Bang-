// Essa classe é usada para facilitar a lidar com revolvers comprados, não comprados ou que ainda podem ser comprados
class Revolver {
  final String name; // nome do revolver
  final String avatarPath; // path da imagem do revolver
  bool owned; // revolver já comprado
  final double price; // preço do revolver
  final String lore; // história do revolver

  Revolver({
    required this.name,
    required this.avatarPath,
    required this.owned,
    required this.price,
    required this.lore,
  });

  // essa função transforma um map no modelo do Revolver
  factory Revolver.fromMap(Map<dynamic, dynamic> data) {
    return Revolver(
      name: data['name'] ?? 'Sem nome',
      avatarPath: data['avatarPath'] ?? 'assets/imgs/default_avatar.png',
      owned: data['owned'] ?? false,
      price: data['price'] ?? 100,
      lore: data['lore'] ?? ''
    );
  }
   // essa função transforma o modelo de Revolver em um Map
   Map<String, dynamic> toMap(){
    return {
      'name': name,
      'avatarPath': avatarPath,
      'owned': owned,
      'price': price,
      'lore' : lore,
    };
  }
}
//Essa é usada para facilitar a lidar com avatares comprados, não comprados ou que ainda podem ser comprados
class Avatar {
  final String name; //nome do avatar
  final String avatarPath; //path para a imagem
  bool owned; // já foi comprado
  final double price; // preço do avatar
  final String lore; // história do avatar

  Avatar({
    required this.name,
    required this.avatarPath,
    required this.owned,
    required this.price,
    required this.lore,
  });

  
  // essa função transforma um map no modelo do avatar
  factory Avatar.fromMap(Map<dynamic, dynamic> data) {
    return Avatar(
      name: data['name'] ?? 'Sem nome',
      avatarPath: data['avatarPath'] ?? 'assets/imgs/default_avatar.png',
      owned: data['owned'] ?? false,
      price: data['price'] ?? 100,
      lore: data['lore'] ?? ''
    );
  }

    // essa função transforma o modelo de avatar em um Map
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
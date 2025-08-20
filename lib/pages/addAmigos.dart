import 'package:bang/main.dart';
import 'package:bang/services/enviarConvites.dart';
import 'package:flutter/material.dart';
import '../pages/playingPage.dart';
import 'package:flutter/services.dart';
import 'package:bang/pages/onlineMenu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../appdata.dart';
import '../pages/bluetoothHostPage.dart';
import '../pages/bluetoothClientPage.dart';
import '../pages/rankingPage.dart';
import '../pages/signUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAmigosPage extends StatefulWidget {
  const AddAmigosPage({super.key});

  @override
  State<AddAmigosPage> createState() => _AddAmigosPageState();
}

class _AddAmigosPageState extends State<AddAmigosPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool playin = AppData.mute == 0;
  final TextEditingController emailController = TextEditingController();
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> resultados = [];



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    playin = AppData.mute == 0;
  }

  Future<void> buscarAmigo(String termo) async {
  if (termo.isEmpty) return;

  List<Map<String, dynamic>> resultadosTemp = [];

  try {
    // busca pelo gamertag
    final querySnapshot = await firestore
        .collection('users')
        .where('gamertag', isEqualTo: termo)
        .get();

    resultadosTemp.addAll(querySnapshot.docs.map((doc) => {
      "id": doc.id,
      "name": doc['gamertag'] ?? "Sem nome",
      "avatar": doc['currentAvatar'] ?? 'assets/imgs/avatares/avatar1_pose1.png',
    }));

    // busca pelo ID do documento
    final docSnap = await firestore.collection('users').doc(termo).get();
    if (docSnap.exists) {
      final data = {
        "id": docSnap.id,
        "name": docSnap['gamertag'] ?? "Sem nome",
        "avatar": docSnap['currentAvatar'] ?? 'assets/imgs/avatares/avatar1_pose1.png',
      };
      // evita duplicata
      if (!resultadosTemp.any((e) => e['id'] == docSnap.id)) {
        resultadosTemp.add(data);
      }
    }

    setState(() {
      resultados = resultadosTemp;
    });

  } catch (e) {
    print("Erro ao buscar amigo: $e");
    setState(() {
      resultados = [];
    });
  }
}

 @override
  Widget build(BuildContext context) {
    final backgroundColor = Color(0xFF6B4C3B); // marrom terra
    final boxColor = Color(0xFFC19A6B); // bege amarelado
    final buttonColor = Color(0xFF4B3B2A); // marrom escuro

    return Scaffold(
      backgroundColor: backgroundColor,
      body: 
      Stack(children: [
        Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: 
          AssetImage('assets/imgs/loginBG.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 80,),
                 Stack(
                  children: [
                    // Texto com contorno (usando Paint)
                    Text(
                      'Adicionar Amigo',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vt323(
                        fontSize: 50,
                        height: 0.8,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 8
                          ..color = Color(0xFF4A251D),
                      ),
                    ),
                    // Texto preenchido
                    Text(
                      'Adicionar Amigo',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vt323(
                        fontSize: 50,
                        height: 0.8,
                        color: Color(0xFFE33117),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 45,),
                _buildTextField('Digite o ID ou o nome', emailController, boxColor),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: EdgeInsets.symmetric(horizontal: 64, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                  onPressed: () async{
                    print('DEBUG ${emailController.text}');
                    await buscarAmigo(emailController.text);
                  },
                  child: Text(
                    'Buscar',
                    style: TextStyle(
                      fontFamily: 'PirataOne',
                      fontSize: 20,
                      color: boxColor.withOpacity(0.9),
                    ),
                  ),
                ),
                SizedBox(height: 20),  
Container(
  height: 150, // altura fixa para o scroll de resultados
  child: resultados.isEmpty
      ? Center(child: Text("Nenhum usuário encontrado", style: TextStyle(color: Colors.white)))
      : ListView.builder(
          itemCount: resultados.length,
          itemBuilder: (context, index) {
            final player = resultados[index];
            return customListTile(avatarPath: player['avatar'], name: player['name'], onTap: (){
              enviarConviteAmizade(player['id']);
              resultados = [];
              emailController.text = '';
            });
          },
        ),
),            ],
            ),
          ),
        ),
      ),
      ),
      Positioned(
        left: 20,
        top: 20,
        child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF544528),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Icon(Icons.arrow_back),
                  ),
                )
      ],)
      

      
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, Color bgColor, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        filled: true,
        fillColor: bgColor,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.brown[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.brown.shade700, width: 2),
        ),
      ),
    );
  }
}



Widget customListTile({
  required String avatarPath,
  required String name,
  VoidCallback? onTap,
}) {
  return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFF544528),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Color.fromARGB(255, 251, 230, 218),
              backgroundImage: AssetImage(avatarPath),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child:Text(
                  name,
                  style: GoogleFonts.vt323(
                    fontSize: 30,
                    color: Color(0xFFC19A6B),
                    height: 0.8,
                  ),
                ),
                ),
                
                SizedBox(height: 8,),
                Center(
                  child:ElevatedButton(onPressed: onTap, 
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4B3B2A),
                    padding: EdgeInsets.symmetric(horizontal: 64, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                child: Text(
            'adicionar',
            style: TextStyle(
                      fontFamily: 'PirataOne',
                      fontSize: 18,
                      color: Color(0xFFC19A6B).withOpacity(0.9),
                    ),
          )) ,
                )
                
              ],
            ),
          ),
        ],
      ),
    );
}
import 'package:bang/main.dart';
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

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool playin = AppData.mute == 0;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'Preencha todos os campos.';
      });
      return;
    }

    try {
      // 1. Faz login no Firebase
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // 2. Busca dados no Firestore
        final doc = await firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          print('documento existe');

          // 3. Atualiza AppData com os dados do Firestore
          AppData.qtVitoria = data['qtVitoria'] ?? 0;
          AppData.qtDerrota = data['qtDerrota'] ?? 0;
          AppData.qtEmpate = data['qtEmpate'] ?? 0;
          AppData.qtGold = data['qtGold'] ?? 0;
          AppData.gamertag = data['gamertag'] ?? '';

          // Campos que são listas em JSON
          AppData.amigos = List<String>.from(
            (data['amigos'] != null)
                ? List<String>.from(data['amigos'])
                : [],
          );
          AppData.avataresComprados = List<String>.from(
            (data['avataresComprados'] != null)
                ? List<String>.from(data['avataresComprados'])
                : [],
          );
          AppData.revolveresComprados = List<String>.from(
            (data['revolveresComprados'] != null)
                ? List<String>.from(data['revolveresComprados'])
                : [],
          );

          AppData.salvartudo();

          // 4. Vai pra tela principal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => onlineMenuPage()),
          );
        } else {
          setState(() {
            errorMessage = 'Usuário não encontrado no banco.';
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro inesperado: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isLoading = false;
  String? errorMessage;

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

 @override
  Widget build(BuildContext context) {
    final backgroundColor = Color(0xFF6B4C3B); // marrom terra
    final boxColor = Color(0xFFC19A6B); // bege amarelado
    final buttonColor = Color(0xFF4B3B2A); // marrom escuro

    return Scaffold(
      backgroundColor: backgroundColor,
      body: 
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
                Image.asset("assets/imgs/logo.png", height:200,),
                _buildTextField('E-mail', emailController, boxColor),
                SizedBox(height: 24),
                _buildTextField('Senha', passwordController, boxColor, obscureText: true),
                SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                  onPressed: () {
                    login();
                  },
                  child: Text(
                    'Entrar',
                    style: TextStyle(
                      fontFamily: 'PirataOne',
                      fontSize: 24,
                      color: boxColor.withOpacity(0.9),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text(
                  'Não tem uma conta?',
                  style: TextStyle(
                    color: boxColor.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(0, 255, 255, 255),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()));
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: 'PirataOne',
                      fontSize: 12,
                      color: boxColor.withOpacity(0.9),
                    ),
                  ),
                ),
                ],)
                
              ],
            ),
          ),
        ),
      ),
      )

      
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
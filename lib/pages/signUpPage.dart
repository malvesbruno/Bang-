import 'package:bang/pages/logInPage.dart';
import 'package:bang/pages/onlineMenu.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../appdata.dart';
import 'dart:convert';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final gamertagController = TextEditingController();

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;

  Future<bool> isGamertagTaken(String gamertag) async {
    final query = await firestore
        .collection('users')
        .where('gamertag', isEqualTo: gamertag.toLowerCase())
        .get();

    return query.docs.isNotEmpty;
  }

  Future<void> signup() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final gamertag = gamertagController.text.trim().toLowerCase();

    if (email.isEmpty || password.isEmpty || gamertag.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'Preencha todos os campos.';
      });
      return;
    }

    // Verifica se gamertag está em uso
    if (await isGamertagTaken(gamertag)) {
      setState(() {
        isLoading = false;
        errorMessage = 'Gamertag já está em uso, escolha outra.';
      });
      return;
    }

    try {
      // Cria usuário no Firebase Auth
      final userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final user = auth.currentUser;
  if (user != null) {
    // Pega dados iniciais do AppData (você pode adaptar)
    final docData = {
      'email': email,
      'gamertag': gamertag,
      'qtVitoria': AppData.qtVitoria,
      'qtDerrota': AppData.qtDerrota,
      'qtEmpate': AppData.qtEmpate,
      'qtGold': AppData.qtGold,
      'amigos': AppData.amigos,
      'avataresComprados': AppData.avataresComprados,
      'revolveresComprados': AppData.revolveresComprados,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await firestore.collection('users').doc(user.uid).set(docData);
    AppData.gamertag = gamertag;
    AppData.salvartudo();
    print('Documento criado no Firestore para usuário: ${user.uid}');
        // Signup e gravação OK, pode redirecionar para home ou login
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
                SizedBox(height: 24),
                _buildTextField('Gamertag', gamertagController, boxColor),
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
                  onPressed: () async{
                    await signup();
                    if (errorMessage == null) {
    Navigator.push(context, MaterialPageRoute(builder: (builder) => onlineMenuPage()));
  } else {
    showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Erro'),
    content: Text(errorMessage ?? 'Erro desconhecido'),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('OK'),
      ),
    ],
  ),
);
  }
                  },
                  child: Text(
                    'Cadastrar',
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
                  'Já tem uma conta?',
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LogInPage()));
                  },
                  child: Text(
                    'LogIn',
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
      ),)
      
      
    );
  }
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

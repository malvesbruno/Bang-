import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/offlinePage.dart';
import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

// tela com um pequeno timer para que os users se preparem para o duelo
class BluetoothPreparePage extends StatefulWidget {
  final QualifiedCharacteristic writeChar;

  const BluetoothPreparePage({super.key, required this.writeChar});

  @override
  State<BluetoothPreparePage> createState() => _BluetoothPreparePageState();
}

class _BluetoothPreparePageState extends State<BluetoothPreparePage> {
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  //Cria um contador de um segundo para sincronizar os users
  void startCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown == 0) {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OfflineDuelPage(writeChar: widget.writeChar,)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          _countdown > 0 ? 'Prepare-se...\n$_countdown' : 'Vai!',
          textAlign: TextAlign.center,
          style: GoogleFonts.vt323(
            fontSize: 60,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

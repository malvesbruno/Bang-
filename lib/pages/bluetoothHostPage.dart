import 'package:bang/pages/offlinePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../pages/playingPage.dart';
import 'package:app_settings/app_settings.dart';
import '../pages/bluetoothLobbyPage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/bluetoothPreparePage.dart';

class BluetoothHostPage extends StatefulWidget {
  const BluetoothHostPage({super.key});

  @override
  State<BluetoothHostPage> createState() => _BluetoothHostPageState();
}

class _BluetoothHostPageState extends State<BluetoothHostPage> {
  final _ble = FlutterReactiveBle();
  late DiscoveredDevice _connectedDevice;
  late QualifiedCharacteristic _writeChar;

  final Uuid serviceUuid = Uuid.parse("12345678-1234-5678-1234-56789abcdef0");
  final Uuid charUuid = Uuid.parse("abcdef01-1234-5678-1234-56789abcdef0");

  bool _isAdvertising = false;
  bool _deviceConnected = false;
  bool _modoTeste = true;

  Stream<DiscoveredDevice>? _advertisingStream;

  bool _dialogShown = false;

@override
void initState() {
  super.initState();

  // Escuta continuamente o status do Bluetooth
  _ble.statusStream.listen((status) {
    print("Status do Bluetooth: $status");

    if (status == BleStatus.ready) {
      if (!_deviceConnected && !_isAdvertising) {
        startAdvertising();
      }
    } else if (status == BleStatus.poweredOff) {
      _showBluetoothEnableDialog();
    }
  });

  // Checa o status inicial depois que o build estiver completo
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final initialStatus = await _ble.statusStream.first;
    if (initialStatus == BleStatus.poweredOff) {
      _showBluetoothEnableDialog();
    } else if (initialStatus == BleStatus.ready) {
      startAdvertising();
    }
  });
}

void simularConexao() async {
  setState(() {
    _deviceConnected = true;
  });

  await Future.delayed(Duration(seconds: 1));

  if (mounted) {
    _goToPreparationScreen();
  }
}

void _showBluetoothEnableDialog() {
  if (_dialogShown) return;
  _dialogShown = true;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Color(0xFF4A251D),
      title: Text('Bluetooth está desligado',
      style: GoogleFonts.vt323(
        fontSize: 40,
         height: 0.8,
        color: Colors.white,
  ),),
      content: Text('Por favor, ative o Bluetooth para continuar.',
      style: GoogleFonts.vt323(
        fontSize: 20,
         height: 0.8,
        color: Colors.white,
  )
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _dialogShown = false;
          },
          child: Text('Ok', style: GoogleFonts.vt323(
        fontSize: 20,
         height: 0.8,
        color: Colors.white,
  )),
        ),
      ],
    ),
  );
}

  void startAdvertising() {
  setState(() => _isAdvertising = true);

  _advertisingStream = _ble.scanForDevices(
    withServices: [serviceUuid],
    scanMode: ScanMode.lowLatency,
  );

  _advertisingStream!.listen((device) {
    if (_deviceConnected) return;

    if (device.name.isNotEmpty) {
      // Pare o scan assim que encontrar um dispositivo válido
      _advertisingStream = null;

      // Conecta ao dispositivo e escuta o estado da conexão
      _ble.connectToDevice(id: device.id).listen((connectionState) async {
        if (connectionState.connectionState == DeviceConnectionState.connected) {
          setState(() {
            _deviceConnected = true;
            _connectedDevice = device;
          });

          _writeChar = QualifiedCharacteristic(
            serviceId: serviceUuid,
            characteristicId: charUuid,
            deviceId: device.id,
          );

          try {
          // Envia "pronto" para o outro jogador
          await _ble.writeCharacteristicWithResponse(
            _writeChar,
            value: [1],
          );

          // Escuta a resposta do outro jogador (também [1] = pronto)
          final responseChar = QualifiedCharacteristic(
            serviceId: serviceUuid,
            characteristicId: charUuid,
            deviceId: device.id,
          );

          _ble.subscribeToCharacteristic(responseChar).listen((data) {
            if (data.isNotEmpty && data[0] == 1) {
              print("Jogador remoto confirmou que está pronto!");
              _goToPreparationScreen(); // Vamos criar isso
            }
          });

        } catch (e) {
          print("Erro ao enviar ou escutar característica: $e");
        }
        }
      }, onError: (error) {
        print("Erro na conexão: $error");
      });
    }
  }, onError: (error) {
    print("Erro no scan: $error");
  });
}

  void _goToPreparationScreen() {
  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => BluetoothPreparePage(writeChar: _writeChar,)),
    );
  }
}

  @override
  void dispose() {
    if (_isAdvertising) {
      _ble.deinitialize();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 243, 165, 152),
    body: Stack(
      children: [
        Positioned.fill(
  child: Image.asset(
    'assets/imgs/bg_menu.png', // ou o caminho da sua imagem
    fit: BoxFit.cover,
  ),
),
Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.3), // 0.0 = transparente, 1.0 = preto total
      ),
    ),
        // Conteúdo centralizado
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
              Text(
                _deviceConnected
                    ? "Jogador conectado!"
                    : _isAdvertising
                        ? "Aguardando jogador..."
                        : "Inicializando Bluetooth...",
                 textAlign: TextAlign.center,
      style: GoogleFonts.vt323(
        fontSize: 40,
        height: 0.8,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = Color(0xFF4A251D),
      ),
              ),

              Text(
                _deviceConnected
                    ? "Jogador conectado!"
                    : _isAdvertising
                        ? "Aguardando jogador..."
                        : "Inicializando Bluetooth...",
                 textAlign: TextAlign.center,
      style: GoogleFonts.vt323(
        fontSize: 40,
         height: 0.8,
        color: Color(0xFFE33117),
  ),
              ),
                ],
              ),
              SizedBox(height: 20),
              if (!_deviceConnected)
              SizedBox(
                width: 150,
                height: 200,
                child: _AnimatedTumbleweedWithShadow(),
              ),
             
              if (_modoTeste)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: simularConexao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  child: Text('Simular conexão'),
                ),
              ),
            ],
          ),
        ),

        // Botão no canto superior direito
         Positioned(
              top: 20,
              left: 20,
              child: ElevatedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothLobbyPage()));}, 
            style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF544528),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
            child: Icon(Icons.arrow_back))),
      ],
    ),
  );
}
}

class _AnimatedTumbleweedWithShadow extends StatefulWidget {
  @override
  State<_AnimatedTumbleweedWithShadow> createState() => _AnimatedTumbleweedWithShadowState();
}

class _AnimatedTumbleweedWithShadowState extends State<_AnimatedTumbleweedWithShadow>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    _bounceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -35).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: Listenable.merge([_rotationController, _bounceAnimation]),
    builder: (context, child) {
      double bounceY = _bounceAnimation.value;
      
      // Escala da sombra
      double shadowScale = 1.0 - (bounceY.abs() / 15) * 0.3;

      // Deslocamento da sombra para baixo (quanto mais o tumbleweed sobe, mais a sombra desce)
      double shadowOffsetY = (bounceY.abs() / 15) * 10;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          // Sombra
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Transform.translate(
              offset: Offset(0, shadowOffsetY),
              child: Transform.scale(
                scale: shadowScale,
                child: Center(
                  child: Image.asset(
                    'assets/imgs/tumbleweed_shadow.png',
                    width: 200,
                    height: 110,
                  ),
                ),
              ),
            ),
          ),

          // Tumbleweed
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Transform.translate(
              offset: Offset(0, bounceY),
              child: Transform.rotate(
                angle: _rotationController.value * 2 * 3.1415926535,
                child: Center(
                  child: Image.asset(
                    'assets/imgs/tumbleweed.png',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
}
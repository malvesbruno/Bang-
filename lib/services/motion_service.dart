import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

// classe que controla o movimento do celular
class MotionService {
  static final MotionService _instance = MotionService._internal();

  factory MotionService() => _instance;

  MotionService._internal();

  StreamSubscription<AccelerometerEvent>? _subscription;
  Function()? _onSaqueDetected;
  bool _hasSacado = false;

  void startListening({required Function() onSaque}) {
    _onSaqueDetected = onSaque;
    _hasSacado = false;

    _subscription = accelerometerEvents.listen((event) {
      final x = event.x;
      final y = event.y;

      // Detecta quando vira para horizontal (landscape)
      if (!_hasSacado && x.abs() > 7 && y.abs() < 3) {
        _hasSacado = true;
        _onSaqueDetected?.call();
      }
    });
  }

  void reset() {
    _hasSacado = false;
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}

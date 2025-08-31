import 'package:flutter/material.dart';


/// animação do tumblewwed girando
class AnimatedTumbleweedWithShadow extends StatefulWidget {
  const AnimatedTumbleweedWithShadow();

  @override
  State<AnimatedTumbleweedWithShadow> createState() => _AnimatedTumbleweedWithShadowState();
}

class _AnimatedTumbleweedWithShadowState extends State<AnimatedTumbleweedWithShadow>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
        double shadowScale = 1.0 - (bounceY.abs() / 15) * 0.3;
        double shadowOffsetY = (bounceY.abs() / 15) * 10;

        return Stack(
          clipBehavior: Clip.none,
          children: [
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

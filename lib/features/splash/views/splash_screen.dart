// lib/features/splash/views/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    // Después de un delay, navega a la pantalla de escaneo
    Future.delayed(const Duration(seconds: 2), () {
      // Fade out de la splash
      _ctrl.reverse().then((_) {
        context.goNamed('scan');  // o 'home' si ya no escaneas
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Color(0xFFFFF8EA);

    return FadeTransition(
      opacity: _ctrl,
      child: Scaffold(
        backgroundColor: bg,
        body: Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: Image.asset(
              'assets/icons/comandeat_icon.png'
            ),
          ),
        ),
      ),
    );
  }
}

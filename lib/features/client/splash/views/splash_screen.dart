import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrAnimacion;

  @override
  void initState() {
    super.initState();
    _ctrAnimacion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    Future.delayed(const Duration(seconds: 2), () {
      _ctrAnimacion.reverse().then((_) {
        context.goNamed('scan');
      });
    });
  }

  @override
  void dispose() {
    _ctrAnimacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Color(0xFFFFF8EA);
    return FadeTransition(
      opacity: _ctrAnimacion,
      child: Scaffold(
        backgroundColor: bg,
        body: Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: Image.asset('assets/icons/comandeat_icon.png'),
          ),
        ),
      ),
    );
  }
}

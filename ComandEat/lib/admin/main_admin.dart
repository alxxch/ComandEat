import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url:   dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: ComandEatAdminApp()));
}

class ComandEatAdminApp extends StatelessWidget {
  const ComandEatAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ComandEat – Admin',
      home: Scaffold(
        appBar: AppBar(title: const Text('Panel de pedidos')),
        body: const Center(
          child: Text('Por implementar: listado en tiempo real'),
        ),
      ),
    );
  }
}

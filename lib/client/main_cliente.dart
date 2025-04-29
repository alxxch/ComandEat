import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url:   dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: ComandEatClienteApp()));
}

class ComandEatClienteApp extends StatelessWidget {
  const ComandEatClienteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ComandEat – Cliente',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,

        // Paleta suave y fondo
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF6FA8DC),
          secondary: const Color(0xFFF9CB9C),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black87,
          onSurface: Colors.black87,
        ),

        scaffoldBackgroundColor: Colors.grey.shade50,

        // AppBar limpio
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),

        // ListTile / Card con bordes redondeados
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
          color: Colors.white,
        ),
        listTileTheme: ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        // ChoiceChip estilizado
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey.shade200,
          selectedColor: const Color(0xFF6FA8DC),
          labelStyle: const TextStyle(color: Colors.black87),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        // TextField suave
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade200,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),

        // BottomNavigationBar limpio
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF6FA8DC),
          unselectedItemColor: Colors.grey.shade600,
          showUnselectedLabels: true,
          elevation: 4,
          type: BottomNavigationBarType.fixed,
        ),

        // FloatingActionButton minimalista
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFF9CB9C),
          foregroundColor: Colors.black87,
          elevation: 2,
        ),
      ),
    );
  }
}
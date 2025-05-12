import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends ChangeNotifier {
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();

  bool isCargando = false;

  Future<void> submit(
      BuildContext context,
      VoidCallback onSuccess,
      ) async {
    isCargando = true;
    notifyListeners();

    final sql = Supabase.instance.client;
    try {
      final resultado = await sql.auth.signInWithPassword(
        email: email.text.trim(),
        password: pass.text,
      );

      if (resultado.session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales incorrectas')),
        );
      } else {
        onSuccess();
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    } finally {
      isCargando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }
}

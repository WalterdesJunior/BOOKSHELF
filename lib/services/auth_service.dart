import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _db = DatabaseService();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty) return 'Informe seu nome.';
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email)) {
      return 'E-mail inválido.';
    }
    if (password.length < 6) return 'A senha deve ter pelo menos 6 caracteres.';

    final exists = await _db.emailExists(email.toLowerCase());
    if (exists) return 'Este e-mail já está cadastrado.';

    final user = UserModel(
      name: name.trim(),
      email: email.toLowerCase().trim(),
      passwordHash: _hashPassword(password),
    );

    try {
      await _db.insertUser(user);
      return null; // sucesso
    } catch (_) {
      return 'Erro ao criar conta. Tente novamente.';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Preencha todos os campos.';
    }

    final user = await _db.getUserByEmail(email.toLowerCase().trim());
    if (user == null) return 'E-mail não encontrado.';

    if (user.passwordHash != _hashPassword(password)) {
      return 'Senha incorreta.';
    }

    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id!);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);

    return null; // sucesso
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    final email = prefs.getString('user_email');
    final name = prefs.getString('user_name');

    if (id == null || email == null || name == null) return false;

    _currentUser = UserModel(
      id: id,
      name: name,
      email: email,
      passwordHash: '', // Não necessária para sessão ativa
    );
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }
}

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isDisposed = false;
  
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    if (_isDisposed) return;
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Por favor, preencha todos os campos.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.loginWithEmail(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Por favor, preencha todos os campos.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.registerWithEmail(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.loginWithGoogle();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      _setLoading(false);
      return false;
    }
  }

  String _parseError(dynamic e) {
    final error = e.toString();
    if (error.contains('user-not-found')) return 'Usuário não encontrado.';
    if (error.contains('wrong-password')) return 'Senha incorreta.';
    if (error.contains('network-request-failed')) return 'Sem conexão com a internet.';
    return error;
  }
}

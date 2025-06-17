
class AuthService {
  static bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login(String username, String password) {
    if (username == 'user' && password == '1234') {
      _isLoggedIn = true;
    }
  }

  void logout() {
    _isLoggedIn = false;
  }
}

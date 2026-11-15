import 'package:flutter/foundation.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final IAuthRepository _authRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel({required IAuthRepository authRepository})
      : _authRepository = authRepository {
    _loadCurrentUser();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && !_currentUser!.isGuest;
  bool get isGuest => _currentUser != null && _currentUser!.isGuest;

  Future<void> _loadCurrentUser() async {
    _currentUser = await _authRepository.getCurrentUser();
    notifyListeners();
  }

  Future<bool> signIn(String emailOrPhone, String password, {bool rememberMe = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.signIn(emailOrPhone, password, rememberMe: rememberMe);
      return true;
    } catch (e) {
      _errorMessage = 'Invalid credentials. Please verify your email/password.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.signUp(name, phone, email, password);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create account. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authRepository.signInWithGoogle();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithApple() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authRepository.signInWithApple();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> continueAsGuest() async {
    _currentUser = await _authRepository.continueAsGuest();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> sendResetOtp(String emailOrPhone) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _authRepository.sendPasswordResetOtp(emailOrPhone);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String emailOrPhone, String code) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _authRepository.verifyOtp(emailOrPhone, code);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String emailOrPhone, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _authRepository.resetPassword(emailOrPhone, newPassword);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({required String name, required String email, required String phone}) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(name: name, email: email, phone: phone);
    _currentUser = await _authRepository.updateProfile(updated);
    notifyListeners();
  }

  Future<void> addAddress(Address address) async {
    await _authRepository.addAddress(address);
    _currentUser = await _authRepository.getCurrentUser();
    notifyListeners();
  }

  Future<void> updateAddress(Address address) async {
    await _authRepository.updateAddress(address);
    _currentUser = await _authRepository.getCurrentUser();
    notifyListeners();
  }

  Future<void> deleteAddress(String addressId) async {
    await _authRepository.deleteAddress(addressId);
    _currentUser = await _authRepository.getCurrentUser();
    notifyListeners();
  }

  Future<void> setDefaultAddress(String addressId) async {
    await _authRepository.setDefaultAddress(addressId);
    _currentUser = await _authRepository.getCurrentUser();
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _authRepository.deleteAccount();
    _currentUser = null;
    notifyListeners();
  }
}


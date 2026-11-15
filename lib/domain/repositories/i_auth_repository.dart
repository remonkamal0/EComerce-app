import '../models/models.dart';

abstract class IAuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signIn(String emailOrPhone, String password, {bool rememberMe = true});
  Future<UserModel> signUp(String name, String phone, String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<UserModel> continueAsGuest();
  Future<void> signOut();
  Future<bool> sendPasswordResetOtp(String emailOrPhone);
  Future<bool> verifyOtp(String emailOrPhone, String code);
  Future<bool> resetPassword(String emailOrPhone, String newPassword);
  Future<UserModel> updateProfile(UserModel user);
  Future<void> addAddress(Address address);
  Future<void> updateAddress(Address address);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefaultAddress(String addressId);
  Future<void> deleteAccount();
}


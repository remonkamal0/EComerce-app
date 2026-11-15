import '../../domain/models/models.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../services/mock_data_service.dart';

class AuthRepository implements IAuthRepository {
  UserModel? _currentUser;
  final Map<String, String> _otpStore = {};

  AuthRepository() {
    // Default to guest user so users can browse products without registration
    // Product prices will display 'لمعرفة السعر سجل' until they sign in or register
    _currentUser = const UserModel(
      id: 'guest_user',
      name: 'Guest Shopper',
      email: '',
      phone: '',
      isGuest: true,
      ordersCount: 0,
      wishlistCount: 0,
      rating: 5.0,
      reviewsCount: 0,
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserModel> signIn(String emailOrPhone, String password, {bool rememberMe = true}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final defaultUser = MockDataService.getDefaultUser();
    _currentUser = defaultUser.copyWith(
      email: emailOrPhone.contains('@') ? emailOrPhone : 'ahmed@example.com',
      isGuest: false,
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> signUp(String name, String phone, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      addresses: [MockDataService.getDefaultAddress()],
      ordersCount: 0,
      wishlistCount: 0,
      rating: 5.0,
      reviewsCount: 0,
      isGuest: false,
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = MockDataService.getDefaultUser().copyWith(
      name: 'Ahmed Mohamed (Google)',
      isGuest: false,
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = MockDataService.getDefaultUser().copyWith(
      name: 'Ahmed Mohamed (Apple)',
      isGuest: false,
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> continueAsGuest() async {
    _currentUser = const UserModel(
      id: 'guest_user',
      name: 'Guest Shopper',
      email: 'guest@homeplus.com',
      phone: '',
      ordersCount: 0,
      wishlistCount: 0,
      isGuest: true,
    );
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = const UserModel(
      id: 'guest_user',
      name: 'Guest Shopper',
      email: '',
      phone: '',
      isGuest: true,
      ordersCount: 0,
      wishlistCount: 0,
      rating: 5.0,
      reviewsCount: 0,
    );
  }

  @override
  Future<bool> sendPasswordResetOtp(String emailOrPhone) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _otpStore[emailOrPhone] = '1234'; // Demo OTP code
    return true;
  }

  @override
  Future<bool> verifyOtp(String emailOrPhone, String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Accepts 1234 or any 4-digit code in test/demo mode
    return code == '1234' || code.length == 4;
  }

  @override
  Future<bool> resetPassword(String emailOrPhone, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    _currentUser = user;
    return _currentUser!;
  }

  @override
  Future<void> addAddress(Address address) async {
    final user = _currentUser;
    if (user == null) return;
    final updatedList = List<Address>.from(user.addresses);
    if (address.isDefault) {
      for (int i = 0; i < updatedList.length; i++) {
        updatedList[i] = updatedList[i].copyWith(isDefault: false);
      }
    }
    updatedList.add(address);
    _currentUser = user.copyWith(addresses: updatedList);
  }

  @override
  Future<void> updateAddress(Address address) async {
    final user = _currentUser;
    if (user == null) return;
    final updatedList = List<Address>.from(user.addresses);
    final index = updatedList.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      if (address.isDefault) {
        for (int i = 0; i < updatedList.length; i++) {
          updatedList[i] = updatedList[i].copyWith(isDefault: false);
        }
      }
      updatedList[index] = address;
      _currentUser = user.copyWith(addresses: updatedList);
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    final user = _currentUser;
    if (user == null) return;
    final updatedList = user.addresses.where((a) => a.id != addressId).toList();
    _currentUser = user.copyWith(addresses: updatedList);
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    final user = _currentUser;
    if (user == null) return;
    final updatedList = user.addresses.map((a) {
      return a.copyWith(isDefault: a.id == addressId);
    }).toList();
    _currentUser = user.copyWith(addresses: updatedList);
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }
}


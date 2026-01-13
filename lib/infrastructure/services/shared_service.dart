import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const String _token = 'token';
  static const String _isAuthorized = 'is_authorized';
  static const String _passcode = 'passcode';
  static const String _passcodeEnabled = 'passcode_enabled';
  static const String _name = 'name';
  static const String _phone = 'phone';
  static const String _percent = 'percent';
  static const String _branchGuid = 'branch_guid';
  static const String _workerGuid = 'worker_guid';
  static const String _branchName = 'branch_name';
  static const String _image = 'image';
  static const String _role = 'role';
  static const String _guid = 'guid';
  static const String _userId = 'user_id';
  static const String _isAdmin = 'is_admin';
  static const String _authorGuid = 'author_guid';
  static const String _biometricEnabled = 'biometric_enabled';


  static late SharedPreferences _preference;

  const SharedPrefService._();

  static Future<SharedPrefService> initialize() async {
    _preference = await SharedPreferences.getInstance();
    return const SharedPrefService._();
  }

  void setAuthorGuid(String authorGuid) => _preference.setString(_authorGuid, authorGuid);
  String get getAuthorGuid => _preference.getString(_authorGuid) ?? '';

  void setIsAdmin(bool isAdmin) => _preference.setBool(_isAdmin, isAdmin);
  bool get getIsAdmin => _preference.getBool(_isAdmin) ?? false;

  void setToken(String token) => _preference.setString(_token, token);
  String get getToken => _preference.getString(_token) ?? '';

  void setRole(List<String> role) => _preference.setStringList(_role, role);
  List<String> get getRole => _preference.getStringList(_role) ?? [];


  void setUserId(int userId) => _preference.setInt(_userId, userId);

  int get getUserId => _preference.getInt(_userId) ?? 0;



  void setBranchName(String branchName) => _preference.setString(_branchName, branchName);
  String get getBranchName => _preference.getString(_branchName) ?? '';

  void setImage(String image) => _preference.setString(_image, image);
  String get getImage => _preference.getString(_image) ?? '';

  void setPercent(String percent) => _preference.setString(_percent, percent);
  String get getPercent => _preference.getString(_percent) ?? '';
  void setBranchGuid(String branchGuid) => _preference.setString(_branchGuid, branchGuid);
  String get getBranchGuid => _preference.getString(_branchGuid) ?? '';
  void setWorkerGuid(String workerGuid) => _preference.setString(_workerGuid, workerGuid);
  String get getWorkerGuid => _preference.getString(_workerGuid) ?? '';

  void setName(String name) => _preference.setString(_name, name);

  String get getName => _preference.getString(_name) ?? '';

  void setAuthStatus(bool value) => _preference.setBool(_isAuthorized, value);

  bool get isAuthorized => _preference.getBool(_isAuthorized) ?? false;

  void setPasscode(String value) => _preference.setString(_passcode, value);

  String get passcode => _preference.getString(_passcode) ?? '';

  void setPasscodeEnabled(bool value) => _preference.setBool(_passcodeEnabled, value);

  bool get isPasscodeEnabled => _preference.getBool(_passcodeEnabled) ?? false;

  void setPhone(String phone) => _preference.setString(_phone, phone);

  String get getPhone => _preference.getString(_phone) ?? '';

  ///guid
  void setGuid(String guid) => _preference.setString(_guid, guid);

  String get getGuid => _preference.getString(_guid) ?? '';

  void setBiometricEnabled(bool value) => _preference.setBool(_biometricEnabled, value);

  bool get isBiometricEnabled => _preference.getBool(_biometricEnabled) ?? false;

  void clear() => _preference.clear();
}

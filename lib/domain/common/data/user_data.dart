class UserData {
  static int branchId = 0;
  static int workerId = 0;
  static int positionId = 0;
  static int userId = -1;
  static List<int?>? roleId = [];
  static String name = '';
  static String authorGuid = '';
  static String branchName = '';
  static String positionName = '';
  static String image = '';
  static String phone = '';
  static String token = '';
  static String deviceToken = '';
  static String passCode = "";
  static bool passCodeStatus = false;
  static bool isAdmin = false;
  static List<String>? role = [];
  static String responsibleWorker = "";
  static Map<String, dynamic> deviceInfo = {};
  static Map<String?, List<String?>?>? permissions = {};
}

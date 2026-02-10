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
  static bool xZiffler = false;
  static List<String>? role = [];
  static String responsibleWorker = "";
  static Map<String, dynamic> deviceInfo = {};
  static Map<String?, List<String?>?>? permissions = {};

  static void reset() {
    branchId = 0;
    workerId = 0;
    positionId = 0;
    userId = -1;
    roleId = [];
    name = '';
    authorGuid = '';
    branchName = '';
    positionName = '';
    image = '';
    phone = '';
    token = '';
    deviceToken = '';
    passCode = "";
    passCodeStatus = false;
    isAdmin = false;
    xZiffler = false;
    role = [];
    responsibleWorker = "";
    deviceInfo = {};
    permissions = {};
  }
}

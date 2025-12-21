
import 'package:hisobchi/domain/common/data/user_data.dart';

extension Check on String {

  bool get isScreenshot {
    final checkPermission = ((UserData.permissions ?? {})[this] ?? []).contains("screenshot");
    return checkPermission;
  }

  bool get isShow {
    final checkPermission = ((UserData.permissions ?? {})[this] ?? []).contains("show");
    return checkPermission;
  }

  bool get isStore {
    final checkPermission = ((UserData.permissions ?? {})[this] ?? []).contains("store");
    return checkPermission;
  }

  bool get isUpdate {
    final checkPermission = ((UserData.permissions ?? {})[this] ?? []).contains("update");
    return checkPermission;
  }

  bool get isDelete {
    final checkPermission = ((UserData.permissions ?? {})[this] ?? []).contains("delete");
    return checkPermission;
  }

  bool get isRestore {
    final checkPermission = ((UserData.permissions ?? {})[this] ?? []).contains("restore_delete");
    return checkPermission;
  }

  bool get forceDelete {
    final checkPermission = ((UserData.permissions ?? {})[this] ?? []).contains("force_delete");
    return checkPermission;
  }
}

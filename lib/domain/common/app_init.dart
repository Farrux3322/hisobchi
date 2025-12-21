import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> initializeApp() async {

  // await Upgrader.clearSavedSettings();
  // await Hive.initFlutter();
  // // Hive.registerAdapter(ProductsAdapter());
  // await Hive.openBox("reyting_box");
  // await Hive.openBox("reyting_detail_box");
  // await Hive.openBox("product_history_box");
  // await Hive.openBox("app_lock_date_box");
  // await Hive.openBox("app_photo_add_box"  );

  await EasyLocalization.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  // AppTheme.init() ScreenUtilInit ichida chaqiriladi
}

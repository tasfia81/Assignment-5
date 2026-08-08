import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/deck_repository.dart';
import 'data/repositories/local_deck_repository.dart';
import 'routes/app_routes.dart';
import 'viewmodels/session_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initDependencies();
  runApp(const FlashSwipeApp());
}

void _initDependencies() {
  ///--------------------------- Inject repository and viewmodel singletons ------------------------------------
  Get.put<DeckRepository>(LocalDeckRepository());
  Get.put(SessionViewModel());
}

class FlashSwipeApp extends StatelessWidget {
  const FlashSwipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ScreenUtilInit ensures responsive layout adjustments across devices
    return ScreenUtilInit(
      designSize: const Size(390, 844), // Design resolution baseline (iPhone 13/14)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'FlashSwipe',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          initialRoute: AppRoutes.home,
          getPages: AppRoutes.pages,
        );
      },
    );
  }
}

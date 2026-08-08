import 'package:get/get.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/session_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String session = '/session';

  static final List<GetPage> pages = [
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: session,
      page: () => const SessionScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}

import 'package:get/get.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/session_screen.dart';
import '../views/screens/summary_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String session = '/session';
  static const String summary = '/summary';

  static final List<GetPage> pages = [
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: session,
      page: () => SessionScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: summary,
      page: () => const SummaryScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}

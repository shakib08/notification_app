import 'package:get/get.dart';
import 'package:notification_app/features/home/view/home_view.dart';
import 'package:notification_app/features/login/view/login_view.dart';
import 'package:notification_app/features/registration/view/registration_view.dart';


class Routes {
  static const login = '/login';
  static const registration = '/registration';
  static const home = '/home';
}

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.login,
      page: () =>  LoginView(),
    ),
    GetPage(
      name: Routes.registration,
      page: () =>  RegistrationView(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
    ),
  ];
}

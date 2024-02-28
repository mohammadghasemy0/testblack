import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/background.dart';
import '../../responsive.dart';
import 'components/login_signup_btn.dart';
import 'components/welcome_image.dart';
// import '../dashboard/dashboard_screen.dart';
import '../Signup/signup_screen.dart';
import '../dash/dash.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // نمایش انتظار در حال دریافت وضعیت لاگین
        } else {
          final isLoggedIn = snapshot.data ?? false; // اطلاعات از فیوچر برگردانده شده و مقدار پیش‌فرض false است

          if (isLoggedIn) {
            // اگر کاربر لاگین کرده باشد، به صفحه DashboardScreen هدایت شود
            print('is logined');
            return DashboardScreen(); // navigate to DashboardScreen
          } else {
            print('is not logine');
            return const Background(
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Responsive(
                    desktop: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: WelcomeImage(),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 450,
                                child: LoginAndSignupBtn(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    mobile: MobileWelcomeScreen(),
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }
  Future<bool> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');
  
    // اگر هر دو مقدار username و password وجود داشته باشند، isLoggedIn را true قرار دهید؛ در غیر این صورت، آن را false قرار دهید.
    return (username != null && password != null);
  }
}

class MobileWelcomeScreen extends StatelessWidget {
  const MobileWelcomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        WelcomeImage(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: LoginAndSignupBtn(),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}

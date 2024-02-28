import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../Login/login_screen.dart';
import '../../Signup/signup_screen.dart';
class LoginAndSignupBtn extends StatelessWidget {
  const LoginAndSignupBtn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const SignUpScreen();
                },
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF00555C), // رنگ زمینه دکمه
            elevation: 5, // سایه
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), // حاشیه داخلی
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // گوشه گرد کردن دکمه
            ),
          ),
          child: Text(
            "ورود به اکانت".toUpperCase(),
            style: TextStyle(
              color: Colors.white, // رنگ متن دکمه
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
  import 'package:flutter/material.dart';

  import '../../../components/already_have_an_account_acheck.dart';
  import '../../../constants.dart';
  import '../../Login/login_screen.dart';

  import 'package:http/http.dart' as http;
  import 'dart:convert'; // برای تبدیل JSON

  import 'package:shared_preferences/shared_preferences.dart';
  import '../../dash/dash.dart';
  import 'package:fluttertoast/fluttertoast.dart';


  class SignUpForm extends StatefulWidget {
    const SignUpForm({Key? key}) : super(key: key);

    @override
    _SignUpFormState createState() => _SignUpFormState();
  }

  class _SignUpFormState extends State<SignUpForm> {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _emailController = TextEditingController(); // 3. تعریف کنترلر برای ایمیل
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _confirmPasswordController = TextEditingController();
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final FocusNode _focusNode = FocusNode();
    // 4. تعریف کنترلر برای رمز عبور
    
    
    void send_toast(String text) {
                Fluttertoast.showToast(
                        msg: text,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Color(0xFF00555C),
                        textColor: Colors.white,
                      );
    }
  
    @override
    Widget build(BuildContext context) {
      bool isRightAligned = false;
      return Form(
        
        key: _formKey, // اعمال GlobalKey به فرم
        child: Column(
          children: [
            TextFormField(
              
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: Colors.white,
              textDirection: TextDirection.ltr ,
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'لطفا یوزرنیم خود را وارد کنید'; // 3. اعتبارسنجی فیلد ایمیل
                }
                return null;
              },
              style: TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "یوزرنیم",
                hintTextDirection: TextDirection.rtl,
                
                prefixIcon: Padding(
                  
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.person,color: Colors.white),
                  
                ),
                filled: true,
                fillColor: Color(0xFF00555C),
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.white),
                counterStyle :  TextStyle(color: Colors.white),
                errorStyle :  TextStyle(color: Colors.white),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              
              child: TextFormField(
                textInputAction: TextInputAction.done,
                obscureText: true,
                cursorColor: Colors.white,
                // ignore: dead_code
                textDirection: TextDirection.ltr ,
                

                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفا رمز عبور خود را وارد کنید'; // اعتبارسنجی فیلد رمز
                  }
                  return null;
                },
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "رمز عبور",
                  hintTextDirection: TextDirection.rtl,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.lock,color: Colors.white),
                  ),
                                filled: true,
                fillColor: Color(0xFF00555C),
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.white),
                counterStyle :  TextStyle(color: Colors.white),
                errorStyle :  TextStyle(color: Colors.white),
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: defaultPadding /10),
            //   child: TextFormField(
                
            //     textInputAction: TextInputAction.done,
            //     obscureText: true,
            //     cursorColor: kPrimaryColor,
            //     textDirection: TextDirection.ltr,
            //     controller: _confirmPasswordController,
            //     validator: (value) {
            //       if (value == null || value.isEmpty) {
            //         return 'لطفا تکرار رمز عبور را وارد کنید';
            //       }
            //       if (value != _passwordController.text) {
            //         return 'رمز عبور با تکرار آن مطابقت ندارد';
            //       }
            //       return null;
            //     },
            //     decoration: const InputDecoration(
            //       hintText: "تکرار رمز عبور",
            //       hintTextDirection: TextDirection.rtl,
            //       prefixIcon: Padding(
            //         padding: EdgeInsets.all(defaultPadding),
            //         child: Icon(Icons.lock),
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: defaultPadding ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // _focusNode.unfocus();
                  final String email = _emailController.text;
                  final String password = _passwordController.text;
                  var success = await _sendDataToApi(email, password);
                  print(success);
                  if (success == 'good') {
                    _save_login(context,email,password);
                    print(await getSavedCredentials(context));

                    // اگر درخواست موفق بود، عملیات دیگری انجام ندهید
                    send_toast('ورود با موفقیت انجام شد');
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardScreen()),
                      (route) => false,
                    );
                    
                  } else if (success == 'invalid_username') {
                    // اگر درخواست ناموفق بود، پیام خطا را نمایش دهید
                    send_toast('یوزرنیم معتبر نمیباشد');
                  } else if (success == 'invalid_pass') {
                    // اگر درخواست ناموفق بود، پیام خطا را نمایش دهید
                    send_toast('رمز عبور معتبر نمیباشد');
                  } else {
                    send_toast('مشکلی پیش آمده ، بعدا امتحان کنید');
                  }

                }
              },
              style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // برای شکل گرد کردن دکمه
                            ),
                            minimumSize: const Size(120, 40),
                            backgroundColor: Color(0xFF1A237E), //
              ),
              child: Text("ساخت حساب".toUpperCase()),
            ),
            
            const SizedBox(height: defaultPadding),
            // AlreadyHaveAnAccountCheck(
            //   login: false,
            //   press: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) {
            //           return const LoginScreen();
            //         },
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
        
      );
    }
    void _save_login(BuildContext context, String username, String password) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('username', username);
      prefs.setString('password', password);
    }
    Future<Map<String, String>> getSavedCredentials(BuildContext context) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? username = prefs.getString('username');
      final String? password = prefs.getString('password');
      return {'username': username ?? '', 'password': password ?? ''};
    }
    Future<dynamic> _sendDataToApi(String email, String password) async {
      try {
        var response = await http.post(
          Uri.parse('http://91.107.240.247:9595/login'),
          body: {
            'email': email,
            'password': password,
          },
        );
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final result = responseData['result'];
          print('kos');
          print(result);
          return result;
        } else {
          return false;
        }
      } catch (e) {
        print(e);
        return false;
      }
    }
    void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,textAlign: TextAlign.center,),
        behavior: SnackBarBehavior.floating,
        
      ),
    );
    
    
  }
  }


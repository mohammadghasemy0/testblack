import 'package:flutter/material.dart';
import 'dart:convert'; // برای تبدیل JSON
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart'; // import for animation progress bar
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // import for notifications
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'dart:io' show Platform;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Welcome/welcome_screen.dart';
import 'dart:io' show Platform;


void main() {
  runApp(MaterialApp(
    home: DashboardScreen(),
  ));
}

class ApiService {
  static Future<String> fetchNews() async {
    final response = await http.get(Uri.parse('http://91.107.240.247:9595/news'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load news');
    }
  }
  static Future<Map<String, dynamic>> checkUpdate() async {
    final response = await http.get(Uri.parse('http://91.107.240.247:9595/update'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to check for updates');
    }
  }
}

class AppColors {
  static const Color primaryColor = Color(0xFF4CAF50); // آبی تیره
  static const Color secondaryColor = Color(0xFF3F51B5); // قرمز تیره
  static const Color darkColor = Color(0xFF1A237E); // آبی تیره تر
  static const Color lightColor = Color(0xFFE8EAF6); // آبی روشن
  static const Color accentColor = Color(0xFF1B5E20); // سبز تیره
}

class V2rayStatusManager {
  static ValueNotifier<String> v2rayStatus = ValueNotifier('Disconnected');
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, String>> _userData;
  late Future<List<Subscription>> _subscriptionList;
  late Future<String> news_text;
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late String latestVersion = '';
  late String updateLink = '';
  late final AudioCache _audioCache;
  int _page = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    news_text = ApiService.fetchNews();
    _userData = getSavedCredentials();
    _subscriptionList = fetchSubscriptions();
    _page = 1;
    _audioCache = AudioCache(
      prefix: 'assets/',
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );
    
    // V2rayStatusManager.v2rayStatus = ValueNotifier('Disconnected');
     // Initial state is Disconnected
  }

  Future<Map<String, String>> getSavedCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final password = prefs.getString('password') ?? '';
    return {'username': username, 'password': password};
  }
  Future<void> deleteSavedCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
  }
  Future<List<Subscription>> fetchSubscriptions() async {
    final response = await http.get(Uri.parse('http://91.107.240.247:9595/list'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Subscription.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load subscriptions');
    }
  }
    Future<dynamic> _check_login_data(String email, String password) async {
      try {

        var response = await http.post(
          Uri.parse('http://91.107.240.247:9595/login'),
          body: {
            'email': email,
            'password': password,
          },
        );
        print(email);
        print(password);
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final result = responseData;
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
  void _refreshSubscriptions() async{

    await _audioCache.play('sounds/update_sound.mp3');
    setState(() {
      _subscriptionList = fetchSubscriptions();
      news_text = ApiService.fetchNews();
    });
  }

  void _refreshUserProfile() {
    setState(() {
      _userData = getSavedCredentials();
      print(_userData);
    });
  }

  List<String> bypassSubnets = [];


 void _handleNavigation(int index) {
  switch(index) {
    case 0:
      updateapp();
      break;
    case 1:
      _refreshSubscriptions();
      break;
    case 2:
      print(index);
      break;
    case 3:
      print(index);
      break;
    case 4:
      print(index);
      break;
    default:
    print(index);
      // اگر شرایطی مطابقت نداشته باشد
  }
}
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
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('داشبورد'),
      // ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page, // ایندکس صفحه فعلی
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.get_app_sharp, size: 30,color: Color(0xFF00555C),),
          Icon(Icons.refresh_sharp, size: 30,color: Color(0xFF00555C),),
          Icon(Icons.support_agent, size: 30,color: Color(0xFF00555C),),
 
        ],
        color: Color.fromARGB(255, 255, 255, 255),
        buttonBackgroundColor: Colors.white,
        backgroundColor: Color(0xFF708090),
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          _handleNavigation(index); // فراخوانی تابع مدیریت ناوبری
        },
        letIndexChange: (index) => true,
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError || snapshot.data == null) {
              return const Text('خطا: اطلاعات کاربر دریافت نشد');
            } else {
              final username = snapshot.data!['username'];
              final password = snapshot.data!['password'];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                textDirection: TextDirection.rtl,
                children: [
                  const SizedBox(height: 50),
                  const Card(
                    color: Color(0xFF00555C), // Updated color
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 5), // Reduced margin

                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'BlackSpeed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  
                  FutureBuilder<String>(
                    future: news_text,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError || snapshot.data == null) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'خطا: اطلاعات اطلاعیه دریافت نشد',
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF08457E),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                                    child: Text(
                                      snapshot.data!,
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
           
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly, // تراز کردن دکمه‌ها
                  //   children: [
                  //     ElevatedButton(
                  //       onPressed: (){
                  //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('این بخش به زودی فعال میشود',textDirection: TextDirection.rtl,)));
                  //       },
                  //       style: ElevatedButton.styleFrom(
                  //         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(10), // برای شکل گرد کردن دکمه
                  //         ),
                  //         minimumSize: const Size(120, 40),
                  //         backgroundColor:Color(0xFF560319), // رنگ تیره
                  //       ),
                  //       child: Text(
                  //         "خرید اشتراک".toUpperCase(),
                  //         style: const TextStyle(color: Colors.white), // رنگ متن
                  //       ),
                  //     ),
                  //     ElevatedButton(
                  //       onPressed: () async {
                  //         final updateData = await ApiService.checkUpdate();
                  //         print(updateData);
                  //         var nowversion = '1.0.0';
                  //         latestVersion = updateData['result']['version'];
                  //         updateLink = updateData['result']['link'];
                  //         if (latestVersion != nowversion) {
                  //           print('update app');
                  //           openLink('https://google.com');
                  //         } else {
                  //           print('lasted installed');
                  //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('درحال حاضر از آخرین نسخه برنامه استفاده میکنید.',textDirection: TextDirection.rtl,)));
                  //         }
                  //         print('here');
                  //         print(latestVersion);
                  //       },
                  //       style: ElevatedButton.styleFrom(
                  //         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(10), // برای شکل گرد کردن دکمه
                  //         ),
                  //         minimumSize: const Size(120, 40),
                  //         backgroundColor: Color(0xFF560319), // رنگ تیره
                  //       ),
                  //       child: Text(
                  //         "بروزرسانی برنامه".toUpperCase(),
                  //         style: const TextStyle(color: Colors.white), // رنگ متن
                  //       ),
                  //     ),
                  //     ElevatedButton(
                  //       onPressed: () {
                  //        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('این بخش به زودی فعال میشود',textDirection: TextDirection.rtl,)));

                  //       },
                  //       style: ElevatedButton.styleFrom(
                  //         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(10), // برای شکل گرد کردن دکمه
                  //         ),
                  //         minimumSize: const Size(120, 40),
                  //         backgroundColor: Color(0xFF560319), // رنگ تیره
                  //       ),
                  //       child: Text(
                  //         "پشتیبانی".toUpperCase(),
                  //         style: const TextStyle(color: Colors.white), // رنگ متن
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 5),
          Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'اشتراک ها',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
      Expanded(
        child: FutureBuilder<List<Subscription>>(
          future: _subscriptionList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasError) {
                return Center(
                  child: Text('خطا: ${snapshot.error}'),
                );
              } else {
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'شما هنوز اشتراکی ندارید',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                        onPressed: () {
                          openLink('https://google.com');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // برای شکل گرد کردن دکمه
                          ),
                          minimumSize: const Size(120, 40),
                          backgroundColor: Color(0xFF00555C), // رنگ تیره
                        ),
                        child: Text(
                          "خرید اشتراک از ربات".toUpperCase(),
                          style: const TextStyle(color: Colors.white), // رنگ متن
                        ),
                      ),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final subscription = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              subscription.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              subscription.link,
                              style: TextStyle(fontSize: 14),
                            ),
                            onTap: () async{
                              var data = await getSavedCredentials();
                              var username = data['username'];
                              var password = data['password'];
                              var version = '1.0.0';
                              var result_login = await _check_login_data(username!,password!);
                              print(result_login);
                              if (result_login['result'] == 'good') {
                                if (result_login['version'] == version) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SubscriptionDetailsScreen(subscription: subscription)),
                                  );
                                } else {
                                  return send_toast('لطفا برنامه را بروزرسانی کنید ');
                                }
                              } else {
                                print('wronnng');
                                deleteSavedCredentials();
                                   Navigator.pushReplacement(
                                     context,
                                     MaterialPageRoute(builder: (context) => WelcomeScreen()),
                                   );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              }
            }
          },
        ),
      ),
    ],
  ),
),

                 
                ],
              );
            }
          }
        },
      ),

floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
floatingActionButton: FloatingActionButton(
  onPressed: () {
    deleteSavedCredentials();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
    },
  child: Icon(Icons.logout_outlined, color: Colors.white),
  backgroundColor: Color(0xFF00555C), // dark color
),
    );
  }
void openLink(String link) async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (await url_launcher.canLaunch(link)) {
        await url_launcher.launch(link);
      } else {
        throw 'Could not launch $link';
      }
    } 
  }
   void updateapp() async {
                          final updateData = await ApiService.checkUpdate();
                          print(updateData);
                          var nowversion = '1.0.0';
                          latestVersion = updateData['result']['version'];
                          updateLink = updateData['result']['link'];
                          if (latestVersion != nowversion) {
                            print('update app');
                            openLink(updateLink);
                          } else {
                            print('lasted installed');
                             send_toast('درحال حاضر آخرین نسخه نصب میباشد');
                        }}
            
}

class Subscription {
  final String link;
  final String name;
  final double remainingData;
  final double totalData; // added total data field
  final String expirationDate;
  final String status;
  final String config;

  Subscription({
    required this.link,
    required this.name,
    required this.remainingData,
    required this.totalData, // added total data field
    required this.expirationDate,
    required this.status,
    required this.config,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      link: json['link'],
      config: json['config'],
      name: json['name'],
      remainingData: json['remainingData'] ?? 0.0,
      totalData: json['totalData'] ?? 0.0, // added total data field
      expirationDate: json['expirationDate'] ?? 'نامشخص',
      status: json['status'] ?? 'نامشخص',
    );
  }
}

class SubscriptionDetailsScreen extends StatefulWidget {
  final Subscription subscription;
  const SubscriptionDetailsScreen({Key? key, required this.subscription}) : super(key: key);

  @override
  _SubscriptionDetailsScreenState createState() => _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  late final FlutterV2ray flutterV2ray = FlutterV2ray(
    onStatusChanged: (status) {
      v2rayStatus.value = status;
    },
  );
  
  var v2rayStatus = ValueNotifier<V2RayStatus>(V2RayStatus());
  final linkController = TextEditingController();
  late final AudioCache _audioCache;
  
  final config = TextEditingController();
  String? coreVersion;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _page = 1;
  

  @override
  void initState() {
    super.initState();
      flutterV2ray.initializeV2Ray().then((value) async {
      coreVersion = await flutterV2ray.getCoreVersion();
      setState(() {});
      _audioCache = AudioCache(
      prefix: 'assets/',
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );
    });
    // V2rayStatusManager.v2rayStatus = ValueNotifier('Disconnect');
    
    linkController.text = widget.subscription.link;
  }
 void _handleNavigation(int index) {
  switch(index) {
    case 0:
      delay(widget.subscription.config);
      break;
   
    default:
    print(index);
      // اگر شرایطی مطابقت نداشته باشد
  }}
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
    
    return Scaffold(
            bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0, // ایندکس صفحه فعلی
        height: 60.0,
        items: const <Widget>[
          // Icon(Icons.get_app_sharp, size: 30,color: Color(0xFF00555C),),
          Icon(Icons.network_wifi_rounded, size: 30,color: Color(0xFF00555C),),
          // Icon(Icons.support_agent, size: 30,color: Color(0xFF00555C),),
 
        ],
        color: Color.fromARGB(255, 44, 62, 80),
        buttonBackgroundColor: Colors.white,
        backgroundColor: Color(0xFF708090),
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          _handleNavigation(index); // فراخوانی تابع مدیریت ناوبری
        },
        letIndexChange: (index) => true,
      ),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 44, 62, 80),
        title: const Text('BlackSpeed',style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Updated text color
                    ),textDirection: TextDirection.rtl,textAlign: TextAlign.right),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 44, 62, 80), // Updated background color
                border: Border.all(color: Colors.grey), // Add border
                borderRadius: BorderRadius.circular(10), // Add border radius
              ),
              padding: const EdgeInsets.all(15),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
   
                  SizedBox(height: 10),
                  Text('💡 راهنما', textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white)), // Updated text color
                  SizedBox(height: 10),
                  Text(
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    '🟢 جهت اتصال روی دکمه اتصال کلیک کنید و منتظر بمانید \n\n🟠 درصورتی که اتصال برقرار بود اما به اینترنت متصل نبودید یک پینگ از سرور بگیرید تا وضعیت سرور را بررسی کنید \n\n\nجهت آپدیت سرور به صفحه قبل بازگشته و بروزرسانی کنید ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Updated text color
                    ),
                  ),
                ],
              ),),
        // Row(
        //   children: [
        //     const Spacer(),
        //     Expanded(
        //       flex: 8,
        //       child: Image.asset("assets/images/vpn.png"),
        //     ),
        //     const Spacer(),
        //   ],
        // ),
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 44, 62, 80), // Updated background color
                border: Border.all(color: Colors.grey), // Add border
                borderRadius: BorderRadius.circular(10), // Add border radius
              ),
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
   
                  const SizedBox(height: 10),
                  Text('نام اشتراک : ${widget.subscription.name}', textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white)), // Updated text color
                  const SizedBox(height: 10),
                  Text(
                    textAlign: TextAlign.center,
                    'تاریخ انقضا: ${widget.subscription.expirationDate}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Updated text color
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    textAlign: TextAlign.center,
                    'وضعیت: ${widget.subscription.status}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Updated text color
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'جهت کپی کردن لینک کلیک کنید :',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.white, // Updated text color
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: linkController,
                    readOnly: true,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.subscription.link));
            Fluttertoast.showToast(
              msg: 'لینک در کیبورد شما کپی شد',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Color(0xFF00555C),
              textColor: Colors.white,
            );                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      hintText: 'برای کپی کردن لمس کنید',
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  ValueListenableBuilder(
                    
                    valueListenable: v2rayStatus,
                    
                    builder: (context, status, _) {
                      return Column(
                        textDirection: TextDirection.rtl,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        
                        children: [
                          
                          Text(
                            'وضعیت اتصال: ${status.state}',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: v2rayStatus.value.state == 'CONNECTED' ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 500),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: FAProgressBar( // animation progress bar
                              // key: ValueKey<String>(status),
                              currentValue: widget.subscription.remainingData, // current value
                              maxValue: widget.subscription.totalData, // max value
                              size: 10, // size of progress bar
                              backgroundColor: Colors.grey, // background color
                              progressColor: _getProgressBarColor(widget.subscription.remainingData, widget.subscription.totalData), // progress color based on remaining data
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'داده باقی‌مانده: ${widget.subscription.remainingData} گیگابایت از ${widget.subscription.totalData} گیگابایت',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getProgressBarColor(widget.subscription.remainingData, widget.subscription.totalData),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder(
                    
                    valueListenable: v2rayStatus,
                    
                    builder: (context, status, _) {
                      return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            
                            children: [

                              ElevatedButton(
                                onPressed: () async{
                                  if (Platform.isAndroid) {
    // اگر دستگاه اندروید است، این بلوک اجرا می‌شود
                                        print('Android device detected.');
                                      } else if (Platform.isIOS) {
                                        // اگر دستگاه iOS است، این بلوک اجرا می‌شود
                                        return send_toast('امکان اتصال در ios وجود ندارد');
                                      }
                                   if (v2rayStatus.value.state == 'CONNECTED') {
                                     disconnect();
                                     await _audioCache.play('sounds/connect.mp3');
                                   } else {
                                     connect(widget.subscription.link, widget.subscription.config);
                                     await _audioCache.play('sounds/connect.mp3');
                                   }
                                   print(v2rayStatus.value.state);
                                 },
                                    
                                
                                child: Text(v2rayStatus.value.state == 'CONNECTED'
                                    ? 'قطع اتصال'
                                    : 'اتصال'),
                                style: ElevatedButton.styleFrom(
                               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(10),
                                  // برای شکل گرد کردن دکمه
                               ),
                                 backgroundColor: v2rayStatus.value.state == 'CONNECTED' ? Colors.red : Colors.green
                                ),    
                                                            
                              ),
              
                             
              
                            ],
                          ),
            );
                    },
                  ),
            
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
  void delay(String config_json) async {
    late int delay;
    if (Platform.isAndroid) {
    // اگر دستگاه اندروید است، این بلوک اجرا می‌شود
     print('Android device detected.');
     send_toast('درحال دریافت پینگ');
    } else if (Platform.isIOS) {
                                        // اگر دستگاه iOS است، این بلوک اجرا می‌شود
     return send_toast('امکان اتصال در ios وجود ندارد');
    }
      
    if (v2rayStatus.value.state == 'CONNECTED') {
      delay = await flutterV2ray.getConnectedServerDelay();
    } else {
      delay = await flutterV2ray.getServerDelay(config: config_json);
    }
      send_toast('Ping : ${delay}ms');
    if (!mounted) return;
            Fluttertoast.showToast(
              msg: 'Ping : ${delay}ms',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Color(0xFF00555C),
              textColor: Colors.white,
            );
            await _audioCache.play('sounds/ping.mp3');
    }
  void connect(String link,String config_json) async {
    final V2RayURL v2rayURL = FlutterV2ray.parseFromURL(link);
    var remark = v2rayURL.remark;
    var config_url = v2rayURL.getFullConfiguration();
    String configString = config_url;
    if (await flutterV2ray.requestPermission()) {
      flutterV2ray.startV2Ray(
        remark: remark,
        config: config_json,
        proxyOnly: false,
        bypassSubnets: [],
      );
      print(V2rayStatusManager.v2rayStatus.value);
          var delay = await flutterV2ray.getConnectedServerDelay();
    print(delay);
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('دسترسی مسدود شد'),
        ),
      );
    }
  }

  void disconnect() async {
    await flutterV2ray.stopV2Ray();
    var delay = await flutterV2ray.getConnectedServerDelay();
    print(delay);
  }
  Color _getProgressBarColor(double remainingData, double totalData) {
    double ratio = remainingData / totalData;
    if (ratio > 0.7) {
      return Colors.green;
    } else if (ratio > 0.3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getTextColor(double remainingData) {
    return remainingData > 10 ? Colors.green : Colors.red;
  }


  //   void delay() async {
  //   late int delay;
  //   if (v2rayStatus.value.state == 'CONNECTED') {
  //     delay = await flutterV2ray.getConnectedServerDelay();
  //   } else {
  //     delay = await flutterV2ray.getServerDelay(config: config.text);
  //   }
  //   if (!mounted) return;
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         '${delay}ms',
  //       ),
  //     ),
  //   );
  // }

}

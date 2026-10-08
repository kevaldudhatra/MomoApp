import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/notification_service.dart';
import 'package:momos/network/socket_service.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/cartManagement/cart_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: Platform.isAndroid
        ? const FirebaseOptions(
            apiKey: 'AIzaSyDnMncD9j6a6ZOkggo2bkeWbEm6xQAYf2A',
            appId: '1:432315956205:android:148f86f6df3765f23485e4',
            messagingSenderId: '432315956205',
            projectId: 'momo-app-bf562',
          )
        : const FirebaseOptions(
            apiKey: 'AIzaSyA535uEDG8DgYAytc49vxjthixKi7jplJw',
            appId: '1:432315956205:ios:c3f9d410d63d5bc23485e4',
            messagingSenderId: '432315956205',
            projectId: 'momo-app-bf562',
          ),
  );
  await GetStorage.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: background,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Momos',
      defaultTransition: Transition.noTransition,
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.routes,
      initialBinding: BindingsBuilder(() async {
        Get.put(CartController(), permanent: true);
        final storage = GetStorage();
        if (storage.read(loginTrue) == true) {
          String authToken = await storage.read(userToken);
          String token = authToken.replaceFirst('Bearer ', '');
          SocketService().connect(userToken: token);
          await NotificationService().init();
          await NotificationService().getDeviceToken();
        }
      }),
    );
  }
}

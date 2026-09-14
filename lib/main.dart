import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
      initialBinding: BindingsBuilder(() {
        Get.put(CartController(), permanent: true);
        final socketService = Get.put(SocketService(), permanent: true);
        final storage = GetStorage();
        if (storage.read(loginTrue) == true) {
          socketService.connect();
        }
      }),
    );
  }
}

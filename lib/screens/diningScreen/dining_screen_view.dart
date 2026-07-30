import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/screens/diningScreen/dining_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';

class DiningScreen extends GetView<DiningScreenController> {
  const DiningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }
}

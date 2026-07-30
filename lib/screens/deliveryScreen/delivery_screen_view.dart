import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/screens/outletScreen/outlet_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/custom_text_field.dart';
import 'package:momos/screens/cartManagement/cart_controller.dart';
import 'package:momos/screens/cartManagement/cart_button.dart';

class CarouselSlider extends StatefulWidget {
  const CarouselSlider({super.key});

  @override
  State<CarouselSlider> createState() => _CarouselSliderState();
}

class _CarouselSliderState extends State<CarouselSlider> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 155,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    AppImages().carouselImg,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isActive ? orange : lightGray,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class DeliveryScreen extends GetView<DeliveryScreenController> {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categories = [
      {"name": "Chicken xao\nlong bao", "image": AppImages().foodItemOne},
      {"name": "Green\ncoriander fish", "image": AppImages().foodItemThree},
      {"name": "Pepper\nsriaracha fish", "image": AppImages().foodItemTwo},
      {"name": "Teriyaki\nchicken salad", "image": AppImages().foodItemOne},
      {"name": "Non veg shushi\nparty pack", "image": AppImages().foodItemOne},
      {"name": "Miso ramen\npork", "image": AppImages().foodItemTwo},
      {"name": "Lasa pork", "image": AppImages().foodItemThree},
      {
        "name": "Stir fried green\ncoriander rice",
        "image": AppImages().foodItemTwo,
      },
      {
        "name": "Hangover spicy\nchicken momo",
        "image": AppImages().foodItemOne,
      },
    ];

    final List<dynamic> topPicks = [
      {
        "title": "Smokey Chilli Paneer",
        "subtitle": "Indulge in our spicy chilli panner flavor",
        "price": "₹350",
        "image": AppImages().topPicksImg,
        "isVeg": true,
      },
      {
        "title": "Smokey Chicken Momo",
        "subtitle": "Indulge in our delicious chicken momo flavor",
        "price": "₹350",
        "image": AppImages().foodItemOne,
        "isVeg": false,
      },
      {
        "title": "Pepper Sriracha Fish",
        "subtitle": "Steamed fish glazed in spicy sriracha sauce",
        "price": "₹420",
        "image": AppImages().foodItemTwo,
        "isVeg": false,
      },
    ];

    return Scaffold(
      backgroundColor: background,
      floatingActionButton: const GlobalCartButton(horizontalMargin: 16),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Obx(() {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        orangeGradientStart,
                        orangeGradientEnd,
                        orangeGradientStart,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: black.withValues(alpha: 0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages().locationIcon,
                                    width: 24,
                                    height: 24,
                                    color: white,
                                  ),
                                  const SizedBox(width: 2),
                                  const Text(
                                    "Home",
                                    style: TextStyle(
                                      fontFamily: natoSemiBold,
                                      fontSize: 16,
                                      color: white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "  Kolkata, westbengal, India",
                                style: TextStyle(
                                  fontFamily: natoRegular,
                                  fontSize: 12,
                                  color: white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(7),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: white,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              AppImages().discountIcon,
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        hintText: "Search for dishes",
                        textEditingController: controller.searchController,
                        keyboardType: TextInputType.webSearch,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Image.asset(
                          AppImages().searchIcon,
                          scale: 2.5,
                        ),
                      ),
                    ],
                  ),
                ),
                controller.isSearchEmpty.value
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const CarouselSlider(),
                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "List of category",
                                  style: TextStyle(
                                    fontFamily: natoSemiBold,
                                    fontSize: 18,
                                    color: black,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      AppImages().timerIcon,
                                      width: 16,
                                      height: 16,
                                      color: charcoalGray,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "34-39 mins",
                                      style: TextStyle(
                                        fontFamily: natoMedium,
                                        fontSize: 13,
                                        color: charcoalGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: categories.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 5,
                                    crossAxisSpacing: 5,
                                    childAspectRatio: 0.90,
                                  ),
                              itemBuilder: (context, index) {
                                final item = categories[index];
                                return InkWell(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    Future.delayed(
                                      Duration(milliseconds: 500),
                                      () {
                                        Get.toNamed(Routes.outletScreen);
                                      },
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 75,
                                        height: 75,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: cardShadow,
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: ClipOval(
                                              child: Image.asset(
                                                item["image"]!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item["name"]!,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: natoMedium,
                                          fontSize: 11,
                                          color: charcoalGray,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Top Picks",
                              style: TextStyle(
                                fontFamily: natoSemiBold,
                                fontSize: 18,
                                color: black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(left: 16, right: 4),
                            child: Row(
                              children: topPicks.map((item) {
                                return Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.70,
                                  margin: const EdgeInsets.only(
                                    right: 12,
                                    bottom: 12,
                                    top: 4,
                                    left: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: cardShadow,
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(12),
                                                ),
                                            child: Image.asset(
                                              item["image"],
                                              height: 110,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Image.asset(
                                              item["isVeg"]
                                                  ? AppImages().vegIcon
                                                  : AppImages().nonVegIcon,
                                              width: 18,
                                              height: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item["title"],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontFamily: natoSemiBold,
                                                fontSize: 13,
                                                color: black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item["subtitle"],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: natoRegular,
                                                fontSize: 10,
                                                color: charcoalGray.withValues(
                                                  alpha: 0.8,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  item["price"],
                                                  style: const TextStyle(
                                                    fontFamily: natoBold,
                                                    fontSize: 14,
                                                    color: black,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {},
                                                  child: Container(
                                                    height: 26,
                                                    width: 55,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: white,
                                                      border: Border.all(
                                                        color: orange,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      "Add",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            natoSemiBold,
                                                        fontSize: 11,
                                                        color: orange,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: Column(
                          children: controller.categories
                              .map((category) => _buildFoodItemCard(category))
                              .toList(),
                        ),
                      ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFoodItemCard(FoodItem item) {
    return GestureDetector(
      onTap: () {
        FoodItemDetailsBottomSheet.show(Get.context!, foodItem: item);
      },
      child: Container(
        color: white,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Details (Left)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Veg / Non-Veg Indicator
                      Image.asset(
                        item.isVeg
                            ? AppImages().vegIcon
                            : AppImages().nonVegIcon,
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(height: 6),

                      // Item Name
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: black,
                          fontSize: 16,
                          fontFamily: natoBold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Item Description
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: charcoalGray,
                          fontSize: 13,
                          fontFamily: natoRegular,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price & Strikethrough Discount Price
                      Row(
                        children: [
                          Text(
                            "₹${item.price.toInt()}",
                            style: const TextStyle(
                              color: black,
                              fontSize: 15,
                              fontFamily: natoBold,
                            ),
                          ),
                          if (item.originalPrice != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              "₹${item.originalPrice!.toInt()}",
                              style: const TextStyle(
                                color: charcoalGray,
                                fontSize: 15,
                                fontFamily: natoRegular,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Customization text
                      Text(
                        item.customization,
                        style: const TextStyle(
                          color: charcoalGray,
                          fontSize: 12,
                          fontFamily: natoRegular,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Read More Link
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          "Read More",
                          style: TextStyle(
                            color: charcoalGray,
                            fontSize: 12,
                            fontFamily: natoMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Item Image & Floating Add Button (Right)
                Column(
                  children: [
                    SizedBox(
                      height: 128,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Food Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              item.image,
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // Add Button (Overlapping)
                          Positioned(
                            bottom: 0,
                            child: InkWell(
                              onTap: () {
                                Get.find<CartController>().addItem(
                                  id: item.id,
                                  name: item.name,
                                  price: item.price,
                                  image: item.image,
                                  isVeg: item.isVeg,
                                );
                              },
                              child: Container(
                                width: 70,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: orange,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: cardShadow,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  "Add",
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 14,
                                    fontFamily: natoBold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (item.hasCustomise)
                      const Text(
                        "Customise",
                        style: TextStyle(
                          color: charcoalGray,
                          fontSize: 11,
                          fontFamily: natoRegular,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: borderGray),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/accountAccessScreen/account_access_screen_controller.dart';
import 'package:momos/screens/profileScreen/profile_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';

// Reusable List Item for clean architecture
class _ProfileListItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileListItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Image.asset(icon, width: 22, height: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: black,
                    fontSize: 15,
                    fontFamily: natoMedium,
                  ),
                ),
              ),
              Image.asset(
                AppImages().rightArrowIcon,
                width: 12,
                height: 12,
                color: charcoalGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends GetView<ProfileScreenController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();

    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            color: white,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 16,
            ),
            child: const Text(
              "My Profile",
              style: TextStyle(
                color: black,
                fontSize: 22,
                fontFamily: natoBold,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: borderGray),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Info Card
                    _buildCard(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Avatar Image
                              ClipOval(
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      AppImages().profileIcon,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Name and Phone number
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Neha Verma",
                                      style: TextStyle(
                                        color: black,
                                        fontSize: 18,
                                        fontFamily: natoBold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "+91 123456789",
                                      style: TextStyle(
                                        color: charcoalGray,
                                        fontSize: 13,
                                        fontFamily: natoRegular,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Edit Icon
                              GestureDetector(
                                onTap: () =>
                                    Get.toNamed(Routes.editProfileScreen),
                                child: Image.asset(
                                  AppImages().editIcon,
                                  width: 20,
                                  height: 20,
                                  color: charcoalGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Wallet Balance Card
                    _buildCard(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "WALLET BALANCE",
                                    style: TextStyle(
                                      color: black,
                                      fontSize: 12,
                                      fontFamily: dmBold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "₹42.50",
                                    style: TextStyle(
                                      color: black,
                                      fontSize: 32,
                                      fontFamily: natoBold,
                                    ),
                                  ),
                                ],
                              ),
                              Image.asset(
                                AppImages().walletIcon,
                                width: 44,
                                height: 44,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Address Book Button Card
                    _buildCard(
                      children: [
                        _ProfileListItem(
                          icon: AppImages().addressIcon,
                          title: "Address Book",
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Order History Section
                    _buildSectionTitle("Order History"),
                    const SizedBox(height: 8),
                    _buildCard(
                      children: [
                        _ProfileListItem(
                          icon: AppImages().orderIcon,
                          title: "My Orders",
                          onTap: () => Get.toNamed(Routes.myOrdersScreen),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: borderGray,
                        ),
                        _ProfileListItem(
                          icon: AppImages().reservationIcon,
                          title: "My Reservations",
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // More Section
                    _buildSectionTitle("More"),
                    const SizedBox(height: 8),
                    _buildCard(
                      children: [
                        _ProfileListItem(
                          icon: AppImages().supportIcon,
                          title: "Support Chat",
                          onTap: () {},
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: borderGray,
                        ),
                        _ProfileListItem(
                          icon: AppImages().aboutIcon,
                          title: "About Us",
                          onTap: () {},
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: borderGray,
                        ),
                        _ProfileListItem(
                          icon: AppImages().faqIcon,
                          title: "FAQ",
                          onTap: () {},
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: borderGray,
                        ),
                        _ProfileListItem(
                          icon: AppImages().logoutIcon,
                          title: "Log out",
                          onTap: () async {
                            final google = GoogleAuthService();
                            await google.signOutWithGoogle();
                            await storage.erase();
                            Get.offAllNamed(Routes.startScreen);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section Header Text Builder
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: charcoalGray,
          fontSize: 14,
          fontFamily: natoMedium,
        ),
      ),
    );
  }

  // Styled Container Wrapper representing the Card
  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: cardShadow,
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

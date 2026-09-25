import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/profileScreen/profile_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/widgets/loading_view.dart';
import 'package:shimmer/shimmer.dart';

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
    return Scaffold(
      backgroundColor: background,
      body: Obx(
        () => controller.mainLoading.value
            ? const Center(child: LoadingDialog())
            : Column(
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
                                          controller.userData['profileImage'] ??
                                              "",
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade100,
                                                  child: Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              },
                                          errorBuilder:
                                              (context, error, stackTrace) {
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
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller.userData['name'] ?? "",
                                              style: TextStyle(
                                                color: black,
                                                fontSize: 18,
                                                fontFamily: natoBold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              controller.userData['email'] !=
                                                      null
                                                  ? (controller.userData['loginType'] ==
                                                            'phone'
                                                        ? "+91 ${controller.userData['phoneNumber']}"
                                                        : controller
                                                              .userData['email'])
                                                  : "",
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
                                        onTap: () => Get.toNamed(
                                          Routes.editProfileScreen,
                                        ),
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
                                InkWell(
                                  onTap: () =>
                                      Get.toNamed(Routes.myWalletScreen),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              "₹${controller.userData['walletAmt'] ?? 0.00}",
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
                                  onTap: () => controller
                                      .showAddressBottomSheet(context),
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
                                  onTap: () =>
                                      Get.toNamed(Routes.myOrdersScreen),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: borderGray,
                                ),
                                _ProfileListItem(
                                  icon: AppImages().reservationIcon,
                                  title: "My Reservations",
                                  onTap: () =>
                                      Get.toNamed(Routes.myReservationsScreen),
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
                                  onTap: () =>
                                      Get.toNamed(Routes.supportChatScreen),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: borderGray,
                                ),
                                _ProfileListItem(
                                  icon: AppImages().aboutIcon,
                                  title: "About Us",
                                  onTap: () =>
                                      Get.toNamed(Routes.aboutUsScreen),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: borderGray,
                                ),
                                _ProfileListItem(
                                  icon: AppImages().faqIcon,
                                  title: "FAQ",
                                  onTap: () => Get.toNamed(Routes.faqScreen),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: borderGray,
                                ),
                                _ProfileListItem(
                                  icon: AppImages().logoutIcon,
                                  title: "Log out",
                                  onTap: () =>
                                      controller.showLogoutBottomSheet(context),
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

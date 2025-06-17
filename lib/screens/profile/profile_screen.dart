import 'package:flutter/material.dart';
import 'package:frontendpatient/core/routes/route_names.dart';
import 'package:frontendpatient/models/auth/update_profile.dart';
import 'package:frontendpatient/models/user/patient_model.dart';
import 'package:frontendpatient/models/user/role.dart';
import 'package:frontendpatient/models/user/user_model.dart';
import 'package:frontendpatient/providers/auth_provider.dart';
import 'package:frontendpatient/screens/profile/widgets/profile_account_info_widget.dart';
import 'package:frontendpatient/screens/profile/widgets/profile_action_buttons_widget.dart';
import 'package:frontendpatient/screens/profile/widgets/profile_error_widget.dart';
import 'package:frontendpatient/screens/profile/widgets/profile_header_widget.dart';
import 'package:frontendpatient/screens/profile/widgets/profile_health_info_widget.dart';
import 'package:frontendpatient/screens/profile/widgets/profile_info_card_widget.dart';
import 'package:frontendpatient/widgets/app_navigation_handler.dart';
import 'package:frontendpatient/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import 'controllers/profile_controller.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppNavigationHandler _navigationHandler = AppNavigationHandler();
  late ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: ProfileAppBar(controller: _controller),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Consumer<ProfileController>(
              builder: (context, profileController, child) {
                if (authProvider.isLoading || profileController.isRefreshing) {
                  return const ProfileLoadingWidget();
                }

                if (authProvider.errorMessage != null) {
                  return ProfileErrorWidget(
                    error: authProvider.errorMessage!,
                    onRetry: () {
                      authProvider.clearError();
                      profileController.refreshProfile(context);
                    },
                  );
                }

                final user = authProvider.currentUser;
                if (user == null) {
                  return const Center(
                    child: Text('Error: No se pudo cargar la información del usuario'),
                  );
                }

                return ProfileContent(
                  user: user,
                  onRefresh: () => profileController.refreshProfile(context),
                  onEdit: () => profileController.showEditDialog(context),
                  onLogout: () => profileController.showLogoutDialog(context),
                );
              },
            );
          },
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: AppNavigationHandler.currentIndex,
          onTap: (index) => AppNavigationHandler.handleNavigation(context, index),
        ),
      ),
    );
  }
}

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ProfileController controller;

  const ProfileAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Mi Perfil'),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => controller.refreshProfile(context),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => controller.showEditDialog(context),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'logout') controller.showLogoutDialog(context);
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Cerrar sesión')
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProfileLoadingWidget extends StatelessWidget {
  const ProfileLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
      ),
    );
  }
}

class ProfileContent extends StatelessWidget {
  final User user;
  final Future<void> Function() onRefresh;
  final VoidCallback onEdit;
  final VoidCallback onLogout;

  const ProfileContent({
    super.key,
    required this.user,
    required this.onRefresh,
    required this.onEdit,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(user: user),
            const SizedBox(height: 20),
            PersonalInfoCard(user: user),
            const SizedBox(height: 16),
            if (user.role == Role.patient) ...[
              HealthInfoCard(patient: user as Patient),
              const SizedBox(height: 16),
            ],
            AccountInfoCard(user: user),
            const SizedBox(height: 20),
            ProfileActionButtons(
              onEdit: onEdit,
              onLogout: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
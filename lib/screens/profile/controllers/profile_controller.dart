import 'package:flutter/material.dart';
import 'package:frontendpatient/core/routes/route_names.dart';
import 'package:frontendpatient/models/user/patient_model.dart';
import 'package:frontendpatient/models/user/role.dart';
import 'package:frontendpatient/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../dialogs/edit_profile_patient_dialog.dart';
import '../profile_screen.dart';
import '../widgets/logout_dialog.dart';
class ProfileController extends ChangeNotifier {
  bool _isRefreshing = false;
  bool _isLoading = false;

  bool get isRefreshing => _isRefreshing;
  bool get isLoading => _isLoading;

  Future<void> refreshProfile(BuildContext context) async {
    _isRefreshing = true;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus();
    } catch (e) {
      // Handle error if needed
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  void showEditDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null || user.role != Role.patient) {
      _showErrorSnackBar(
        context,
        'Error: No se puede editar este perfil',
      );
      return;
    }

    final patient = user as Patient;
    showDialog(
      context: context,
      builder: (BuildContext context) => EditPatientProfileDialog(patient: patient),
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => LogoutDialog(),
    );
  }

  Future<void> logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
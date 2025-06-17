

import '../../../models/user/patient_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/app_navigation_handler.dart';
import '../controllers/edit_profile_controller.dart';
import '../widgets/edit_profile_header.dart';

class EditPatientProfileDialog extends StatefulWidget {
  final Patient patient;

  const EditPatientProfileDialog({super.key, required this.patient});

  @override
  State<EditPatientProfileDialog> createState() => _EditPatientProfileDialogState();
}

class _EditPatientProfileDialogState extends State<EditPatientProfileDialog> {
  late EditProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = EditProfileController();
    controller.initializeControllers(widget.patient);
    AppNavigationHandler.setCurrentIndex(3);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<EditProfileController>(
        builder: (context, controller, child) {
          return Dialog(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EditProfileHeader(
                      isLoading: controller.isLoading,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                    const Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: EditProfileForm(controller: controller),
                      ),
                    ),
                    const SizedBox(height: 16),
                    EditProfileActions(
                      isLoading: controller.isLoading,
                      onCancel: () => Navigator.of(context).pop(),
                      onSave: () => controller.saveProfile(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
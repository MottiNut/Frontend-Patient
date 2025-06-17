import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/edit_profile_controller.dart';
import '../controllers/profile_controller.dart';
import '../utils/profile_utils.dart';

class EditProfileHeader extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onClose;

  const EditProfileHeader({
    super.key,
    required this.isLoading,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Editar Perfil',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.orange.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: isLoading ? null : onClose,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class EditProfileForm extends StatelessWidget {
  final EditProfileController controller;

  const EditProfileForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NameFields(controller: controller),
        const SizedBox(height: 16),
        PhoneField(controller: controller),
        const SizedBox(height: 16),
        PhysicalMeasurementsFields(controller: controller),
        const SizedBox(height: 16),
        GenderDropdown(controller: controller),
        const SizedBox(height: 16),
        MedicalConditionSwitch(controller: controller),
        const SizedBox(height: 16),
        MedicalInfoFields(controller: controller),
        const SizedBox(height: 16),
        EmergencyContactField(controller: controller),
      ],
    );
  }
}

class NameFields extends StatelessWidget {
  final EditProfileController controller;

  const NameFields({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller.firstNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) => ProfileUtils.validateRequired(value, 'Nombre'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: controller.lastNameController,
            decoration: const InputDecoration(
              labelText: 'Apellido',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) => ProfileUtils.validateRequired(value, 'Apellido'),
          ),
        ),
      ],
    );
  }
}

class PhoneField extends StatelessWidget {
  final EditProfileController controller;

  const PhoneField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller.phoneController,
      decoration: const InputDecoration(
        labelText: 'Teléfono',
        prefixIcon: Icon(Icons.phone),
      ),
      keyboardType: TextInputType.phone,
    );
  }
}

class PhysicalMeasurementsFields extends StatelessWidget {
  final EditProfileController controller;

  const PhysicalMeasurementsFields({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller.heightController,
            decoration: const InputDecoration(
              labelText: 'Altura (cm)',
              prefixIcon: Icon(Icons.height),
            ),
            keyboardType: TextInputType.number,
            validator: ProfileUtils.validateHeight,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: controller.weightController,
            decoration: const InputDecoration(
              labelText: 'Peso (kg)',
              prefixIcon: Icon(Icons.monitor_weight),
            ),
            keyboardType: TextInputType.number,
            validator: ProfileUtils.validateWeight,
          ),
        ),
      ],
    );
  }
}

class GenderDropdown extends StatelessWidget {
  final EditProfileController controller;

  const GenderDropdown({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfileController>(
      builder: (context, controller, child) {
        return DropdownButtonFormField<String>(
          value: controller.selectedGender,
          decoration: const InputDecoration(
            labelText: 'Género',
            prefixIcon: Icon(Icons.person_outline),
          ),
          items: controller.genderOptions.map((gender) => DropdownMenuItem(
            value: gender,
            child: Text(gender),
          )).toList(),
          onChanged: controller.setGender,
        );
      },
    );
  }
}

class MedicalConditionSwitch extends StatelessWidget {
  final EditProfileController controller;

  const MedicalConditionSwitch({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfileController>(
      builder: (context, controller, child) {
        return SwitchListTile(
          title: const Text('¿Tiene condición médica?'),
          value: controller.hasMedicalCondition,
          onChanged: controller.setMedicalCondition,
          activeColor: Colors.orange,
        );
      },
    );
  }
}

class MedicalInfoFields extends StatelessWidget {
  final EditProfileController controller;

  const MedicalInfoFields({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller.chronicDiseaseController,
          decoration: const InputDecoration(
            labelText: 'Enfermedad Crónica',
            prefixIcon: Icon(Icons.local_hospital),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controller.allergiesController,
          decoration: const InputDecoration(
            labelText: 'Alergias',
            prefixIcon: Icon(Icons.warning),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controller.dietaryPreferencesController,
          decoration: const InputDecoration(
            labelText: 'Preferencias Dietéticas',
            prefixIcon: Icon(Icons.restaurant),
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}

class EmergencyContactField extends StatelessWidget {
  final EditProfileController controller;

  const EmergencyContactField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller.emergencyContactController,
      decoration: const InputDecoration(
        labelText: 'Contacto de Emergencia',
        prefixIcon: Icon(Icons.emergency),
      ),
      keyboardType: TextInputType.phone,
    );
  }
}

class EditProfileActions extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const EditProfileActions({
    super.key,
    required this.isLoading,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            )
                : const Text('Guardar'),
          ),
        ),
      ],
    );
  }
}
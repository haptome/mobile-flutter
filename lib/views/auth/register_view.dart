// Purpose: Registration view
// Author: haptome H.
// Linked Spec Section: FR01-FR03

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('register'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Phone field
            TextField(
              decoration: InputDecoration(
                labelText: 'phone'.tr,
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) => controller.phone.value = value,
            ),
            const SizedBox(height: 16),
            // Full name field
            TextField(
              decoration: InputDecoration(
                labelText: 'full_name'.tr,
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => controller.fullName.value = value,
            ),
            const SizedBox(height: 16),
            // Password field (optional)
            Obx(
              () => TextField(
                decoration: InputDecoration(
                  labelText: 'password'.tr + ' (${'optional'.tr})',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
                onChanged: (value) => controller.password.value = value,
              ),
            ),
            const SizedBox(height: 24),
            // Register button
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.register(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : Text('register'.tr),
              ),
            ),
            const SizedBox(height: 16),
            // Login link
            TextButton(
              onPressed: () => Get.back(),
              child: Text('login'.tr),
            ),
          ],
        ),
      ),
    );
  }
}


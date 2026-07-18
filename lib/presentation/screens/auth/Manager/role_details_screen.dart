import 'package:flutter/material.dart';

import '../detail_registration_form/retailer_form.dart';
import '../detail_registration_form/wholesaler_form.dart';

class RoleDetailsScreen extends StatefulWidget {
  final String role;

  const RoleDetailsScreen({super.key, required this.role});

  @override
  State<RoleDetailsScreen> createState() => _RoleDetailsScreenState();
}

class _RoleDetailsScreenState extends State<RoleDetailsScreen> {
  late String selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.role;
  }

  Widget getForm() {
    if (selectedRole == "retailer") {
      return const RetailerForm();
    } else if (selectedRole == "wholesaler") {
      return const WholesalerForm();
    } else {
      return const Center(
        child: Text("Invalid role"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Role: ${selectedRole.toUpperCase()}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: getForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
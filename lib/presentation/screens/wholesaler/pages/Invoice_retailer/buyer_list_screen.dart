import 'package:drug_tracking_system/core/services/api_service/invoice_api.dart';
import 'package:flutter/material.dart';
import 'invoice_list_screen.dart';

class BuyerListScreen extends StatefulWidget {
  const BuyerListScreen({super.key});

  @override
  State<BuyerListScreen> createState() => _BuyerListScreenState();
}

class _BuyerListScreenState extends State<BuyerListScreen> {
  List<Map<String, dynamic>> buyers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBuyers();
  }

  Future<void> loadBuyers() async {
    try {
      final data = await InvoiceApi.getBuyers();
      if (!mounted) return;
      setState(() {
        buyers = data.map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e);
          return {
            "user_id": int.tryParse(m["user_id"]?.toString() ?? "0") ?? 0,
            "name": m["name"]?.toString() ?? "",
          };
        }).where((e) => e["user_id"] != 0).toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception:", ""))),
      );
    }
  }

  Widget _card(Map<String, dynamic> b) {
    final int id = b["user_id"];
    final String name = b["name"];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.deepPurple),
        title: Text(name),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoiceListScreen(
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Retailer"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buyers.isEmpty
          ? const Center(child: Text("No Buyers Found"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: buyers.length,
        itemBuilder: (context, i) => _card(buyers[i]),
      ),
    );
  }
}
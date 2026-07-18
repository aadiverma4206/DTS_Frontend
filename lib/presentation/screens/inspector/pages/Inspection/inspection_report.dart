import 'package:flutter/material.dart';

class InspectionReportScreen extends StatelessWidget {
  final Map<String, dynamic> inspection;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> checks;

  const InspectionReportScreen({
    super.key,
    required this.inspection,
    required this.items,
    required this.checks,
  });

  Color statusColor(String status) {
    switch (status) {
      case "verified":
        return Colors.green;
      case "discrepancy":
        return Colors.red;
      case "in_progress":
        return Colors.blue;
      case "completed":
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    try {
      final d = DateTime.parse(date);
      return "${d.day}/${d.month}/${d.year}";
    } catch (_) {
      return date;
    }
  }

  Widget header() {
    final status = inspection["status"] ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Inspection Report",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text("Target: ${inspection["target_name"] ?? ""}"),
        Text("Inspector: ${inspection["inspector_name"] ?? ""}"),
        Text("Date: ${formatDate(inspection["inspection_date"])}"),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor(status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor(status)),
          ),
        ),
        const SizedBox(height: 8),
        Text("System Total: ${inspection["total_system_qty"] ?? 0}"),
        Text("Physical Total: ${inspection["total_physical_qty"] ?? 0}"),
      ],
    );
  }

  Widget itemTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "Items Verification",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("Drug")),
              DataColumn(label: Text("Batch")),
              DataColumn(label: Text("System")),
              DataColumn(label: Text("Physical")),
              DataColumn(label: Text("Status")),
            ],
            rows: items.map((item) {
              final mismatch = item["status"] == "mismatch";

              return DataRow(cells: [
                DataCell(Text(item["drug_name"] ?? "")),
                DataCell(Text(item["batch_no"] ?? "")),
                DataCell(Text("${item["system_qty"] ?? 0}")),
                DataCell(Text("${item["physical_qty"] ?? 0}")),
                DataCell(
                  Text(
                    item["status"] ?? "",
                    style: TextStyle(
                      color: mismatch ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget checksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "Checklist",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...checks.map((c) {
          final value = c["check_value"] ?? "no";
          final isYes = value == "yes" || value == "pass";

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isYes ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isYes ? Icons.check : Icons.close,
                  color: isYes ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(c["check_name"] ?? "")),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget remarksSection() {
    final remarks = inspection["remarks"];

    if (remarks == null || remarks.toString().isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "Remarks",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(remarks),
        ),
      ],
    );
  }

  Widget printButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Print/PDF coming soon")),
          );
        },
        icon: const Icon(Icons.print),
        label: const Text("Download / Print"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.deepPurple,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inspection Report"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            header(),
            itemTable(),
            checksSection(),
            remarksSection(),
            const SizedBox(height: 20),
            printButton(context),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class InspectionItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const InspectionItemCard({
    super.key,
    required this.item,
  });

  int toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final int systemQty = toInt(item["system_qty"]);
    final int physicalQty = toInt(item["physical_qty"]);
    final int difference = physicalQty - systemQty;

    final bool mismatch = (item["status"] ?? "") == "mismatch"
        ? true
        : systemQty != physicalQty;

    final String drugName =
    (item["drug_name"] ?? "").toString().isNotEmpty
        ? item["drug_name"]
        : "Unknown Drug";

    final String batchNo =
    (item["batch_no"] ?? "").toString().isNotEmpty
        ? item["batch_no"]
        : "-";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: mismatch ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: mismatch ? Colors.red : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: mismatch ? Colors.red : Colors.green,
            child: Icon(
              mismatch ? Icons.warning : Icons.check,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drugName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text("Batch: $batchNo"),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "System: $systemQty",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Physical: $physicalQty",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Difference: $difference",
                  style: TextStyle(
                    color: mismatch ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (mismatch)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      "Mismatch detected",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
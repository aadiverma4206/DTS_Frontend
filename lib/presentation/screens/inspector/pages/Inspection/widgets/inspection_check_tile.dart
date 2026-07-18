import 'package:flutter/material.dart';

class InspectionCheckTile extends StatelessWidget {
  final String title;
  final String value;
  final Function(String) onChanged;

  const InspectionCheckTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  bool get isPositive => value == "yes" || value == "pass";

  @override
  Widget build(BuildContext context) {
    final positive = isPositive;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: positive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: positive ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: positive ? Colors.green : Colors.red,
            child: Icon(
              positive ? Icons.check : Icons.close,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title.isNotEmpty ? title : "Check",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => onChanged("yes"),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: positive ? Colors.green : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Yes",
                    style: TextStyle(
                      color: positive ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged("no"),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: !positive ? Colors.red : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: !positive ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
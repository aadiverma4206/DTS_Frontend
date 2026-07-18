// // import 'dart:io';
// //
// // import 'package:drug_tracking_system/core/services/api_service/stock_api.dart';
// // import 'package:excel/excel.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:pdf/widgets.dart' as pw;
// // import 'package:printing/printing.dart';
// //
// // class StockHistoryScreen extends StatefulWidget {
// //   const StockHistoryScreen({super.key});
// //
// //   @override
// //   State<StockHistoryScreen> createState() => _StockHistoryScreenState();
// // }
// //
// // class _StockHistoryScreenState extends State<StockHistoryScreen> {
// //   List<Map<String, dynamic>> movements = [];
// //
// //   bool isLoading = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     loadHistory();
// //   }
// //
// //   Future<void> loadHistory() async {
// //     try {
// //       final data = await StockApi.getStockHistory();
// //
// //       if (!mounted) return;
// //
// //       final mapped = data.map<Map<String, dynamic>>((e) {
// //         final m = Map<String, dynamic>.from(e);
// //
// //         return {
// //           "drug_name": m["drug_name"]?.toString() ?? "",
// //
// //           "batch_no": m["batch_no"]?.toString() ?? "",
// //
// //           "change_qty": int.tryParse(m["change_qty"]?.toString() ?? "0") ?? 0,
// //
// //           "movement_type": m["movement_type"]?.toString() ?? "",
// //
// //           "created_at": m["created_at"]?.toString() ?? "",
// //
// //           "manufacturer": m["manufacturer_name"]?.toString() ?? "",
// //
// //           "from": m["sender_name"]?.toString() ?? "",
// //
// //           "to": m["receiver_name"]?.toString() ?? "",
// //         };
// //       }).toList();
// //
// //       setState(() {
// //         movements = mapped;
// //         isLoading = false;
// //       });
// //     } catch (e) {
// //       if (!mounted) return;
// //
// //       setState(() {
// //         isLoading = false;
// //       });
// //
// //       Get.snackbar(
// //         "Error",
// //         e.toString().replaceAll("Exception:", "").trim(),
// //         snackPosition: SnackPosition.BOTTOM,
// //         backgroundColor: Colors.red.shade400,
// //         colorText: Colors.white,
// //         margin: const EdgeInsets.all(12),
// //         duration: const Duration(seconds: 2),
// //       );
// //     }
// //   }
// //
// //   Future<void> exportPDF() async {
// //     try {
// //       final pdf = pw.Document();
// //
// //       pdf.addPage(
// //         pw.Page(
// //           build: (context) {
// //             return pw.Table.fromTextArray(
// //               headers: ["Drug", "Batch", "Qty", "Type", "From", "To", "Date"],
// //
// //               data: movements.map((e) {
// //                 return [
// //                   e["drug_name"],
// //                   e["batch_no"],
// //                   e["change_qty"].toString(),
// //                   e["movement_type"],
// //                   e["from"],
// //                   e["to"],
// //                   e["created_at"],
// //                 ];
// //               }).toList(),
// //             );
// //           },
// //         ),
// //       );
// //
// //       await Printing.layoutPdf(onLayout: (format) async => pdf.save());
// //     } catch (e) {
// //       showMsg("Failed to export PDF");
// //     }
// //   }
// //
// //   Future<void> exportExcel() async {
// //     try {
// //       final excel = Excel.createExcel();
// //
// //       final sheet = excel['Sheet1'];
// //
// //       sheet.appendRow([
// //         TextCellValue("Drug"),
// //         TextCellValue("Batch"),
// //         TextCellValue("Qty"),
// //         TextCellValue("Type"),
// //         TextCellValue("From"),
// //         TextCellValue("To"),
// //         TextCellValue("Date"),
// //       ]);
// //
// //       for (var e in movements) {
// //         sheet.appendRow([
// //           TextCellValue(e["drug_name"]),
// //
// //           TextCellValue(e["batch_no"]),
// //
// //           IntCellValue(e["change_qty"]),
// //
// //           TextCellValue(e["movement_type"]),
// //
// //           TextCellValue(e["from"]),
// //
// //           TextCellValue(e["to"]),
// //
// //           TextCellValue(e["created_at"]),
// //         ]);
// //       }
// //
// //       final dir = await getApplicationDocumentsDirectory();
// //
// //       final file = File("${dir.path}/stock_history.xlsx");
// //
// //       final bytes = excel.save();
// //
// //       if (bytes != null) {
// //         await file.writeAsBytes(bytes);
// //
// //         showMsg("Excel saved successfully");
// //       }
// //     } catch (e) {
// //       showMsg("Failed to export Excel");
// //     }
// //   }
// //
// //   void showMsg(String msg) {
// //     Get.snackbar(
// //       "Message",
// //       msg,
// //       snackPosition: SnackPosition.BOTTOM,
// //       backgroundColor: Colors.deepPurple,
// //       colorText: Colors.white,
// //       margin: const EdgeInsets.all(12),
// //       duration: const Duration(seconds: 2),
// //     );
// //   }
// //
// //   Widget buildItem(Map<String, dynamic> m) {
// //     final bool isIn = m["movement_type"] == "IN";
// //
// //     return Container(
// //       margin: const EdgeInsets.symmetric(vertical: 8),
// //
// //       padding: const EdgeInsets.all(14),
// //
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(18),
// //
// //         gradient: LinearGradient(
// //           colors: isIn
// //               ? [Colors.green.shade400, Colors.green.shade700]
// //               : [Colors.red.shade400, Colors.red.shade700],
// //         ),
// //
// //         boxShadow: [
// //           BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
// //         ],
// //       ),
// //
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //
// //         children: [
// //           Row(
// //             children: [
// //               CircleAvatar(
// //                 backgroundColor: Colors.white,
// //
// //                 child: Icon(
// //                   isIn ? Icons.arrow_downward : Icons.arrow_upward,
// //
// //                   color: isIn ? Colors.green : Colors.red,
// //                 ),
// //               ),
// //
// //               const SizedBox(width: 10),
// //
// //               Expanded(
// //                 child: Text(
// //                   m["drug_name"],
// //
// //                   maxLines: 1,
// //
// //                   overflow: TextOverflow.ellipsis,
// //
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //
// //                     fontWeight: FontWeight.bold,
// //
// //                     fontSize: 16,
// //                   ),
// //                 ),
// //               ),
// //
// //               Text(
// //                 isIn ? "+${m["change_qty"]}" : "-${m["change_qty"]}",
// //
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //
// //                   fontWeight: FontWeight.bold,
// //
// //                   fontSize: 16,
// //                 ),
// //               ),
// //             ],
// //           ),
// //
// //           const SizedBox(height: 10),
// //
// //           Text(
// //             "Batch: ${m["batch_no"]}",
// //
// //             style: const TextStyle(color: Colors.white70),
// //           ),
// //
// //           Text(
// //             "Manufacturer: ${m["manufacturer"]}",
// //
// //             style: const TextStyle(color: Colors.white70),
// //           ),
// //
// //           if (m["from"].toString().isNotEmpty)
// //             Text(
// //               "From: ${m["from"]}",
// //
// //               style: const TextStyle(color: Colors.white70),
// //             ),
// //
// //           if (m["to"].toString().isNotEmpty)
// //             Text(
// //               "To: ${m["to"]}",
// //
// //               style: const TextStyle(color: Colors.white70),
// //             ),
// //
// //           const SizedBox(height: 6),
// //
// //           Text(
// //             m["created_at"],
// //
// //             style: const TextStyle(color: Colors.white54, fontSize: 12),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final width = MediaQuery.of(context).size.width;
// //
// //     final bool isDesktop = width > 900;
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text(
// //           "Stock History",
// //
// //           style: TextStyle(fontSize: 22, color: Colors.white),
// //         ),
// //
// //         centerTitle: true,
// //
// //         backgroundColor: Colors.deepPurple,
// //
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
// //
// //             onPressed: exportPDF,
// //           ),
// //
// //           IconButton(
// //             icon: const Icon(Icons.table_chart, color: Colors.white),
// //
// //             onPressed: exportExcel,
// //           ),
// //         ],
// //       ),
// //
// //       body: Container(
// //         width: double.infinity,
// //
// //         padding: EdgeInsets.symmetric(
// //           horizontal: isDesktop
// //               ? width * 0.2
// //               : width > 600
// //               ? width * 0.12
// //               : 16,
// //
// //           vertical: 16,
// //         ),
// //
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             colors: [Colors.white, Colors.white],
// //
// //             begin: Alignment.topCenter,
// //
// //             end: Alignment.bottomCenter,
// //           ),
// //         ),
// //
// //         child: isLoading
// //             ? const Center(
// //                 child: CircularProgressIndicator(color: Colors.deepPurple),
// //               )
// //             : movements.isEmpty
// //             ? const Center(
// //                 child: Text(
// //                   "No Stock History",
// //
// //                   style: TextStyle(
// //                     color: Colors.black87,
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               )
// //             : RefreshIndicator(
// //                 color: Colors.deepPurple,
// //
// //                 onRefresh: loadHistory,
// //
// //                 child: ListView.builder(
// //                   physics: const AlwaysScrollableScrollPhysics(),
// //
// //                   itemCount: movements.length,
// //
// //                   itemBuilder: (context, index) {
// //                     return buildItem(movements[index]);
// //                   },
// //                 ),
// //               ),
// //       ),
// //     );
// //   }
// // }
import 'dart:io';
import 'package:drug_tracking_system/core/services/api_service/stock_api.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:excel/excel.dart' as ex;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

enum StockFilter { all, receive, supply }

class StockHistoryScreen extends StatefulWidget {
  const StockHistoryScreen({super.key});
  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> movements = [];
  List<Map<String, dynamic>> filteredMovements = [];
  bool isLoading = true;
  StockFilter activeFilter = StockFilter.all;
  final TextEditingController searchController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  static const Color _bg = Color(0xFFF4F2FB);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _purple = Color(0xFF8640F6); // for app bar
  static const Color _purpleSoft = Color(0xFFEDE8FB);
  static const Color _receiveColor = Color(0xFF00B87A);
  static const Color _supplyColor = Color(0xFFE8455A);
  static const Color _receiveBg = Color(0xFFE6F9F2);
  static const Color _supplyBg = Color(0xFFFDECEF);
  static const Color _textPrimary = Color(0xFF1A1035);
  static const Color _textSecondary = Color(0xFF7B7494);
  static const Color _divider = Color(0xFFE5E0F5);
  static const Color _cardShadow = Color(0x14602EE8);
  String formatDateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "-";
    }
    try {
      final date = DateTime.parse(value).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(date.year, date.month, date.day);
      final diff = today.difference(target).inDays;
      if (diff == 0) {
        return "Today, ${DateFormat('hh:mm a').format(date)}";
      }
      if (diff == 1) {
        return "Yesterday, ${DateFormat('hh:mm a').format(date)}";
      }
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return value;
    }
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    searchController.addListener(_applyFilters);
    loadHistory();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadHistory() async {
    setState(() => isLoading = true);
    try {
      final data = await StockApi.getStockHistory();
      if (!mounted) return;
      final mapped = data.map<Map<String, dynamic>>((e) {
        final m = Map<String, dynamic>.from(e);
        return {
          "drug_name": m["drug_name"]?.toString() ?? "",
          "batch_no": m["batch_no"]?.toString() ?? "",
          "change_qty": int.tryParse(m["change_qty"]?.toString() ?? "0") ?? 0,
          "movement_type": m["movement_type"]?.toString() ?? "",
          "created_at": m["created_at"]?.toString() ?? "",
          "manufacturer": m["manufacturer_name"]?.toString() ?? "",
          "from": m["sender_name"]?.toString() ?? "",
          "to": m["receiver_name"]?.toString() ?? "",
        };
      }).toList();
      setState(() {
        movements = mapped;
        isLoading = false;
      });
      _applyFilters();
      _fadeController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      Get.snackbar(
        "Error",
        e.toString().replaceAll("Exception:", "").trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _supplyColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        borderRadius: 12,
      );
    }
  }

  void _applyFilters() {
    final query = searchController.text.toLowerCase().trim();
    setState(() {
      filteredMovements = movements.where((m) {
        final matchesFilter =
            activeFilter == StockFilter.all ||
            (activeFilter == StockFilter.receive &&
                m["movement_type"] == "IN") ||
            (activeFilter == StockFilter.supply && m["movement_type"] == "OUT");
        final matchesSearch =
            query.isEmpty ||
            m["drug_name"].toString().toLowerCase().contains(query) ||
            m["batch_no"].toString().toLowerCase().contains(query) ||
            m["from"].toString().toLowerCase().contains(query) ||
            m["to"].toString().toLowerCase().contains(query) ||
            m["manufacturer"].toString().toLowerCase().contains(query);
        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  void _setFilter(StockFilter filter) {
    setState(() => activeFilter = filter);
    _applyFilters();
  }

  int get receiveCount =>
      movements.where((m) => m["movement_type"] == "IN").length;
  int get supplyCount =>
      movements.where((m) => m["movement_type"] == "OUT").length;
  Future<void> exportPDF() async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Table.fromTextArray(
            headers: ["Drug", "Batch", "Qty", "Type", "From", "To", "Date"],
            data: filteredMovements
                .map(
                  (e) => [
                    e["drug_name"],
                    e["batch_no"],
                    e["change_qty"].toString(),
                    e["movement_type"],
                    e["from"],
                    e["to"],
                    formatDateTime(e["created_at"]),
                  ],
                )
                .toList(),
          ),
        ),
      );
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      _showMsg("Failed to export PDF");
    }
  }

  Future<void> exportExcel() async {
    try {
      final excelDoc = ex.Excel.createExcel();
      final sheet = excelDoc['Sheet1'];
      sheet.appendRow([
        TextCellValue("Drug"),
        TextCellValue("Batch"),
        TextCellValue("Qty"),
        TextCellValue("Type"),
        TextCellValue("From"),
        TextCellValue("To"),
        TextCellValue("Date"),
      ]);
      for (var e in filteredMovements) {
        sheet.appendRow([
          TextCellValue(e["drug_name"]),
          TextCellValue(e["batch_no"]),
          IntCellValue(e["change_qty"]),
          TextCellValue(e["movement_type"]),
          TextCellValue(e["from"]),
          TextCellValue(e["to"]),
          TextCellValue(formatDateTime(e["created_at"])),
        ]);
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/stock_history.xlsx");
      final bytes = excelDoc.save();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        _showMsg("Excel saved to Documents");
      }
    } catch (e) {
      _showMsg("Failed to export Excel");
    }
  }

  void _showMsg(String msg) {
    Get.snackbar(
      "Notice",
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _purple,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      borderRadius: 12,
    );
  }

  Widget _buildSummaryCard(
    String label,
    int count,
    Color color,
    Color bgColor,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.18), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _cardShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading
                    ? _BlinkingSkeleton(
                        child: Container(
                          width: 36,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _divider,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      )
                    : Text(
                        count.toString(),
                        style: GoogleFonts.spaceGrotesk(
                          color: _textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: _textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    StockFilter filter,
    Color activeColor,
    Color activeBg,
  ) {
    final bool selected = activeFilter == filter;
    return GestureDetector(
      onTap: () => _setFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? activeColor : _surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? activeColor : _divider,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: selected ? Colors.white : _textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildMovementCard(Map<String, dynamic> m) {
    final bool isIn = m["movement_type"] == "IN";
    final Color accent = isIn ? _receiveColor : _supplyColor;
    final Color cardAccentBg = isIn ? _receiveBg : _supplyBg;
    final IconData dirIcon = isIn ? Icons.south_rounded : Icons.north_rounded;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: _cardShadow,
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cardAccentBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(dirIcon, color: accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m["drug_name"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            color: _textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Batch: ${m["batch_no"]}",
                          style: GoogleFonts.inter(
                            color: _textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isIn ? "+${m["change_qty"]}" : "-${m["change_qty"]}",
                        style: GoogleFonts.spaceGrotesk(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isIn ? "RECEIVE" : "SUPPLY",
                          style: GoogleFonts.inter(
                            color: accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                children: [
                  if (m["manufacturer"].toString().isNotEmpty)
                    _buildDetailRow(
                      Icons.business_rounded,
                      "Manufacturer",
                      m["manufacturer"],
                      _purple,
                    ),
                  if (m["from"].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.send_rounded,
                      "From",
                      m["from"],
                      _receiveColor,
                    ),
                  ],
                  if (m["to"].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.location_on_rounded,
                      "To",
                      m["to"],
                      _supplyColor,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: _textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatDateTime(m["created_at"]),
                        style: GoogleFonts.inter(
                          color: _textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor.withOpacity(0.75)),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: GoogleFonts.inter(
            color: _textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovementSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: _cardShadow,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _divider,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 15,
                        decoration: BoxDecoration(
                          color: _divider,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _divider,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 40,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 50,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 120,
                      height: 13,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 150,
                      height: 13,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return _BlinkingSkeleton(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (_, __) => _buildMovementSkeletonCard(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _purpleSoft,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: _purple.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No records found",
              style: GoogleFonts.spaceGrotesk(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Try adjusting your search or filter",
              style: GoogleFonts.inter(color: _textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double horizontalPad = width > 900
        ? width * 0.18
        : width > 600
        ? width * 0.08
        : 16;
    final bool canPop = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          "Stock History",
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Export PDF",
            icon: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: exportPDF,
          ),
          IconButton(
            tooltip: "Export Excel",
            icon: const Icon(
              Icons.table_chart_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: exportExcel,
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Container(
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: RefreshIndicator(
            color: _purple,
            backgroundColor: _surface,
            onRefresh: loadHistory,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPad,
                      0,
                      horizontalPad,
                      8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildSummaryCard(
                              "Received",
                              receiveCount,
                              _receiveColor,
                              _receiveBg,
                              Icons.south_rounded,
                            ),
                            const SizedBox(width: 12),
                            _buildSummaryCard(
                              "Supplied",
                              supplyCount,
                              _supplyColor,
                              _supplyBg,
                              Icons.north_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _divider, width: 1.2),
                          ),
                          child: TextField(
                            controller: searchController,
                            style: GoogleFonts.inter(
                              color: _textPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  "Search drug, batch, sender, receiver...",
                              hintStyle: GoogleFonts.inter(
                                color: _textSecondary,
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: _purple.withOpacity(0.6),
                                size: 20,
                              ),
                              suffixIcon: searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: _textSecondary,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        searchController.clear();
                                        _applyFilters();
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildFilterChip(
                                "All  (${movements.length})",
                                StockFilter.all,
                                _purple,
                                _purpleSoft,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                "Received  ($receiveCount)",
                                StockFilter.receive,
                                _receiveColor,
                                _receiveBg,
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                "Supplied  ($supplyCount)",
                                StockFilter.supply,
                                _supplyColor,
                                _supplyBg,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(height: 1, color: _divider),
                        const SizedBox(height: 8),
                        Text(
                          "${filteredMovements.length} record${filteredMovements.length != 1 ? "s" : ""}",
                          style: GoogleFonts.inter(
                            color: _textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPad,
                    14,
                    horizontalPad,
                    30,
                  ),
                  sliver: isLoading
                      ? SliverToBoxAdapter(child: _buildSkeletonList())
                      : filteredMovements.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildMovementCard(filteredMovements[index]),
                            childCount: filteredMovements.length,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlinkingSkeleton extends StatefulWidget {
  final Widget child;
  const _BlinkingSkeleton({required this.child});
  @override
  State<_BlinkingSkeleton> createState() => _BlinkingSkeletonState();
}

class _BlinkingSkeletonState extends State<_BlinkingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.35,
        end: 0.85,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

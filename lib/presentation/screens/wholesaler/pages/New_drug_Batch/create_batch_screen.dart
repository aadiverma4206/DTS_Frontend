import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../../../core/services/api_service/api_service.dart';
import '../../../../../core/services/api_service/drug_api.dart';
import '../../../../../core/services/api_service/manufacturer_api.dart';

class CreateBatchScreen extends StatefulWidget {
  const CreateBatchScreen({super.key});
  @override
  State<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends State<CreateBatchScreen> {
  final batchNoController = TextEditingController();
  final mrpController = TextEditingController();
  final purchaseController = TextEditingController();
  final quantityController = TextEditingController();
  final mfgController = TextEditingController();
  final expController = TextEditingController();
  final stockReceiveController = TextEditingController();
  DateTime? mfgDate;
  DateTime? expDate;
  DateTime? stockReceiveDate;
  bool isLoading = false;
  bool isDataLoading = true;
  bool isDrugLoading = false;
  List<Map<String, dynamic>> manufacturers = [];
  List<Map<String, dynamic>> drugs = [];
  int? selectedManufacturerId;
  int? selectedDrugId;
  String selectedManufacturerName = "";
  String selectedDrugName = "";
  static const Color _bg = Color(0xFFF4F2FB);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _purple = Color(0xFF5C35D4);
  static const Color _purpleSoft = Color(0xFFEDE8FB);
  static const Color _purpleBorder = Color(0xFFD4C8F7);
  static const Color _textPrimary = Color(0xFF1A1035);
  static const Color _textSecondary = Color(0xFF7B7494);
  static const Color _error = Color(0xFFE8455A);
  static const Color _success = Color(0xFF00B87A);
  @override
  void initState() {
    super.initState();
    loadManufacturers();
  }

  @override
  void dispose() {
    batchNoController.dispose();
    mrpController.dispose();
    purchaseController.dispose();
    quantityController.dispose();
    mfgController.dispose();
    expController.dispose();
    stockReceiveController.dispose();
    super.dispose();
  }

  Future<void> loadManufacturers() async {
    try {
      final data = await ManufacturerApi.getMyManufacturers();
      if (!mounted) return;
      setState(() {
        manufacturers = List<Map<String, dynamic>>.from(data);
        isDataLoading = false;
      });
    } catch (_) {
      Get.closeAllSnackbars();
      if (!mounted) return;
      setState(() => isDataLoading = false);
      showMsg("Failed to load manufacturers", isError: true);
    }
  }

  Future<void> loadDrugs() async {
    if (selectedManufacturerId == null) return;
    if (mounted) setState(() => isDrugLoading = true);
    try {
      final data = await DrugApi.getDrugsByManufacturer(
        selectedManufacturerId!,
      );
      if (!mounted) return;
      setState(() {
        drugs = List<Map<String, dynamic>>.from(data);
        selectedDrugId = null;
        selectedDrugName = "";
        isDrugLoading = false;
      });
    } catch (_) {
      Get.closeAllSnackbars();
      if (!mounted) return;
      setState(() => isDrugLoading = false);
      showMsg("Failed to load drugs", isError: true);
    }
  }

  Future<void> pickDate({required bool isMfg, bool isStock = false}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    final formatted = DateFormat('yyyy-MM-dd').format(picked);
    setState(() {
      if (isStock) {
        stockReceiveDate = picked;
        stockReceiveController.text = formatted;
      } else if (isMfg) {
        mfgDate = picked;
        mfgController.text = formatted;
      } else {
        expDate = picked;
        expController.text = formatted;
      }
    });
  }

  Future<void> selectManufacturer() async {
    if (!mounted) return;
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchBottomSheet(
        title: "Search Manufacturer",
        items: manufacturers,
        icon: Icons.business,
        labelBuilder: (item) => item["company_name"].toString(),
        filterLogic: (item, query) =>
            item["company_name"].toString().toLowerCase().contains(query),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        selectedManufacturerId = result["manufacturer_id"];
        selectedManufacturerName = result["company_name"];
        selectedDrugId = null;
        selectedDrugName = "";
        drugs.clear();
      });
      await loadDrugs();
    }
  }

  Future<void> selectDrug() async {
    if (selectedManufacturerId == null) {
      Get.closeAllSnackbars();
      showMsg("Please select manufacturer first", isError: true);
      return;
    }
    if (isDrugLoading) {
      Get.closeAllSnackbars();
      showMsg("Loading drugs...", isError: false);
      return;
    }
    if (drugs.isEmpty) await loadDrugs();
    if (drugs.isEmpty) {
      Get.closeAllSnackbars();
      showMsg("No drugs available", isError: true);
      return;
    }
    if (!mounted) return;
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchBottomSheet(
        title: "Search Drug",
        items: drugs,
        icon: Icons.medication,
        labelBuilder: (item) => "${item["drug_name"]} (${item["strength"]})",
        filterLogic: (item, query) {
          final name = item["drug_name"].toString().toLowerCase();
          final strength = item["strength"].toString().toLowerCase();
          return name.contains(query) || strength.contains(query);
        },
      ),
    );
    if (result != null && mounted) {
      setState(() {
        selectedDrugId = result["master_drug_id"];
        selectedDrugName = "${result["drug_name"]} (${result["strength"]})";
      });
    }
  }

  void clearForm() {
    batchNoController.clear();
    mrpController.clear();
    purchaseController.clear();
    quantityController.clear();
    mfgController.clear();
    expController.clear();
    stockReceiveController.clear();
    setState(() {
      mfgDate = null;
      expDate = null;
      stockReceiveDate = null;
      selectedManufacturerId = null;
      selectedManufacturerName = "";
      selectedDrugId = null;
      selectedDrugName = "";
      drugs.clear();
    });
  }

  Future<void> createBatch() async {
    FocusScope.of(context).unfocus();
    if (batchNoController.text.trim().isEmpty ||
        selectedManufacturerId == null ||
        selectedDrugId == null ||
        mfgDate == null ||
        expDate == null ||
        stockReceiveDate == null ||
        mrpController.text.trim().isEmpty ||
        purchaseController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty) {
      Get.closeAllSnackbars();
      showMsg("All fields are required", isError: true);
      return;
    }
    final mrp = double.tryParse(mrpController.text.trim());
    final purchasePrice = double.tryParse(purchaseController.text.trim());
    final quantity = int.tryParse(quantityController.text.trim());
    if (mrp == null || purchasePrice == null || quantity == null) {
      Get.closeAllSnackbars();
      showMsg("Please enter valid numeric values", isError: true);
      return;
    }
    if (quantity <= 0) {
      Get.closeAllSnackbars();
      showMsg("Quantity must be greater than 0", isError: true);
      return;
    }
    if (expDate!.isBefore(mfgDate!) || expDate!.isAtSameMomentAs(mfgDate!)) {
      Get.closeAllSnackbars();
      showMsg("Expiry date must be after manufacture date", isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      final response = await http
          .post(
            Uri.parse("${ApiService.baseUrl}/batches"),
            headers: ApiService.headers,
            body: jsonEncode({
              "manufacturer_id": selectedManufacturerId,
              "batch_no": batchNoController.text.trim(),
              "drug_id": selectedDrugId,
              "manufacture_date": mfgController.text,
              "expiry_date": expController.text,
              "stock_receive_date": stockReceiveController.text,
              "mrp": mrp,
              "purchase_price": purchasePrice,
              "quantity": quantity,
            }),
          )
          .timeout(const Duration(seconds: 30));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        clearForm();
        Get.closeAllSnackbars();
        showMsg(
          data["message"] ?? "Stock received successfully!",
          isError: false,
          isSuccess: true,
        );
      } else {
        throw Exception(data["message"] ?? "Failed to create batch");
      }
    } on TimeoutException {
      Get.closeAllSnackbars();
      showMsg("Request timeout", isError: true);
    } on SocketException {
      Get.closeAllSnackbars();
      showMsg("No internet connection", isError: true);
    } on FormatException {
      Get.closeAllSnackbars();
      showMsg("Invalid response format", isError: true);
    } catch (e) {
      Get.closeAllSnackbars();
      showMsg(e.toString().replaceAll("Exception:", "").trim(), isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showMsg(String msg, {bool isError = false, bool isSuccess = false}) {
    Color bg;
    IconData icon;
    if (isSuccess) {
      bg = _success;
      icon = Icons.check_circle_outline;
    } else if (isError) {
      bg = _error;
      icon = Icons.error_outline;
    } else {
      bg = _purple;
      icon = Icons.info_outline;
    }
    Get.snackbar(
      "",
      "",
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bg,
      borderRadius: 14,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: Duration(seconds: isSuccess ? 3 : 2),
      isDismissible: true,
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 6),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _purpleBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: GoogleFonts.dmSans(
          color: _textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(color: _textSecondary, fontSize: 14),
          prefixIcon: Icon(icon, color: _purple.withOpacity(0.7), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildPickerTile({
    required String hint,
    required String? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool hasValue = value != null && value.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: hasValue ? _purpleSoft : _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasValue ? _purple.withOpacity(0.4) : _purpleBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _purple.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: hasValue ? _purple : _purple.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasValue ? value! : hint,
                style: GoogleFonts.dmSans(
                  color: hasValue ? _textPrimary : _textSecondary,
                  fontSize: 14,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _purple.withOpacity(0.6),
              size: 22,
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
        ? width * 0.2
        : width > 600
        ? width * 0.1
        : 16;
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Receive Stock"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Container(
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFF4F2FB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(horizontalPad, 4, horizontalPad, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel("MANUFACTURER"),
              isDataLoading
                  ? _BlinkingWidget(
                      child: _buildPickerTile(
                        hint: "Loading manufacturers...",
                        value: null,
                        icon: Icons.business,
                        onTap: () {},
                      ),
                    )
                  : _buildPickerTile(
                      hint: "Select Manufacturer",
                      value: selectedManufacturerName.isEmpty
                          ? null
                          : selectedManufacturerName,
                      icon: Icons.business,
                      onTap: selectManufacturer,
                    ),
              _buildSectionLabel("DRUG"),
              isDrugLoading
                  ? _BlinkingWidget(
                      child: _buildPickerTile(
                        hint: "Loading drugs...",
                        value: null,
                        icon: Icons.medication,
                        onTap: () {},
                      ),
                    )
                  : _buildPickerTile(
                      hint: "Select Drug",
                      value: selectedDrugName.isEmpty ? null : selectedDrugName,
                      icon: Icons.medication,
                      onTap: selectDrug,
                    ),
              _buildSectionLabel("STOCK DETAILS"),
              _buildTextField(
                hint: "Batch No *",
                controller: batchNoController,
                icon: Icons.confirmation_number,
              ),
              _buildTextField(
                hint: "Quantity *",
                controller: quantityController,
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                hint: "MRP *",
                controller: mrpController,
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                hint: "Purchase Price *",
                controller: purchaseController,
                icon: Icons.money,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
              ),
              _buildSectionLabel("DATES"),
              _buildPickerTile(
                hint: "Manufacture Date *",
                value: mfgController.text,
                icon: Icons.calendar_today,
                onTap: () => pickDate(isMfg: true),
              ),
              _buildPickerTile(
                hint: "Expiry Date *",
                value: expController.text,
                icon: Icons.calendar_today,
                onTap: () => pickDate(isMfg: false),
              ),
              _buildPickerTile(
                hint: "Stock Receive Date *",
                value: stockReceiveController.text,
                icon: Icons.calendar_today,
                onTap: () => pickDate(isMfg: false, isStock: true),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: isLoading
                    ? _BlinkingWidget(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _purple,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              "Receiving Stock...",
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: createBatch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.save_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Receive Stock",
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBottomSheet extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final IconData icon;
  final String Function(Map<String, dynamic>) labelBuilder;
  final bool Function(Map<String, dynamic>, String) filterLogic;
  const _SearchBottomSheet({
    required this.title,
    required this.items,
    required this.icon,
    required this.labelBuilder,
    required this.filterLogic,
  });
  @override
  State<_SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<_SearchBottomSheet> {
  late final TextEditingController _searchController;
  late final ValueNotifier<List<Map<String, dynamic>>> _filteredNotifier;
  static const Color _purple = Color(0xFF5C35D4);
  static const Color _purpleSoft = Color(0xFFEDE8FB);
  static const Color _textPrimary = Color(0xFF1A1035);
  static const Color _textSecondary = Color(0xFF7B7494);
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredNotifier = ValueNotifier(
      List<Map<String, dynamic>>.from(widget.items),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filteredNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF4F2FB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD4C8F7),
                        width: 1.2,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.dmSans(
                        color: _textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.title,
                        hintStyle: GoogleFonts.dmSans(
                          color: _textSecondary,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: _purple.withOpacity(0.6),
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: _textSecondary,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _filteredNotifier.value = List.from(
                                    widget.items,
                                  );
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                      onChanged: (value) {
                        final query = value.trim().toLowerCase();
                        _filteredNotifier.value = widget.items
                            .where((e) => widget.filterLogic(e, query))
                            .toList();
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _filteredNotifier,
                      builder: (context, filtered, _) {
                        if (filtered.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: _textSecondary.withOpacity(0.4),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "No results found",
                                  style: GoogleFonts.dmSans(
                                    color: _textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.separated(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => Navigator.of(context).pop(item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE5E0F5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: _purpleSoft,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Icon(
                                          widget.icon,
                                          color: _purple,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          widget.labelBuilder(item),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _textPrimary,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Color(0xFF7B7494),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BlinkingWidget extends StatefulWidget {
  final Widget child;
  const _BlinkingWidget({required this.child});
  @override
  State<_BlinkingWidget> createState() => _BlinkingWidgetState();
}

class _BlinkingWidgetState extends State<_BlinkingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.85).animate(_anim),
      child: widget.child,
    );
  }
}

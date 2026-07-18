import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/services/api_service/drug_api.dart';

class AddDrugScreen extends StatefulWidget {
  const AddDrugScreen({super.key});

  @override
  State<AddDrugScreen> createState() => _AddDrugScreenState();
}

class _AddDrugScreenState extends State<AddDrugScreen>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final compositionController = TextEditingController();
  final categoryController = TextEditingController();
  final strengthController = TextEditingController();
  final itemBrandIdController = TextEditingController();
  final scheduleTypeController = TextEditingController();

  String? dosageForm;
  bool isNarcotic = false;
  bool abuseRisk = false;
  bool isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const Color _bg = Color(0xFFF4F2FB);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _purple = Color(0xFF5C35D4);
  static const Color _purpleSoft = Color(0xFFEDE8FB);
  static const Color _purpleBorder = Color(0xFFD4C8F7);
  static const Color _textPrimary = Color(0xFF1A1035);
  static const Color _textSecondary = Color(0xFF7B7494);
  static const Color _error = Color(0xFFE8455A);
  static const Color _success = Color(0xFF00B87A);
  static const Color _redSoft = Color(0xFFFFECEE);

  final List<String> dosageOptions = [
    "Tablet",
    "Capsule",
    "Syrup",
    "Oral",
    "Injection",
    "Inhaler",
    "Drops",
    "Topical",
    "Patch",
    "Suppository",
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    compositionController.dispose();
    categoryController.dispose();
    strengthController.dispose();
    itemBrandIdController.dispose();
    scheduleTypeController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _addDrug() async {
    FocusScope.of(context).unfocus();
    if (isLoading) return;

    final name = nameController.text.trim();
    final strength = strengthController.text.trim();
    final itemBrandId = itemBrandIdController.text.trim();

    if (name.isEmpty ||
        dosageForm == null ||
        strength.isEmpty ||
        itemBrandId.isEmpty) {
      _showMsg(
        "Drug name, strength, dosage form and item brand ID are required",
        isError: true,
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await DrugApi.addDrug(
        name: name,
        dosageForm: dosageForm!,
        strength: strength,
        itemBrandId: itemBrandId,
        composition: compositionController.text.trim(),
        category: categoryController.text.trim(),
        scheduleType: scheduleTypeController.text.trim(),
        isNarcotic: isNarcotic ? 1 : 0,
        abuseRisk: abuseRisk ? 1 : 0,
      );
      if (!mounted) return;
      _showMsg("Drug added to master list", isError: false);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _clearForm();
    } catch (e) {
      _showMsg(e.toString().replaceAll("Exception:", "").trim(), isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _clearForm() {
    nameController.clear();
    compositionController.clear();
    categoryController.clear();
    strengthController.clear();
    itemBrandIdController.clear();
    scheduleTypeController.clear();
    setState(() {
      dosageForm = null;
      isNarcotic = false;
      abuseRisk = false;
    });
  }

  void _showMsg(String msg, {bool isError = false}) {
    Get.closeAllSnackbars();
    Get.snackbar(
      "",
      "",
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
            size: 20,
          ),
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
      backgroundColor: isError ? _error : _success,
      borderRadius: 14,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: Duration(seconds: isError ? 3 : 2),
      isDismissible: true,
    );
  }

  void _openDosageSheet() async {
    FocusScope.of(context).unfocus();
    if (!mounted) return;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _DosageBottomSheet(options: dosageOptions, selected: dosageForm),
    );
    if (result != null && mounted) setState(() => dosageForm = result);
  }

  // ── Field label row ────────────────────────────────────────────────
  Widget _fieldLabel(String label, {bool required = false, String? note}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: _textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (required) ...[
            const SizedBox(width: 4),
            Text(
              "*",
              style: TextStyle(
                color: _error,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          if (note != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _purpleSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                note,
                style: GoogleFonts.dmSans(
                  color: _purple,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────
  Widget _sectionHeader(String label, IconData icon, Color color, Color bg) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Text field ─────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String placeholder,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final isMulti = maxLines > 1;
    final resolvedType =
        keyboardType ??
        (isMulti ? TextInputType.multiline : TextInputType.text);
    final resolvedAction = isMulti ? TextInputAction.newline : textInputAction;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _purpleBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: resolvedType,
        textInputAction: resolvedAction,
        inputFormatters: inputFormatters,
        style: GoogleFonts.dmSans(
          color: _textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: GoogleFonts.dmSans(
            color: _textSecondary.withOpacity(0.7),
            fontSize: 13,
          ),
          prefixIcon: isMulti
              ? Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 14),
                  child: Icon(icon, color: _purple.withOpacity(0.55), size: 20),
                )
              : Icon(icon, color: _purple.withOpacity(0.55), size: 20),
          prefixIconConstraints: BoxConstraints(
            minWidth: 48,
            minHeight: isMulti ? 52 : 0,
          ),
          alignLabelWithHint: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: isMulti ? 14 : 16,
            horizontal: 4,
          ),
        ),
      ),
    );
  }

  // ── Picker tile ────────────────────────────────────────────────────
  Widget _buildPickerTile({
    required String placeholder,
    required String? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool has = value != null && value.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: has ? _purpleSoft : _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: has ? _purple.withOpacity(0.4) : _purpleBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _purple.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: has ? _purple : _purple.withOpacity(0.45),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                has ? value! : placeholder,
                style: GoogleFonts.dmSans(
                  color: has ? _textPrimary : _textSecondary.withOpacity(0.7),
                  fontSize: has ? 14 : 13,
                  fontWeight: has ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _purple.withOpacity(0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ── Toggle tile ────────────────────────────────────────────────────
  Widget _buildToggle({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
    required Color bg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.06) : _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? color.withOpacity(0.35) : _purpleBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value ? color.withOpacity(0.14) : _bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: value ? color : _textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    color: _textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.2),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double pad = width > 900
        ? width * 0.2
        : width > 600
        ? width * 0.1
        : 16.0;

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Get.back(),
              )
            : null,
        title: Text(
          "Add Drug to Master",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: isLoading ? null : _clearForm,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white70,
              size: 18,
            ),
            label: Text(
              "Clear",
              style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Container(
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFF4F2FB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(pad, 8, pad, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _purpleSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _purpleBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: _purple,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Fields marked with * are required.",
                          style: GoogleFonts.dmSans(
                            color: _purple,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                _sectionHeader(
                  "Drug Details",
                  Icons.medication_rounded,
                  _purple,
                  _purpleSoft,
                ),

                _fieldLabel("Drug Name", required: true),
                _buildTextField(
                  controller: nameController,
                  icon: Icons.medication_rounded,
                  placeholder: "e.g. Morphine, Tramadol, Alprazolam",
                ),

                _fieldLabel("Composition", note: "Optional"),
                _buildTextField(
                  controller: compositionController,
                  icon: Icons.science_rounded,
                  placeholder: "e.g. Morphine Sulfate 10mg",
                  maxLines: 3,
                ),

                _fieldLabel("Category", note: "Optional"),
                _buildTextField(
                  controller: categoryController,
                  icon: Icons.category_rounded,
                  placeholder: "e.g. Opioid, Benzodiazepine, Analgesic",
                ),

                _fieldLabel("Strength", required: true),
                _buildTextField(
                  controller: strengthController,
                  icon: Icons.fitness_center_rounded,
                  placeholder: "e.g. 10mg/ml, 500mg, 2mg",
                ),

                _sectionHeader(
                  "Dosage Form",
                  Icons.local_pharmacy_rounded,
                  const Color(0xFF0D9488),
                  const Color(0xFFCCFBF1),
                ),

                _fieldLabel("Dosage Form", required: true),
                _buildPickerTile(
                  placeholder: "Tap to select — Tablet, Injection, Syrup...",
                  value: dosageForm,
                  icon: Icons.local_pharmacy_rounded,
                  onTap: _openDosageSheet,
                ),

                _sectionHeader(
                  "Identification",
                  Icons.qr_code_rounded,
                  const Color(0xFF0369A1),
                  const Color(0xFFE0F2FE),
                ),

                _fieldLabel("Item Brand ID", required: true),
                _buildTextField(
                  controller: itemBrandIdController,
                  icon: Icons.qr_code_rounded,
                  placeholder: "e.g. 10100156 (unique, no spaces)",
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 2, left: 4),
                  child: Text(
                    "Must be unique across all drugs. No spaces allowed.",
                    style: GoogleFonts.dmSans(
                      color: _textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),

                _fieldLabel("Schedule Type", note: "Optional"),
                _buildTextField(
                  controller: scheduleTypeController,
                  icon: Icons.assignment_rounded,
                  placeholder: "e.g. H, H1, X, G, J (leave blank if unknown)",
                  textInputAction: TextInputAction.done,
                ),

                _sectionHeader(
                  "Classification",
                  Icons.shield_rounded,
                  const Color(0xFFBE123C),
                  const Color(0xFFFFE4E6),
                ),

                const SizedBox(height: 10),
                _buildToggle(
                  title: "Narcotic Drug",
                  subtitle:
                      "Requires special license, handling & strict tracking",
                  icon: Icons.warning_amber_rounded,
                  value: isNarcotic,
                  onChanged: (v) => setState(() => isNarcotic = v),
                  color: const Color(0xFFE8455A),
                  bg: _redSoft,
                ),
                _buildToggle(
                  title: "Abuse Risk",
                  subtitle:
                      "High potential for misuse, addiction or dependency",
                  icon: Icons.gpp_bad_rounded,
                  value: abuseRisk,
                  onChanged: (v) => setState(() => abuseRisk = v),
                  color: const Color(0xFFFF7B00),
                  bg: const Color(0xFFFFF3E8),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: isLoading
                      ? _BlinkingWidget(
                          child: Container(
                            decoration: BoxDecoration(
                              color: _purple,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Adding to Master List...",
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
                        )
                      : ElevatedButton(
                          onPressed: _addDrug,
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
                                Icons.add_circle_outline,
                                size: 22,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Add Drug to Master List",
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
      ),
    );
  }
}

class _DosageBottomSheet extends StatelessWidget {
  final List<String> options;
  final String? selected;
  const _DosageBottomSheet({required this.options, required this.selected});

  static const Color _purple = Color(0xFF5C35D4);
  static const Color _purpleSoft = Color(0xFFEDE8FB);
  static const Color _textPrimary = Color(0xFF1A1035);
  static const Color _textSecondary = Color(0xFF7B7494);

  IconData _iconFor(String o) {
    switch (o.toLowerCase()) {
      case "tablet":
        return Icons.circle_outlined;
      case "capsule":
        return Icons.medication_rounded;
      case "syrup":
        return Icons.local_drink_rounded;
      case "oral":
        return Icons.medication_liquid_rounded;
      case "injection":
        return Icons.vaccines_rounded;
      case "inhaler":
        return Icons.air_rounded;
      case "drops":
        return Icons.water_drop_rounded;
      case "topical":
        return Icons.spa_rounded;
      case "patch":
        return Icons.healing_rounded;
      case "suppository":
        return Icons.science_rounded;
      default:
        return Icons.local_pharmacy_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F2FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 14),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      "Select Dosage Form",
                      style: GoogleFonts.dmSans(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${options.length} options",
                      style: GoogleFonts.dmSans(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  controller: sc,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final opt = options[i];
                    final sel = opt == selected;
                    return GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(opt),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: sel ? _purpleSoft : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: sel
                                ? _purple.withOpacity(0.4)
                                : const Color(0xFFE5E0F5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: sel
                                    ? _purple.withOpacity(0.15)
                                    : const Color(0xFFF4F2FB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _iconFor(opt),
                                color: sel ? _purple : _textSecondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                opt,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: sel
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: sel ? _purple : _textPrimary,
                                ),
                              ),
                            ),
                            if (sel)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _purple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: 0.35, end: 0.85).animate(_anim),
    child: widget.child,
  );
}

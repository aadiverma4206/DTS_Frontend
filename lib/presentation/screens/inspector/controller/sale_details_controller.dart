import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/api_service/inspection_api.dart';

class SaleDetailsController extends GetxController {
  SaleDetailsController({required this.userId, required this.type});

  final int userId;
  final String type;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, dynamic> profile = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> sales = <Map<String, dynamic>>[].obs;

  final RxString selectedFilter = 'all'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSaleDetails();
  }

  Future<void> fetchSaleDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await InspectionApi.getSaleDetails(
        userId: userId,
        type: type,
      );
      if (response['success'] == true) {
        profile.assignAll(Map<String, dynamic>.from(response['profile'] ?? {}));
        sales.assignAll(
          List<Map<String, dynamic>>.from(response['sales'] ?? []),
        );
      } else {
        errorMessage.value =
            response['message']?.toString() ?? 'Failed to load sales';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchSaleDetails();
  }

  void setFilter(String filter) => selectedFilter.value = filter;
  void setSearch(String query) =>
      searchQuery.value = query.toLowerCase().trim();

  bool get isRetailer => type == 'retailer';
  bool get isWholesaler => type == 'wholesaler';

  String get name => profile['name']?.toString() ?? '-';
  String get mobile => profile['mobile']?.toString() ?? '-';
  String get companyName => profile['company_name']?.toString() ?? '-';
  String get shopName => profile['shop_name']?.toString() ?? '-';
  String get dlNo => profile['drug_license_no']?.toString() ?? '-';
  bool get hasData => sales.isNotEmpty;

  List<Map<String, dynamic>> get filteredSales {
    List<Map<String, dynamic>> result = List.from(sales);

    // Date filter
    if (selectedFilter.value != 'all') {
      final now = DateTime.now();
      result = result.where((sale) {
        final rawDate = isRetailer ? sale['created_at'] : sale['invoice_date'];
        if (rawDate == null) return false;
        try {
          final d = DateTime.parse(rawDate.toString()).toLocal();
          if (selectedFilter.value == 'today') {
            return d.year == now.year &&
                d.month == now.month &&
                d.day == now.day;
          } else if (selectedFilter.value == 'week') {
            final weekAgo = now.subtract(const Duration(days: 7));
            return d.isAfter(weekAgo);
          } else if (selectedFilter.value == 'month') {
            return d.year == now.year && d.month == now.month;
          }
        } catch (_) {}
        return false;
      }).toList();
    }

    // Search filter
    final q = searchQuery.value;
    if (q.isNotEmpty) {
      result = result.where((sale) {
        if (isRetailer) {
          final patient = (sale['patient_name'] ?? '').toString().toLowerCase();
          final mobile = (sale['patient_mobile'] ?? '')
              .toString()
              .toLowerCase();
          final doctor = (sale['doctor_name'] ?? '').toString().toLowerCase();
          return patient.contains(q) ||
              mobile.contains(q) ||
              doctor.contains(q);
        } else {
          final retailer = (sale['retailer_name'] ?? '')
              .toString()
              .toLowerCase();
          final shop = (sale['shop_name'] ?? '').toString().toLowerCase();
          final dl = (sale['drug_license_no'] ?? '').toString().toLowerCase();
          return retailer.contains(q) || shop.contains(q) || dl.contains(q);
        }
      }).toList();
    }

    return result;
  }

  List<Map<String, dynamic>> get groupedSales {
    final Map<String, Map<String, dynamic>> grouped = {};
    for (final sale in filteredSales) {
      String groupKey;
      if (isRetailer) {
        groupKey =
            '${sale["patient_name"] ?? ""}_${sale["patient_mobile"] ?? ""}_${sale["doctor_name"] ?? ""}';
      } else {
        groupKey = '${sale["retailer_id"] ?? ""}';
      }
      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = {'header': sale, 'items': <Map<String, dynamic>>[]};
      }
      (grouped[groupKey]!['items'] as List<Map<String, dynamic>>).add(sale);
    }
    return grouped.values
        .map((e) => {'header': e['header'], 'items': e['items']})
        .toList();
  }

  String formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      return DateFormat(
        'dd-MM-yyyy hh:mm a',
      ).format(DateTime.parse(date.toString()).toLocal());
    } catch (_) {
      return date.toString();
    }
  }

  String formatInvoiceDate(dynamic date) {
    if (date == null) return '-';
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(date.toString()));
    } catch (_) {
      return '-';
    }
  }

  String value(Map<String, dynamic> item, String key) =>
      item[key]?.toString() ?? '-';
  int intValue(Map<String, dynamic> item, String key) =>
      int.tryParse(item[key]?.toString() ?? '0') ?? 0;
  double doubleValue(Map<String, dynamic> item, String key) =>
      double.tryParse(item[key]?.toString() ?? '0') ?? 0;
}

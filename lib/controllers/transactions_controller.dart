// Purpose: Controller for transactions page
// Author: haptome H.
// Linked Spec Section: Transactions Page

import 'package:et_digital_equb/controllers/bottom_nav_controller.dart';
import 'package:et_digital_equb/core/services/auth_service.dart';
import 'package:et_digital_equb/core/services/payment_service.dart';
import 'package:et_digital_equb/core/services/storage_service.dart';
import 'package:et_digital_equb/core/widgets/transaction_card.dart';
import 'package:get/get.dart';

class TransactionsController extends GetxController {
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;
  final AuthService _authService = AuthService.to;

  @override
  void onInit() {
    super.onInit();
    
    print('TransactionsController.onInit - Starting initialization');
    print('TransactionsController.onInit - isAuthenticated: ${_authService.isAuthenticated.value}');
    print('TransactionsController.onInit - currentUser: ${_authService.currentUser.value?.id}');
    
    // Listen to authentication state changes
    ever(_authService.isAuthenticated, (isAuth) async {
      print('TransactionsController - Auth state changed: $isAuth');
      if (isAuth) {
        // Wait for user data to be available
        await _waitForUserData();
        // User just logged in, load data
        await _loadTransactions();
      } else {
        // User logged out, clear data
        transactions.clear();
      }
    });
  }
  
  @override
  void onReady() {
    super.onReady();
    
    print('TransactionsController.onReady - Controller ready');
    print('TransactionsController.onReady - isAuthenticated: ${_authService.isAuthenticated.value}');
    print('TransactionsController.onReady - currentUser: ${_authService.currentUser.value?.id}');
    
    // Load data if already authenticated when controller becomes ready
    if (_authService.isAuthenticated.value && _authService.currentUser.value != null) {
      print('TransactionsController.onReady - Already authenticated, loading data');
      _loadTransactions();
    }
  }

  Future<void> _waitForUserData() async {
    // Wait up to 3 seconds for user data to be available
    for (int i = 0; i < 30; i++) {
      if (_authService.currentUser.value != null) {
        print('TransactionsController - User data available');
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    print('TransactionsController - Timeout waiting for user data');
  }

  Future<void> _loadTransactions() async {
    if (isLoading.value) return; // Prevent duplicate calls

    // Double-check user is available
    if (_authService.currentUser.value == null) {
      print('TransactionsController - User not available, skipping load');
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    print('TransactionsController._loadTransactions - Starting API call');
    try {
      final paymentService = Get.find<PaymentService>();
      final history = await paymentService.getUserTransactionHistory(
        limit: 50, // Fetch more transactions
      );

      print('TransactionsController._loadTransactions - API call completed, history: ${history?.length ?? 0} items');

      if (history != null) {
        // Convert API response to transaction format expected by UI
        final convertedTransactions = history.map((item) {
          return _convertApiResponseToTransaction(item);
        }).toList();

        transactions.assignAll(convertedTransactions);
        print('TransactionsController._loadTransactions - Loaded ${transactions.length} transactions');
      } else {
        // Handle empty case
        transactions.clear();
        print('TransactionsController._loadTransactions - No transactions returned');
      }
    } catch (e) {
      print('Error loading transactions: $e');

      // Check if it's a permission error
      String errorMessage = e.toString();
      if (errorMessage.contains('transactions.view') ||
          errorMessage.contains('Forbidden') ||
          errorMessage.contains('403')) {
        // For permission errors, just show a log but don't display an error snackbar
        // This allows the app to continue working even if user lacks specific permissions
        print(
          'Permission error accessing transaction history - user may lack transactions.view permission',
        );
        // Clear transactions but don't show error to user
        transactions.clear();
      } else if (errorMessage.contains('User not authenticated')) {
        // User not authenticated yet, just log and clear
        print('User not authenticated, clearing transactions');
        transactions.clear();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load transaction history: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
      print('TransactionsController._loadTransactions - Finished, isLoading: false');
    }
  }

  /// Converts API response to transaction format expected by TransactionCard
  Map<String, dynamic> _convertApiResponseToTransaction(
    Map<String, dynamic> apiItem,
  ) {
    // Extract amount and format it
    final amountValue = apiItem['amount'] ?? 0;
    final formattedAmount = '${amountValue.toStringAsFixed(2)} Birr';

    // Determine transaction type based on payment status and type
    TransactionType type = TransactionType.deposit; // default
    if (apiItem['status'] == 'completed' || apiItem['status'] == 'success') {
      type = TransactionType.deposit;
    } else if (apiItem['status'] == 'failed' ||
        apiItem['status'] == 'cancelled') {
      type = TransactionType.failed;
    } else if (apiItem['status'] == 'pending') {
      type = TransactionType.withdrawal;
    }

    // Format date
    String formattedDate = 'Unknown date';
    if (apiItem['created_at'] != null) {
      try {
        final date = DateTime.parse(apiItem['created_at']);
        // Format as Ethiopian calendar date (this is a simplified format)
        formattedDate =
            '${date.month.toString()}, ${date.day},${date.year}.E.C.';
      } catch (e) {
        // If parsing fails, use original value
        formattedDate = apiItem['created_at'].toString();
      }
    }

    // Determine source based on group info
    String source = 'Payment';
    if (apiItem['group_name'] != null) {
      source = 'From ${apiItem['group_name']}';
    } else if (apiItem['group_id'] != null) {
      source = 'From Group ${apiItem['group_id']}';
    }

    return {
      'id': apiItem['id'] ?? '',
      'type': type,
      'amount': formattedAmount,
      'date': formattedDate,
      'source': source,
      'ekubName': apiItem['group_name'],
      'transactionId': apiItem['reference_id'] ?? apiItem['id'],
      'rounds': apiItem['cycle_number'] != null
          ? '${apiItem['cycle_number']}th round'
          : null,
    };
  }

  /// Public method to load transactions - can be called from the view
  Future<void> loadTransactionsIfNeeded({bool forceRefresh = false}) async {
    print('TransactionsController.loadTransactionsIfNeeded - Called (forceRefresh: $forceRefresh)');
    print('TransactionsController.loadTransactionsIfNeeded - isAuthenticated: ${_authService.isAuthenticated.value}');
    print('TransactionsController.loadTransactionsIfNeeded - currentUser: ${_authService.currentUser.value?.id}');
    print('TransactionsController.loadTransactionsIfNeeded - transactions.length: ${transactions.length}');
    print('TransactionsController.loadTransactionsIfNeeded - isLoading: ${isLoading.value}');
    
    // Load if authenticated and (no transactions loaded OR force refresh)
    if (_authService.isAuthenticated.value && 
        _authService.currentUser.value != null &&
        !isLoading.value &&
        (transactions.isEmpty || forceRefresh)) {
      print('TransactionsController.loadTransactionsIfNeeded - Loading transactions');
      await _loadTransactions();
    } else {
      print('TransactionsController.loadTransactionsIfNeeded - Skipping load');
    }
  }

  Future<void> onRefresh() async {
    await _loadTransactions();
    Get.snackbar(
      'refreshed'.tr,
      'transactions_refreshed'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 1:
        Get.offAllNamed('/your-ekubs');
        break;
      case 2:
        // Already on Transactions page
        break;
      case 3:
        Get.toNamed('/profile');
        break;
    }
  }
}

import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import '../../data/repositories/return_repository.dart';

class MyReturnsViewModel extends ChangeNotifier {
  MyReturnsViewModel({ReturnRepository? returnRepository})
    : _returnRepository = returnRepository ?? ReturnRepository();

  final ReturnRepository _returnRepository;

  bool isLoading = false;
  String? errorMessage;
  List<ReturnHistoryItem> returns = const [];

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      returns = await _returnRepository.fetchMyReturns();
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = '반품 내역을 불러오지 못했습니다.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

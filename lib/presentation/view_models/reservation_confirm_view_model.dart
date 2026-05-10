import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import '../../data/models/local_basket_item_model.dart';
import '../../data/repositories/local_basket_repository.dart';
import '../../data/repositories/repository_contracts.dart';
import '../../data/repositories/reservation_repository.dart';

class ReservationConfirmViewModel extends ChangeNotifier {
  ReservationConfirmViewModel({
    LocalBasketRepositoryContract? localBasketRepository,
    ReservationRepository? reservationRepository,
  }) : _localBasketRepository =
           localBasketRepository ?? LocalBasketRepository(),
       _reservationRepository =
           reservationRepository ?? ReservationRepository();

  final LocalBasketRepositoryContract _localBasketRepository;
  final ReservationRepository _reservationRepository;

  bool _isLoading = true;
  List<LocalBasketItemModel> _items = const [];
  Map<int, String> _itemIssues = const {};
  ReservationPreviewResult? _preview;
  String? _previewErrorMessage;
  bool _isSubmitting = false;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  List<LocalBasketItemModel> get items => _items;
  bool get hasBlockingIssue => _itemIssues.isNotEmpty;
  String? get previewErrorMessage => _previewErrorMessage;

  double get totalReservedKg {
    final previewTotal = _preview?.totalReservedKg;
    if (previewTotal != null) {
      return previewTotal;
    }
    return _items.fold(0, (sum, item) => sum + item.reservedKg);
  }

  int get totalAmount {
    final previewTotal = _preview?.totalAmount;
    if (previewTotal != null) {
      return previewTotal;
    }
    return _items.fold(0, (sum, item) => sum + item.subtotalAmount);
  }

  String? issueForItem(LocalBasketItemModel item) {
    return _itemIssues[item.slotId];
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _localBasketRepository.fetchItems();
      await _loadPreview();
    } catch (_) {
      _items = const [];
      _itemIssues = const {};
      _preview = null;
      _previewErrorMessage = '예약 정보를 불러오지 못했습니다.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<int?> createReservation() async {
    if (_items.isEmpty || hasBlockingIssue || _isSubmitting) {
      return null;
    }

    _isSubmitting = true;
    _previewErrorMessage = null;
    notifyListeners();

    try {
      final result = await _reservationRepository.create(_items);
      ReservationCheckoutCache.save(result.reservationId, _items);
      _localBasketRepository.replaceItems(const []);
      _items = const [];
      return result.reservationId;
    } on ApiException catch (error) {
      _previewErrorMessage = error.message;
      return null;
    } catch (_) {
      _previewErrorMessage = '예약을 완료하지 못했습니다.';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> _loadPreview() async {
    _preview = null;
    _previewErrorMessage = null;
    _itemIssues = const {};

    if (_items.isEmpty) {
      return;
    }

    try {
      _preview = await _reservationRepository.preview(_items);
    } on ApiException catch (error) {
      _previewErrorMessage = error.message;
      _itemIssues = {
        for (final item in _items) item.slotId: '예약 가능 수량과 금액을 다시 확인해주세요.',
      };
    } catch (_) {
      _previewErrorMessage = '예약 가능 여부를 확인하지 못했습니다.';
      _itemIssues = {for (final item in _items) item.slotId: '잠시 후 다시 확인해주세요.'};
    }
  }
}

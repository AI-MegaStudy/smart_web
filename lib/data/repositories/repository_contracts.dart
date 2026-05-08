import '../models/harvest_slot_model.dart';
import '../models/local_basket_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

abstract class ProductRepositoryContract {
  Future<List<ProductModel>> fetchProducts();
  Future<ProductModel> fetchProductDetail(int productId);
  Future<List<HarvestSlotModel>> fetchProductSlots(int productId);
  Future<List<ProductModel>> fetchFeaturedProducts();
}

abstract class LocalBasketRepositoryContract {
  Future<List<LocalBasketItemModel>> fetchItems();
  void upsertItem(LocalBasketItemModel item);
  void removeItem(LocalBasketItemModel item);
  void replaceItems(List<LocalBasketItemModel> items);
}

abstract class OrderRepositoryContract {
  Future<List<OrderModel>> fetchOrders();
  Future<OrderModel> fetchOrderDetail(int orderId);
  Future<void> requestReturn(int orderId);
}

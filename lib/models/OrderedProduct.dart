import 'Model.dart';

class OrderProducts extends Model {
  static const String PRODUCT_UID_KEY = "product_uid";
  static const String PRODUCT_ITEM_COUNT_ = "item_count";
  static const String ORDER_DATE_KEY = "order_date";

  Map<String, dynamic> products;
  String orderDate;
  String? stripeId;
  OrderProducts(
    String id, {
    this.stripeId,
    required this.products,
    required this.orderDate,
  }) : super(id);

  factory OrderProducts.fromMap(Map<String, dynamic> map, String orderDate, {required String id, stripeId}) {
    return OrderProducts(
      id,
      stripeId: stripeId,
      products: map,
      orderDate: orderDate,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      PRODUCT_UID_KEY: products,
      ORDER_DATE_KEY: orderDate,
    };
    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (products != null) map[PRODUCT_UID_KEY] = products;
    if (orderDate != null) map[ORDER_DATE_KEY] = orderDate;
    return map;
  }
}

import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';

class OrdersStream extends DataStream<List<List<Map<String, dynamic>>>> {
  @override
  void reload() {
    final orderedProductsFuture = UserDatabaseHelper().ordersList;
    orderedProductsFuture.then((data) {
      addData(data);
    }).catchError((e) {
      addError(e);
    });
  }
}

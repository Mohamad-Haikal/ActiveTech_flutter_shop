import 'package:admin_dashboard/providers/orders_provider.dart';
import 'package:admin_dashboard/screens/dashboard_screen/dashboard_screen.dart';
import 'package:admin_dashboard/screens/orders_screen.dart';
import 'package:admin_dashboard/widgets/dashboard_titled_card.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class OrdersTableCard extends StatelessWidget {
  final String? header;
  const OrdersTableCard({super.key, this.header});

  @override
  Widget build(BuildContext context) {
    return DashboardTitledCard(
      flex: 5,
      header: header,
      pageRoute: OrdersScreen.route,
      body: FutureBuilder(
        future: Provider.of<OrdersProvider>(context, listen: false).getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return DataTable2(
              sortArrowIcon: Icons.arrow_downward_rounded,
              horizontalScrollController: ScrollController(),
              empty: const Text('none'),
              // isHorizontalScrollBarVisible: true,
              showBottomBorder: true,
              headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: Color.fromARGB(183, 0, 0, 0)),
              bottomMargin: 2.h,
              columns: [
                const DataColumn2(
                  size: ColumnSize.S,
                  label: Text('Id'),
                ),
                const DataColumn2(
                  label: Text('Customer'),
                ),
                const DataColumn2(
                  label: Text('Status'),
                ),
                DataColumn2(
                  size: ColumnSize.S,
                  fixedWidth: 5.w,
                  label: const Text('actions'),
                ),
              ],
              rows: List.generate(
                Provider.of<OrdersProvider>(context, listen: false).items.length,
                (index) {
                  return DashboardCRUD.ordersDataItems(context, Provider.of<OrdersProvider>(context, listen: false).items[index]);
                },
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

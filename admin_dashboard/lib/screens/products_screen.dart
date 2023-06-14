import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sizer/sizer.dart';
import 'package:admin_dashboard/models/product_model.dart';
import 'package:admin_dashboard/providers/products_provider.dart';
import 'package:admin_dashboard/prettyPrint.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_dashboard/widgets/custom_app_bar.dart';
import 'package:admin_dashboard/widgets/custom_side_menu.dart';
import 'package:admin_dashboard/screens/login_screen.dart';

class ProductsScreen extends StatelessWidget {
  static const String route = '/products';

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        body: Row(
          children: [
            CustomSideMenu(initPageRoute: ProductsScreen.route),
            Flexible(
              child: Column(
                children: [
                  CustomAppBar(
                    titleWidget: 'Products',
                  ),
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 15,
                      clipBehavior: Clip.antiAlias,
                      color: Color.fromARGB(255, 255, 255, 255),
                      child: FutureBuilder(
                        future: Provider.of<ProductsProvider>(context, listen: false).getProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Something went wrong!'),
                            );
                          }
                          if (snapshot.connectionState == ConnectionState.done && Provider.of<ProductsProvider>(context).items.isNotEmpty) {
                            pprint(Provider.of<ProductsProvider>(context).items);
                            return RefreshIndicator(
                              onRefresh: () async {
                                await Future.delayed(const Duration(seconds: 1));
                              },
                              child: DataTable2(
                                empty: Text('empty'),
                                sortArrowIcon: Icons.arrow_downward_rounded,
                                smRatio: 0.3,
                                sortColumnIndex: 1,
                                columns: const [
                                  DataColumn2(
                                    label: Text('Image'),
                                    size: ColumnSize.S,
                                  ),
                                  DataColumn2(
                                    label: Text('Name'),
                                  ),
                                  DataColumn2(
                                    label: Text('description'),
                                  ),
                                  DataColumn2(
                                    label: Text('price'),
                                  ),
                                  DataColumn2(
                                    label: Text('id'),
                                  ),
                                ],
                                rows: List.generate(
                                  Provider.of<ProductsProvider>(context).items.length,
                                  (index) {
                                    Product product = Provider.of<ProductsProvider>(context).items[index];
                                    return DataRow2(
                                      specificRowHeight: 7.sp,
                                      cells: [
                                        DataCell(SizedBox.expand(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.network(
                                            product.images.isNotEmpty ? product.images.first : '',
                                            filterQuality: FilterQuality.low,
                                          ),
                                        ))),
                                        DataCell(Text(product.name)),
                                        DataCell(Text(product.description)),
                                        DataCell(Text(product.price.toString())),
                                        DataCell(Text(product.id)),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.route, (route) => false);
      return SizedBox();
    }
  }
}

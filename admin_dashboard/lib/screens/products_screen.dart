import 'package:admin_dashboard/providers/products_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_dashboard/screens/edit_product_screen.dart';
import 'package:admin_dashboard/widgets/app_drawer.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatelessWidget {
  static const routeName = '/products';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('products').get(),
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong!'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents = snapshot.data?.docs;
          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                padding: const EdgeInsets.all(10.0),
                itemCount: documents?.length,
                itemBuilder: (ctx, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GridTile(
                    child: GestureDetector(
                      onTap: () {
                        // Navigator.of(context).pushNamed(EditProductScreen.routeName, arguments: documents[i].id);
                      },
                      child: OptimizedCacheImage(
                        useOldImageOnUrlChange: true,
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        filterQuality: FilterQuality.low,
                        imageUrl: (documents?[i]['images'] as List)[0] ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                    footer: GridTileBar(
                      backgroundColor: Colors.black54,
                      title: Text(
                        documents?[i]['title'] ?? '',
                        textAlign: TextAlign.center,
                      ),
                      subtitle: Text(
                        '\$${documents?[i]['discount_price'].toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Are you sure?'),
                              content: Text('Do you want to remove the product from the cart?'),
                              actions: [
                                TextButton(
                                  child: Text('No'),
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Yes'),
                                  onPressed: () async {
                                    try {
                                      await FirebaseFirestore.instance.collection('products').doc(documents?[i].id).delete();
                                      Navigator.of(ctx).pop();
                                      Navigator.of(ctx).pushReplacementNamed(routeName);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          duration: Duration(seconds: 5),
                                          content: Text(
                                            'Deleting Successfulled!',
                                            style: TextStyle(color: Colors.green),
                                          ),
                                        ),
                                      );
                                    } catch (error) {
                                      print(error);
                                      Navigator.of(ctx).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          duration: Duration(seconds: 5),
                                          content: Text(
                                            'Deleting failed!',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        color: Theme.of(context).errorColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

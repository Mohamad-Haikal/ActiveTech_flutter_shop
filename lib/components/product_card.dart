import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../constants.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';

import '../size_config.dart';

class ProductCard extends StatelessWidget {
  final String productId;
  final GestureTapCallback press;
  const ProductCard({
    Key? key,
    required this.productId,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: kTextColor.withOpacity(0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: FutureBuilder<List<Product>>(
            future: ProductDatabaseHelper().getProductsWithID([productId]) as Future<List<Product>>,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final Product product = snapshot.data![0];
                return buildProductCardItems(context, product);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                final error = snapshot.error.toString();
                Logger().e(error);
              }
              return Center(
                child: Icon(
                  Icons.error,
                  color: kTextColor,
                  size: 60,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Column buildProductCardItems(BuildContext context, Product product) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.all(0.0.sp),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.sp),
              child: Container(
                height: double.maxFinite,
                width: double.maxFinite,
                child: Image.network(
                  product.images != null && product.images!.isNotEmpty ? (product.images as List)[0] : '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return SvgPicture.asset(
                      "assets/icons/no_Image_avaliable.svg",
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 5.sp),
        Flexible(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: Text(
                  "${product.title}\n",
                  style: TextStyle(
                    color: kTextColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 7.sp),
              Flexible(
                flex: 1,
                child: Text.rich(
                  TextSpan(
                    text: "${product.discountPrice}JOD  ",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16.sp,
                    ),
                    children: [
                      TextSpan(
                        text: "${product.originalPrice}JOD",
                        style: TextStyle(
                          color: kTextColor,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 7.sp),
            ],
          ),
        ),
      ],
    );
  }
}

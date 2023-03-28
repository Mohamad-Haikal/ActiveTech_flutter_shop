import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../size_config.dart';

class ProductShortDetailCard extends StatelessWidget {
  final String productId;
  final int? productCount;
  final VoidCallback onPressed;
  const ProductShortDetailCard({
    Key? key,
    required this.productId,
    required this.onPressed,
    required this.productCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: FutureBuilder<List<Product>>(
        future: ProductDatabaseHelper().getProductsWithID([productId]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final product = snapshot.data![0];
            var image;
            if (product.images != null && product.images!.isNotEmpty) {
              if (product.images![0] != null) {
                image = product.images![0];
              }else{
                image = '';
              }
            }
            else{
              image='';
            }
            return product.id != 'deleted'
                ? Row(
                    children: [
                      SizedBox(
                        width: getProportionateScreenWidth(88),
                        child: AspectRatio(
                          aspectRatio: 0.9,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Image.network(
                              image,
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
                      SizedBox(width: getProportionateScreenWidth(20)),
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title ?? 'This product have deleted',
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(14),
                                fontWeight: FontWeight.bold,
                                color: kTextColor,
                              ),
                              maxLines: 2,
                            ),
                            SizedBox(height: 10),
                            Text.rich(
                              TextSpan(
                                  text: "JOD ${product.discountPrice}    ",
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: getProportionateScreenHeight(12),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "JOD ${product.originalPrice}",
                                      style: TextStyle(
                                        color: kTextColor,
                                        decoration: TextDecoration.lineThrough,
                                        fontWeight: FontWeight.normal,
                                        fontSize: getProportionateScreenHeight(10),
                                      ),
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                      ),
                      productCount != null
                          ? Container(
                              margin: EdgeInsets.only(right: getProportionateScreenWidth(20)),
                              width: getProportionateScreenWidth(30),
                              height: getProportionateScreenWidth(30),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(getProportionateScreenWidth(10)),
                                  border: Border.all(color: kPrimaryColor, width: 5)),
                              child: Center(
                                  child: Text(
                                "${productCount}",
                                style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w900, fontSize: getProportionateScreenWidth(14)),
                              )),
                            )
                          : SizedBox()
                    ],
                  )
                : SizedBox();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            final errorMessage = snapshot.error.toString();
            Logger().e(errorMessage);
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
    );
  }
}

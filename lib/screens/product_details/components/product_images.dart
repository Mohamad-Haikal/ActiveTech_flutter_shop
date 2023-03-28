import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/screens/product_details/provider_models/ProductImageSwiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class ProductImages extends StatelessWidget {
  const ProductImages({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product? product;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProductImageSwiper(),
      child: Consumer<ProductImageSwiper>(
        builder: (context, productImagesSwiper, child) {
          return Column(
            children: [
              SwipeDetector(
                onSwipeLeft: (offset) {
                  productImagesSwiper.currentImageIndex++;
                  productImagesSwiper.currentImageIndex %= product!.images!.length;
                },
                onSwipeRight: (offset) {
                  productImagesSwiper.currentImageIndex--;
                  productImagesSwiper.currentImageIndex += product!.images!.length;
                  productImagesSwiper.currentImageIndex %= product!.images!.length;
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  child: SizedBox(
                    height: SizeConfig.screenHeight! * 0.35,
                    width: SizeConfig.screenWidth! * 0.75,
                    child: Image.network(
                      ((product as Product).images as List<String?>).isNotEmpty ? ((product as Product).images as List<String?>)[productImagesSwiper.currentImageIndex] ?? '' : '',
                      fit: BoxFit.contain,
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
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    product!.images!.length,
                    (index) => buildSmallPreview(productImagesSwiper, index: index),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildSmallPreview(ProductImageSwiper productImagesSwiper, {required int index}) {
    return GestureDetector(
      onTap: () {
        productImagesSwiper.currentImageIndex = index;
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(8)),
        padding: EdgeInsets.all(getProportionateScreenHeight(8)),
        height: getProportionateScreenWidth(48),
        width: getProportionateScreenWidth(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: productImagesSwiper.currentImageIndex == index ? kPrimaryColor : Colors.transparent),
        ),
        child: Image.network(
          ((product as Product).images as List<String?>)[index] ?? '',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return SvgPicture.asset(
              "assets/icons/no_Image_avaliable.svg",
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }
}
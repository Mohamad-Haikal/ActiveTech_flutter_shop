import 'package:e_commerce_app_flutter/components/rounded_icon_button.dart';
import 'package:e_commerce_app_flutter/components/search_field.dart';
import 'package:flutter/material.dart';

import '../../../components/icon_button_with_counter.dart';
import '../../../services/data_streams/cart_items_stream.dart';
import '../../../services/data_streams/data_stream.dart';

class HomeHeader extends StatelessWidget {
  final Function onSearchSubmitted;
  final Function onCartButtonPressed;
  final DataStream cartItemsStreamController;
  const HomeHeader({
    Key? key,
    required this.onSearchSubmitted,
    required this.onCartButtonPressed,
    required this.cartItemsStreamController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RoundedIconButton(
            iconData: Icons.menu,
            press: () {
              Scaffold.of(context).openDrawer();
            }),
        Expanded(
          child: SearchField(
            onSubmit: onSearchSubmitted,
          ),
        ),
        SizedBox(width: 5),
        StreamBuilder<List<String>>(
            stream: cartItemsStreamController.stream as Stream<List<String>>,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return IconButtonWithCounter(
                  svgSrc: "assets/icons/Cart Icon.svg",
                  numOfItems: snapshot.data!.length,
                  press: () {
                    onCartButtonPressed.call();
                  },
                );
              }
              return Center(
                  child: IconButtonWithCounter(
                svgSrc: "assets/icons/Cart Icon.svg",
                numOfItems: 0,
                press: () {
                  onCartButtonPressed.call();
                },
              ));
            }),
      ],
    );
  }
}

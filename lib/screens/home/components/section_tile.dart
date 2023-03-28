import 'package:e_commerce_app_flutter/constants.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../size_config.dart';

class SectionTile extends StatelessWidget {
  final String title;
  final GestureTapCallback press;
  final Function? onArrowPressed;
  const SectionTile({
    Key? key,
    required this.title,
    required this.press,
    this.onArrowPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: getProportionateScreenWidth(21),
              fontWeight: FontWeight.bold,
            ),
          ),
          onArrowPressed != null
              ? IconButton(
                  onPressed: () {
                    onArrowPressed!.call();
                  },
                  icon: Icon(Icons.keyboard_arrow_right_rounded),
                  iconSize: 20.sp,
                  splashColor: kTextColor,
                  tooltip: 'Explore $title',
                )
              : SizedBox(),
        ],
      ),
    );
  }
}

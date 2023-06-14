import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:admin_dashboard/constants.dart';

class DashboardTitledCard extends StatelessWidget {
  final Widget body;
  final int flex;
  final String? header;
  final String pageRoute;
  const DashboardTitledCard({super.key, required this.flex, this.header, required this.pageRoute, required this.body});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Card(
        margin: EdgeInsets.all(2.sp),
        elevation: 15,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                header != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              header ?? '',
                              style: TextStyle(fontSize: 5.sp),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'show more',
                                style: TextStyle(fontSize: 3.sp),
                              ),
                              IconButton(
                                onPressed: () {
                                  // debugPrintStack()
                                  Navigator.of(context).pushNamed(pageRoute);
                                },
                                icon: Icon(Icons.keyboard_arrow_right_rounded),
                                iconSize: 4.sp,
                                splashRadius: 4.sp,
                              ),
                            ],
                          )
                        ],
                      )
                    : SizedBox(),
                Expanded(
                  child: Card(
                      color: kPrimaryLightColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Expanded(child: body)),
                ),
              ],
            )),
      ),
    );
  }
}

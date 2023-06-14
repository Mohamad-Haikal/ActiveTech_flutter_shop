import 'package:admin_dashboard/prettyPrint.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final Widget body;
  const DashboardCard({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Center(
        child: Card(
          margin: EdgeInsets.all(2.sp),
          elevation: 15,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 5.sp),
                  ),
                ),
                body,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

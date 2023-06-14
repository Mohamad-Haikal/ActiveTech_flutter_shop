import 'package:admin_dashboard/prettyPrint.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:admin_dashboard/models/user_model.dart';
import 'package:admin_dashboard/providers/users_provider.dart';
import 'package:admin_dashboard/widgets/custom_app_bar.dart';
import 'package:data_table_2/data_table_2.dart';

import 'package:admin_dashboard/widgets/custom_side_menu.dart';

class UsersScreen extends StatefulWidget {
  static const String route = '/users';
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UsersProvider>(context, listen: false).getUsers();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          CustomSideMenu(initPageRoute: UsersScreen.route),
          Expanded(
            child: Column(
              children: [
                CustomAppBar(
                  titleWidget: 'Users',
                ),
                Expanded(
                  child: Card(
                    margin: EdgeInsets.all(3.sp),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 15,
                    child: DataTable2(
                      columns: const [
                        DataColumn2(
                          label: Text('Uid'),
                        ),
                        DataColumn2(
                          label: Text('Name'),
                        ),
                        DataColumn2(
                          label: Text('Phone Number'),
                        ),
                        DataColumn2(
                          label: Text('Email'),
                        ),
                      ],
                      rows: List.generate(
                        Provider.of<UsersProvider>(context).items.length,
                        (index) {
                          User user = Provider.of<UsersProvider>(context).items[index];

                          return DataRow2(
                            cells: [
                              DataCell(Text(user.uid)),
                              DataCell(Text(user.name)),
                              DataCell(Text(user.phoneNumber)),
                              DataCell(Text(user.email)),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

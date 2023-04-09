import 'package:admin_dashboard/screens/orders_screen.dart';
import 'package:admin_dashboard/screens/products_screen.dart';
import 'package:admin_dashboard/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('products').get(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data != null) {
                    return ListView(
                      children: snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['name'] ?? ''),
                          subtitle: Text(data['description'] ?? ''),
                          trailing: Text(data['price'] ?? ''),
                        );
                      }).toList(),
                    );
                  }
                  return Text('Data Not Found or equal null');
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(OrdersScreen.routeName);
            },
            child: Text('View Orders'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(ProductsScreen.routeName);
            },
            child: Text('View Products'),
          ),
        ],
      ),
    );
  }
}

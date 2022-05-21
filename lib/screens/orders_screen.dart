import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../providers/order_provider.dart';

import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  //you can use both initState or didChangeDependencies
  //by default initState is not an async function

  Future<void> _obtainOrdersFuture() async {
    await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _obtainOrdersFuture();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('building orders');
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: _obtainOrdersFuture(),
            builder: (ctx, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (dataSnapshot == null) {
                  return const Center(
                    child: Text('An error occurred!'),
                  );
                } else {
                  return Consumer<Orders>(
                      builder: (ctx, orderData, _) => ListView.builder(
                          itemCount: orderData.orders.length,
                          itemBuilder: (ctx, i) =>
                              OrderItem1(orderData.orders[i])));
                }
              }
            }));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../providers/cart_provider.dart';

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
    this.title,
    this.length,
  }) : super(key: key);

  final Cart cart;
  final String? title;
  final int? length;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final carts = Provider.of<Cart>(context, listen: false);

    return FlatButton(
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text('ORDER NOW'),
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                widget.cart.items.values.toList(),
                widget.cart.totalAmount,
              );

              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}

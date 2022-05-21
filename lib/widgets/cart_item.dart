import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../providers/cart_provider.dart';
import '../models/cart.dart';

class CartItem1 extends StatelessWidget {
  final String productId;
  final String id;

  final double price;
  final int quantity;
  final String title;

  CartItem1(
    this.productId,
    this.id,
    this.price,
    this.quantity,
    this.title,
  );
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(productId),
      background: Container(
        color: Theme.of(context).errorColor,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(
          right: 20,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                    title: const Text(
                      'Are you sure?',
                    ),
                    content: const Text(
                      'Do you want to remove the item from the cart?',
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                      ),
                      TextButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        },
                      ),
                    ]));
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FittedBox(
                    child: Text('$price'),
                  ),
                ),
              ),
              title: Text('$quantity $title'),
              subtitle: Text('Total: \$${price * quantity}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  Provider.of<Cart>(context, listen: false)
                      .removeSingleItem(productId);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text(
                        'Removed item from cart!',
                      ),
                      duration: const Duration(
                        seconds: 3,
                      ),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          Provider.of<Cart>(context, listen: false).addItem(
                            id,
                            price,
                            title,
                          );
                        },
                      )));
                },
                color: Theme.of(context).accentColor,
              ),
            )),
      ),
    );
  }
}

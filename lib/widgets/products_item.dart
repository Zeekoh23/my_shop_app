import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/products_details_screen.dart';
import '../models/products.dart';
import '../models/cart.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

class ProductItem extends StatelessWidget {
  void _selectProductDetails(BuildContext ctx, String? id) {
    Navigator.of(ctx).pushNamed(
      ProductDetailsScreen.routeName,
      arguments: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context,
        listen:
            false); //listen to false only rebuilds the particular section you want to build
    final cart = Provider.of<Cart>(context, listen: false);

    final user = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      //this forces its child widget to take a certain shape
      borderRadius: BorderRadius.circular(10),

      child: GridTile(
        child: GestureDetector(
          onTap: () => _selectProductDetails(context, product.id.toString()),
          child: Hero(
            tag: product.title,
            child: FadeInImage(
              placeholder:
                  const AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit
                  .cover, //to make the image the same size of the container
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black38,
          leading: Consumer<Product>(
            builder: (__, product, _) => IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () {
                product.toggleFavoriteStatus(user.userId, user.token);
              },
            ),
          ),
          title: Text(
            product.title.toString(),
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              cart.addItem(
                product.title,
                product.price,
                product.title,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Added item to cart!'),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    cart.removeSingleItem(product.id);
                  },
                ),
              ));
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}

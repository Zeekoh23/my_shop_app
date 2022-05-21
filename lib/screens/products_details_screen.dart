import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/products_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = '/productdetails';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct = Provider.of<ProductsProvider>(context, listen: false)
        .findById(
            productId); //listening is set to false because no changes in this widget
    return Scaffold(
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 300,
          pinned: true, //appbar will stick at the top
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              loadedProduct.title,
            ),
            background: Hero(
              tag: loadedProduct.title,
              child: Image.network(
                loadedProduct.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          const SizedBox(height: 10),
          Text(
            '\$${loadedProduct.price}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              width: double.infinity,
              child: Text(
                loadedProduct.description,
                softWrap: true,
              )),
          const SizedBox(height: 800),
        ])),
      ]),
    );
  }
}

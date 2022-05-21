import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/helpers/custom_route.dart';
import './screens/products_details_screen.dart';
import './screens/products_overview_screen.dart';
import './providers/products_provider.dart';
import './providers/cart_provider.dart';
import './providers/auth_provider.dart';
import './screens/cart_screen.dart';
import './providers/order_provider.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_add_userproducts_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './models/products.dart';

import '../models/orders.dart';

import './helpers/custom_route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String token = '';
  String userId = '';
  String email = '';

  String? id;
  List<Product> prod = [];
  List<OrderItem> ord = [];

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (c) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
          update: (ctx, auth, previousProduct) => ProductsProvider(
              auth.token,
              auth.userId,
              previousProduct == null
                  ? []
                  : previousProduct
                      .items), //this only works within the screen size or when you are calling an instance of a class

          create: (ctx) => ProductsProvider(token, userId, prod),
        ),
        ChangeNotifierProxyProvider<Auth, Cart>(
          update: (ctx, auth, previousCart) => Cart(auth.token, auth.userId),
          create: (ctx) => Cart(token, userId),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
          create: (ctx) => Orders(token, userId, ord),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Shop App',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            //primaryColor: Colors.purple,
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            }),
          ),

          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authRes) =>
                      authRes.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          //initialRoute: '/',
          routes: {
            ProductDetailsScreen.routeName: (ctx) => ProductDetailsScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

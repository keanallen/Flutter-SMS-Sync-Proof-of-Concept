import 'dart:async';

import 'package:realtime_poc/product.dart';

class ProductService {
  List<Product> products = [];
  final controller = StreamController<ProductEvent>();
}

class ProductEvent extends Product {
  final List<Product> products;
  final Product product;
  final ProductAction action;

  ProductEvent(this.products, this.action, this.product) : super(0, 0, '');
}

enum ProductAction { NEW, INCREMENT, DECREMENT }

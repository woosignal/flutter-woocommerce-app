//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product_variation.dart';
import 'package:woosignal/models/response/products.dart' as ws_product;

class CartLineItem {
  String? name;
  int? productId;
  int? variationId;
  int quantity = 0;
  bool? isManagedStock;
  int? stockQuantity;
  String? shippingClassId;
  String? taxStatus;
  String? taxClass;
  bool? shippingIsTaxable;
  String? subtotal;
  String? total;
  String? imageSrc;
  String? variationOptions;
  List<ws_product.Category>? categories;
  bool? onSale;
  String? stockStatus;
  Object? metaData = {};

  CartLineItem(
      {this.name,
      this.productId,
      this.variationId,
      this.isManagedStock,
      this.stockQuantity,
      this.quantity = 1,
      this.stockStatus,
      this.shippingClassId,
      this.taxStatus,
      this.taxClass,
      this.categories,
      this.shippingIsTaxable,
      this.variationOptions,
      this.imageSrc,
      this.subtotal,
      this.onSale,
      this.total,
      this.metaData});

  String getCartTotal() {
    return (quantity * parseWcPrice(subtotal)).toStringAsFixed(2);
  }

  CartLineItem.fromProduct(
      {int? quantityAmount, required ws_product.Product product}) {
    name = product.name;
    productId = product.id;
    quantity = quantityAmount ?? 1;
    taxStatus = product.taxStatus;
    shippingClassId = product.shippingClassId.toString();
    subtotal = product.price;
    taxClass = product.taxClass;
    categories = product.categories;
    isManagedStock = product.manageStock;
    stockQuantity = product.stockQuantity;
    shippingIsTaxable = product.shippingTaxable;
    imageSrc = product.images.isEmpty
        ? getEnv("PRODUCT_PLACEHOLDER_IMAGE")
        : product.images.first.src;
    total = product.price;
  }

  CartLineItem.fromProductVariation(
      {int? quantityAmount,
      required List<String> options,
      required ws_product.Product product,
      required ProductVariation productVariation}) {
    String? imageSrc = getEnv("PRODUCT_PLACEHOLDER_IMAGE");
    if (product.images.isNotEmpty) {
      imageSrc = product.images.first.src;
    }
    if (productVariation.image != null) {
      imageSrc = productVariation.image!.src;
    }
    name = product.name;
    productId = product.id;
    variationId = productVariation.id;
    quantity = quantityAmount ?? 1;
    taxStatus = productVariation.taxStatus;
    shippingClassId = productVariation.shippingClassId.toString();
    subtotal = productVariation.price;
    stockQuantity = productVariation.stockQuantity;
    isManagedStock = productVariation.manageStock;
    categories = product.categories;
    taxClass = productVariation.taxClass;
    this.imageSrc = imageSrc;
    shippingIsTaxable = product.shippingTaxable;
    variationOptions = options.join("; ");
    total = productVariation.price;
  }

  CartLineItem.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        productId = json['product_id'],
        variationId = json['variation_id'],
        quantity = json['quantity'],
        shippingClassId = json['shipping_class_id'].toString(),
        taxStatus = json['tax_status'],
        stockQuantity = json['stock_quantity'],
        isManagedStock = (json['is_managed_stock'] != null &&
                json['is_managed_stock'] is bool)
            ? json['is_managed_stock']
            : false,
        shippingIsTaxable = json['shipping_is_taxable'],
        subtotal = json['subtotal'],
        total = json['total'],
        taxClass = json['tax_class'],
        stockStatus = json['stock_status'],
        imageSrc = json['image_src'],
        categories = json['categories'] == null
            ? null
            : List.of(json['categories'] as List)
                .map((e) => ws_product.Category.fromJson(e))
                .toList(),
        onSale = json['on_sale'],
        variationOptions = json['variation_options'],
        metaData = json['metaData'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'product_id': productId,
        'variation_id': variationId,
        'quantity': quantity,
        'shipping_class_id': shippingClassId,
        'tax_status': taxStatus,
        'tax_class': taxClass,
        'stock_status': stockStatus,
        'is_managed_stock': isManagedStock,
        'stock_quantity': stockQuantity,
        'shipping_is_taxable': shippingIsTaxable,
        'image_src': imageSrc,
        'categories': categories != null
            ? categories!.map((e) => e.toJson()).toList()
            : [],
        'variation_options': variationOptions,
        'subtotal': subtotal,
        'on_sale': onSale,
        'total': total,
        'meta_data': metaData,
      };
}

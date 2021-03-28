//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter_app/bootstrap/helpers.dart';

class CartLineItem {
  String name;
  int productId;
  int variationId;
  int quantity;
  bool isManagedStock;
  int stockQuantity;
  String shippingClassId;
  String taxStatus;
  String taxClass;
  bool shippingIsTaxable;
  String subtotal;
  String total;
  String imageSrc;
  String variationOptions;
  String stockStatus;
  Object metaData = {};

  CartLineItem(
      {this.name,
      this.productId,
      this.variationId,
      this.isManagedStock,
      this.stockQuantity,
      this.quantity,
      this.stockStatus,
      this.shippingClassId,
      this.taxStatus,
      this.taxClass,
      this.shippingIsTaxable,
      this.variationOptions,
      this.imageSrc,
      this.subtotal,
      this.total,
      this.metaData});

  String getCartTotal() {
    return (quantity * parseWcPrice(subtotal)).toString();
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
        'variation_options': variationOptions,
        'subtotal': subtotal,
        'total': total,
        'meta_data': metaData,
      };
}

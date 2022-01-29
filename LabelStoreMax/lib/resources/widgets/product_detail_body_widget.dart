//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/product_detail_description_widget.dart';
import 'package:flutter_app/resources/widgets/product_detail_header_widget.dart';
import 'package:flutter_app/resources/widgets/product_detail_image_swiper_widget.dart';
import 'package:flutter_app/resources/widgets/product_detail_related_products_widget.dart';
import 'package:flutter_app/resources/widgets/product_detail_reviews_widget.dart';
import 'package:flutter_app/resources/widgets/product_detail_upsell_widget.dart';
import 'package:woosignal/models/response/products.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class ProductDetailBodyWidget extends StatelessWidget {
  const ProductDetailBodyWidget(
      {Key key, @required this.product, @required this.wooSignalApp})
      : super(key: key);

  final Product product;
  final WooSignalApp wooSignalApp;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        ProductDetailImageSwiperWidget(
            product: product,
            onTapImage: (i) => _viewProductImages(context, i)),
        // </Image Swiper>

        ProductDetailHeaderWidget(product: product),
        // </Header title + price>

        ProductDetailDescriptionWidget(product: product),
        // </Description body>

        ProductDetailReviewsWidget(
            product: product, wooSignalApp: wooSignalApp),
        // </Product reviews>

        ProductDetailUpsellWidget(
            productIds: product.upsellIds, wooSignalApp: wooSignalApp),
        // </You may also like>

        ProductDetailRelatedProductsWidget(
            product: product, wooSignalApp: wooSignalApp)
        // </Related products>
      ],
    );
  }

  _viewProductImages(BuildContext context, int i) =>
      Navigator.pushNamed(context, "/product-images", arguments: {
        "index": i,
        "images": product.images.map((f) => f.src).toList()
      });
}

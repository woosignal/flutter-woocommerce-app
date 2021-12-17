//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:woosignal/models/response/products.dart';

import 'controller.dart';
import 'package:flutter/widgets.dart';

class ProductDetailController extends Controller {
  @override
  construct(BuildContext context) {
    super.construct(context);
  }

  viewExternalProduct(Product product) {
    if (product.externalUrl != null && product.externalUrl.isNotEmpty) {
      openBrowserTab(url: product.externalUrl);
    }
  }

  viewProductImages(int i, Product product) =>
      Navigator.pushNamed(context, "/product-images", arguments: {
        "index": i,
        "images": product.images.map((f) => f.src).toList()
      });
}

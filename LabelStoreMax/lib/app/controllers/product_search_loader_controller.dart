//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter_app/app/controllers/woosignal_api_loader_controller.dart';
import 'package:woosignal/models/response/products.dart';

class ProductSearchLoaderController
    extends WooSignalApiLoaderController<Product> {
  ProductSearchLoaderController();

  Future<void> loadProducts(
      {required bool Function(bool hasProducts) hasResults,
      required void Function() didFinish,
      required String? search}) async {
    await load(
        hasResults: hasResults,
        didFinish: didFinish,
        apiQuery: (api) => api.getProducts(
              perPage: 100,
              search: search,
              page: page,
              status: "publish",
              stockStatus: "instock",
            ));
  }
}

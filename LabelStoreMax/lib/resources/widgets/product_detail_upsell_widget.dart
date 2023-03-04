//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/product_loader_controller.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/products.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class ProductDetailUpsellWidget extends StatefulWidget {
  ProductDetailUpsellWidget(
      {required this.productIds, required this.wooSignalApp});
  final List<int>? productIds;
  final WooSignalApp? wooSignalApp;

  @override
  _ProductDetailUpsellWidgetState createState() =>
      _ProductDetailUpsellWidgetState();
}

class _ProductDetailUpsellWidgetState extends State<ProductDetailUpsellWidget> {
  final ProductLoaderController _productLoaderController =
      ProductLoaderController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    List<Product> products = _productLoaderController.getResults();
    if (widget.productIds!.isEmpty ||
        products.isEmpty ||
        widget.wooSignalApp!.showUpsellProducts == false) {
      return SizedBox.shrink();
    }

    if (_isLoading == true) {
      return AppLoaderWidget();
    }

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                trans("${trans('You may also like')}…"),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: 18),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        Container(
          height: 200,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: products
                .map(
                  (e) => Container(
                    width: MediaQuery.of(context).size.width / 2.2,
                    child: ProductItemContainer(product: e),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Future fetchProducts() async {
    await _productLoaderController.loadProducts(
        hasResults: (result) {
          if (result == false) {
            return false;
          }
          return true;
        },
        didFinish: () {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        productIds: widget.productIds);
  }
}

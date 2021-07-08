//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2021, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/product_image_viewer_controller.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:nylo_support/helpers/helper.dart';
import 'package:nylo_support/widgets/ny_state.dart';
import 'package:nylo_support/widgets/ny_stateful_widget.dart';

class ProductImageViewerPage extends NyStatefulWidget {
  final ProductImageViewerController controller =
      ProductImageViewerController();
  ProductImageViewerPage({Key key}) : super(key: key);

  @override
  _ProductImageViewerPageState createState() => _ProductImageViewerPageState();
}

class _ProductImageViewerPageState extends NyState<ProductImageViewerPage> {
  int _initialIndex;
  List<String> _arrImageSrc;

  @override
  void initState() {
    this._initialIndex = widget.controller.data()['index'];
    this._arrImageSrc = widget.controller.data()['images'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Swiper(
                index: _initialIndex,
                itemBuilder: (BuildContext context, int index) =>
                    CachedImageWidget(
                  image: (_arrImageSrc.length == 0
                      ? getEnv("PRODUCT_PLACEHOLDER_IMAGE")
                      : _arrImageSrc[index]),
                ),
                itemCount: _arrImageSrc.length == 0 ? 1 : _arrImageSrc.length,
                viewportFraction: 0.9,
                scale: 0.95,
              ),
            ),
            Container(
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}

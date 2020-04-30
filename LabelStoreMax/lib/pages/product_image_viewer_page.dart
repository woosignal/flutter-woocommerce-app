// PRODUCT DETAIL NEW
//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductImageViewerPage extends StatefulWidget {
  final int initialIndex;
  final List<String> arrImageSrc;

  const ProductImageViewerPage({Key key, this.initialIndex, this.arrImageSrc})
      : super(key: key);

  @override
  _ProductImageViewerPageState createState() =>
      _ProductImageViewerPageState(this.initialIndex, this.arrImageSrc);
}

class _ProductImageViewerPageState extends State<ProductImageViewerPage> {
  _ProductImageViewerPageState(this._initialIndex, this._arrImageSrc);

  int _initialIndex;
  List<String> _arrImageSrc;

  @override
  void initState() {
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
                itemBuilder: (BuildContext context, int index) {
                  return CachedNetworkImage(
                      imageUrl: _arrImageSrc[index],
                      placeholder: (context, url) =>
                          new CircularProgressIndicator(
                              strokeWidth: 2, backgroundColor: Colors.black12),
                      errorWidget: (context, url, error) =>
                          new Icon(Icons.error),
                      fit: BoxFit.contain);
                },
                itemCount: _arrImageSrc.length,
                viewportFraction: 0.9,
                scale: 0.95,
              ),
            ),
            Container(
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/widgets/cached_image_widget.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart';

class ProductDetailImageSwiperWidget extends StatelessWidget {
  const ProductDetailImageSwiperWidget(
      {super.key, required this.product, required this.onTapImage});

  final Product? product;
  final void Function(int i) onTapImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.40,
      child: SizedBox(
        child: Swiper(
          itemBuilder: (BuildContext context, int index) => CachedImageWidget(
            image: product?.images.isNotEmpty ?? false
                ? product?.images[index].src
                : getEnv("PRODUCT_PLACEHOLDER_IMAGE"),
          ),
          itemCount: (product?.images.isEmpty ?? false)
              ? 1
              : product?.images.length ?? 1,
          viewportFraction: 0.85,
          scale: 0.9,
          onTap: onTapImage,
        ),
      ),
    );
  }
}

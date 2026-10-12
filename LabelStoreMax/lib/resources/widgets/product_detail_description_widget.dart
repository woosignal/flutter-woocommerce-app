//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart';

class ProductDetailDescriptionWidget extends StatelessWidget {
  const ProductDetailDescriptionWidget({super.key, required this.product});

  final Product? product;

  @override
  Widget build(BuildContext context) {
    if ((product?.shortDescription?.isEmpty ?? false) &&
        (product?.description?.isEmpty ?? false)) {
      return SizedBox.shrink();
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
                trans("Description"),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: 18),
                textAlign: TextAlign.left,
              ),
              if ((product?.shortDescription?.isNotEmpty ?? false) &&
                  (product?.description?.isNotEmpty ?? false))
                MaterialButton(
                  height: 50,
                  minWidth: 60,
                  onPressed: () => _modalBottomSheetMenu(context),
                  child: Text(
                    trans("Full description"),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 14),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: HtmlWidget(
              (product?.shortDescription?.isNotEmpty ?? false)
                  ? product?.shortDescription ?? ""
                  : product?.description ?? "",
              renderMode: RenderMode.column, onTapUrl: (String url) async {
            await openUrl(url, mode: UrlLaunchModeType.platformDefault);
            return true;
          }, textStyle: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  void _modalBottomSheetMenu(BuildContext context) {
    wsModalBottom(
      context,
      title: trans("Description"),
      bodyWidget: SingleChildScrollView(
        child: HtmlWidget(product?.description ?? ""),
      ),
    );
  }
}

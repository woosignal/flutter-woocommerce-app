//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2022, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woosignal/models/response/products.dart';

class ProductDetailDescriptionWidget extends StatelessWidget {
  const ProductDetailDescriptionWidget({Key? key, required this.product})
      : super(key: key);

  final Product? product;

  @override
  Widget build(BuildContext context) {
    if (product!.shortDescription!.isEmpty && product!.description!.isEmpty) {
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
                style:
                    Theme.of(context).textTheme.caption!.copyWith(fontSize: 18),
                textAlign: TextAlign.left,
              ),
              if (product!.shortDescription!.isNotEmpty &&
                  product!.description!.isNotEmpty)
                MaterialButton(
                  child: Text(
                    trans("Full description"),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(fontSize: 14),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                  height: 50,
                  minWidth: 60,
                  onPressed: () => _modalBottomSheetMenu(context),
                ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: HtmlWidget(
              product!.shortDescription!.isNotEmpty
                  ? product!.shortDescription!
                  : product!.description!,
              renderMode: RenderMode.column, onTapUrl: (String url) async {
            await launchUrl(Uri.parse(url));
            return true;
          }, textStyle: Theme.of(context).textTheme.bodyText2),
        ),
      ],
    );
  }

  _modalBottomSheetMenu(BuildContext context) {
    wsModalBottom(
      context,
      title: trans("Description"),
      bodyWidget: SingleChildScrollView(
        child: HtmlWidget(product!.description!),
      ),
    );
  }
}

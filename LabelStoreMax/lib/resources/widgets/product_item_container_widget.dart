import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '/bootstrap/helpers.dart';
import '/resources/widgets/cached_image_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart';

class ProductItemContainer extends StatelessWidget {
  const ProductItemContainer({
    super.key,
    this.product,
    this.onTap,
  });

  final Product? product;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return SizedBox.shrink();
    }

    double height = 280;
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(4),
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Container(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.0),
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey[100],
                      height: double.infinity,
                      width: double.infinity,
                    ),
                    CachedImageWidget(
                      image: (product!.images.isNotEmpty
                          ? product!.images.first.src
                          : getEnv("PRODUCT_PLACEHOLDER_IMAGE")),
                      fit: BoxFit.contain,
                      height: height,
                      width: double.infinity,
                    ),
                    if (isProductNew(product))
                      Container(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "New",
                          style: TextStyle(color: Colors.white),
                        ),
                        decoration: BoxDecoration(color: Colors.black),
                      ),
                    if (product!.onSale! && product!.type != "variable")
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                          ),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: '',
                              style: Theme.of(context).textTheme.bodyLarge,
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                  "${workoutSaleDiscount(salePrice: product!.salePrice, priceBefore: product!.regularPrice)}% ${trans("off")}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2, bottom: 2),
              child: Text(
                product?.name ?? "",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AutoSizeText(
                    "${formatStringCurrency(total: product?.price)} ",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.left,
                  ),
                  if ((product?.onSale ?? false) && product?.type != "variable")
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: '${trans("Was")}: ',
                          style:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 11,
                          ),
                        ),
                        TextSpan(
                          text: formatStringCurrency(
                            total: product?.regularPrice,
                          ),
                          style:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ]),
                    ),
                ].toList(),
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}

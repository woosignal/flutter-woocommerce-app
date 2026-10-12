//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/widgets/store_logo_widget.dart';
import '/resources/pages/account_detail_page.dart';
import '/resources/pages/cart_page.dart';
import '/resources/pages/wishlist_page.dart';
import '/resources/pages/browse_category_page.dart';
import 'package:woosignal/models/response/product_category.dart';
import '/bootstrap/app_helper.dart';
import '/resources/widgets/app_version_widget.dart';
import '/resources/widgets/cached_image_widget.dart';
import 'package:nylo_framework/theme/helper/ny_theme.dart';
import '/bootstrap/extensions.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/menu_link.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class HomeDrawerWidget extends StatefulWidget {
  const HomeDrawerWidget(
      {super.key,
      required this.wooSignalApp,
      this.productCategories = const []});

  final WooSignalApp? wooSignalApp;
  final List<ProductCategory> productCategories;

  @override
  createState() => _HomeDrawerWidgetState();
}

class _HomeDrawerWidgetState extends NyState<HomeDrawerWidget> {
  List<MenuLink> _menuLinks = [];
  String? _themeType;

  @override
  get init => () {
        _menuLinks = AppHelper.instance.appConfig?.menuLinks ?? [];
        _themeType = AppHelper.instance.appConfig!.theme;
      };

  @override
  Widget view(BuildContext context) {
    bool isDark = (Theme.of(context).brightness == Brightness.dark);
    return Drawer(
      child: Container(
        color: context.color.general.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: context.color.general.background,
              ),
              child: Center(child: StoreLogo()),
            ),
            if (["compo"].contains(_themeType) == false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    child: Text(
                      trans("Menu"),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  if (widget.wooSignalApp!.wpLoginEnabled == 1)
                    ListTile(
                      title: Text(
                        trans("Profile"),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontSize: 16),
                      ),
                      leading: Icon(Icons.account_circle),
                      onTap: _actionProfile,
                    ),
                  if (widget.wooSignalApp!.wishlistEnabled == true)
                    ListTile(
                      title: Text(
                        trans("Wishlist"),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontSize: 16),
                      ),
                      leading: Icon(Icons.favorite_border),
                      onTap: _actionWishlist,
                    ),
                  ListTile(
                    title: Text(
                      trans("Cart"),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 16),
                    ),
                    leading: Icon(Icons.shopping_cart),
                    onTap: _actionCart,
                  ),
                ],
              ),
            if (widget.wooSignalApp?.productCategoryCollections.isNotEmpty ??
                false)
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      child: Text(
                        trans("Categories".tr()),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    ...widget.productCategories.map((collection) {
                      return ListTile(
                        title: Text(
                          collection.name ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: 16),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right_rounded),
                        onTap: () {
                          routeTo(BrowseCategoryPage.path, data: collection);
                        },
                      );
                    })
                  ]),
            if (widget.wooSignalApp!.appTermsLink != null &&
                widget.wooSignalApp!.appPrivacyLink != null)
              Padding(
                padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text(
                  trans("About Us"),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            if (widget.wooSignalApp!.appTermsLink != null &&
                widget.wooSignalApp!.appTermsLink!.isNotEmpty)
              ListTile(
                title: Text(
                  trans("Terms and conditions"),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 16),
                ),
                leading: Icon(Icons.menu_book_rounded),
                trailing: Icon(Icons.keyboard_arrow_right_rounded),
                onTap: _actionTerms,
              ),
            if (widget.wooSignalApp!.appPrivacyLink != null &&
                widget.wooSignalApp!.appPrivacyLink!.isNotEmpty)
              ListTile(
                title: Text(
                  trans("Privacy policy"),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 16),
                ),
                trailing: Icon(Icons.keyboard_arrow_right_rounded),
                leading: Icon(Icons.account_balance),
                onTap: _actionPrivacy,
              ),
            ListTile(
              title: Text(trans((isDark ? "Light Mode" : "Dark Mode")),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 16)),
              leading: Icon(Icons.brightness_4_rounded),
              onTap: () {
                NyTheme.set(context,
                    id: isDark ? "default_light_theme" : "default_dark_theme");
              },
            ),
            if (_menuLinks.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text(
                  trans("Social"),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ..._menuLinks
                .where((element) => element.label != "")
                .map((menuLink) => ListTile(
                      title: Text(menuLink.label,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: 16)),
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CachedImageWidget(
                          image: menuLink.iconUrl,
                          width: 40,
                        ),
                      ),
                      onTap: () async =>
                          await openUrl(menuLink.linkUrl,
                          mode: UrlLaunchModeType.platformDefault),
                    )),
            ListTile(
              title: Text("Change language".tr()),
              leading: Icon(Icons.language),
              onTap: () {
                LanguageSwitcher.showBottomModal(context);
              },
            ),
            ListTile(
              title: AppVersionWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _actionTerms() => openUrl(widget.wooSignalApp!.appTermsLink!);

  Future<bool> _actionPrivacy() =>
      openUrl(widget.wooSignalApp!.appPrivacyLink!);

  void _actionProfile() {
    Navigator.pop(context);
    // AuthRouteGuard sends the customer to the login page when they are not
    // signed in, and brings them back here once they are.
    routeTo(AccountDetailPage.path);
  }

  /// Wishlist action
  Future<void> _actionWishlist() async {
    Navigator.pop(context);
    routeTo(WishlistPage.path);
  }

  /// Cart action
  void _actionCart() {
    Navigator.pop(context);
    routeTo(CartPage.path);
  }
}

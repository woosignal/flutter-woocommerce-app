/* Storage Keys
|--------------------------------------------------------------------------
| Add your storage keys here and then use them later to retrieve data.
| E.g. static final StorageKey userCoins = "USER_COINS";
| String coins = await NyStorage.read( StorageKeysConfig.userCoins );
|
| Learn more: https://nylo.dev/docs/7.x/storage#storage-keys
|-------------------------------------------------------------------------- */

import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/wp_json_api.dart';

final class StorageKeysConfig {
  // Define the keys you want to be synced on boot
  static Future<List<StorageKey>> Function() syncedOnBoot() => () async {
        return <StorageKey>[
          auth,
        ];
      };

  static final StorageKey auth = WPJsonAPI.storageKey();

  /* Cart & checkout
  |------------------------------------------------------------------------
  | These string values are persisted on your customers' devices, changing
  | one drops the data already stored under the old name.
  |------------------------------------------------------------------------ */

  static final StorageKey cart = "CART_SESSION";

  static final StorageKey customerBillingDetails = "CS_BILLING_DETAILS";

  static final StorageKey customerShippingDetails = "CS_SHIPPING_DETAILS";

  static final StorageKey wishlistProducts = "CS_WISHLIST_PRODUCTS";

  /// Add your storage keys here...
}

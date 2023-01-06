//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:woosignal/woosignal.dart';

class WooSignalApiLoaderController<T> {
  List<T> _results = [];
  int page = 1;
  bool _waitForNextRequest = false;

  WooSignalApiLoaderController();

  Future<void> load(
      {required bool Function(bool hasProducts) hasResults,
      required void Function() didFinish,
      required Future<List<T>> Function(WooSignal query) apiQuery}) async {
    if (_waitForNextRequest) {
      return;
    }
    _waitForNextRequest = true;

    List<T> apiResults = await (appWooSignal((api) => apiQuery(api)));

    if (!hasResults(apiResults.isNotEmpty)) {
      return;
    }

    _results.addAll(apiResults);

    page = page + 1;
    _waitForNextRequest = false;
    didFinish();
  }

  List<T> getResults() => _results;

  void clear() {
    _results = [];
    _waitForNextRequest = false;
    page = 1;
  }
}

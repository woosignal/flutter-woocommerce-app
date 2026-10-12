//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import '/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// Shown when a deep link points at a route this app does not have.
class NotFoundPage extends NyStatefulWidget {
  static RouteView path = ("/not-found", (_) => NotFoundPage());

  NotFoundPage({super.key}) : super(child: () => _NotFoundPageState());
}

class _NotFoundPageState extends NyPage<NotFoundPage> {
  @override
  Widget view(BuildContext context) {
    return Scaffold(
      // These two keys ship translated in every lang/*.json - they are the
      // framework's own, so do not swap them for bare strings.
      appBar: AppBar(title: Text(trans("nylo.page_not_found.title"))),
      body: SafeAreaWidget(
        child: Center(
          child: Text(trans("nylo.page_not_found.message")),
        ),
      ),
    );
  }
}

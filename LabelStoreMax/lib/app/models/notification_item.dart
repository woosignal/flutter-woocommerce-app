//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2026, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:nylo_framework/nylo_framework.dart';

class NotificationItem extends Model {
  String? id;
  String? title;
  String? message;
  bool? hasRead;
  String? type;
  Map<String, dynamic>? meta;
  String? createdAt;

  NotificationItem(
      {this.title,
      this.message,
      this.id,
      this.type,
      this.meta,
      this.createdAt,
      this.hasRead = false});

  NotificationItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        type = json['type'],
        meta = json['meta'],
        message = json['message'],
        hasRead = json['has_read'],
        createdAt = json['created_at'];

  void fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    meta = json['meta'];
    message = json['message'];
    hasRead = json['has_read'];
    createdAt = json['created_at'];
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'meta': meta,
        'message': message,
        'has_read': hasRead,
        "created_at": createdAt
      };
}

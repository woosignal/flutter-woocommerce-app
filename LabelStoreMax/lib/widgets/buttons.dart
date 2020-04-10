import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helpers/tools.dart';

Widget wsPrimaryButton(BuildContext context,
    {@required String title, void Function() action}) {
  return Container(
    height: 55,
    child: RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      padding: EdgeInsets.all(8),
      child: Text(
        title,
        style: Theme.of(context).primaryTextTheme.button.copyWith(fontSize: 16),
      ),
      onPressed: action ?? null,
      elevation: 0,
    ),
  );
}

Widget wsSecondaryButton(BuildContext context,
    {String title, void Function() action}) {
  return Container(
    height: 60,
    margin: EdgeInsets.only(top: 10),
    child: RaisedButton(
        padding: EdgeInsets.all(10),
        child: Text(title,
            style: Theme.of(context).primaryTextTheme.body2,
            textAlign: TextAlign.center),
        onPressed: action,
        color: HexColor("#f6f6f9"),
        elevation: 0),
  );
}

Widget wsLinkButton(BuildContext context,
    {String title, void Function() action}) {
  return Container(
    height: 60,
    margin: EdgeInsets.only(top: 10),
    child: MaterialButton(
        padding: EdgeInsets.all(10),
        child: Text(title,
            style: Theme.of(context).primaryTextTheme.body2,
            textAlign: TextAlign.left),
        onPressed: action,
        elevation: 0),
  );
}

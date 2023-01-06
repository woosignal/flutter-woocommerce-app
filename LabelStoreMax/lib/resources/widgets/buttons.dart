//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2023, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
      {Key? key, this.title, this.action, this.isLoading = false})
      : super(key: key);

  final String? title;
  final Function? action;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => WooSignalButton(
        key: key,
        title: title,
        action: action,
        isLoading: isLoading,
        textStyle: Theme.of(context).textTheme.button!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ThemeColor.get(context).buttonPrimaryContent),
        bgColor: ThemeColor.get(context).buttonBackground,
      );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    Key? key,
    this.title,
    this.action,
  }) : super(key: key);

  final String? title;
  final Function? action;

  @override
  Widget build(BuildContext context) => WooSignalButton(
        key: key,
        title: title,
        action: action,
        textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Colors.black87,
            ),
        bgColor: Color(0xFFF6F6F9),
      );
}

class LinkButton extends StatelessWidget {
  const LinkButton({
    Key? key,
    this.title,
    this.action,
  }) : super(key: key);

  final String? title;
  final Function? action;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      key: key,
      child: Container(
        height: (screenWidth >= 385 ? 55 : 49),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Center(
            child: Text(
          title!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText1,
        )),
      ),
      onTap: action == null ? null : () async => await action!(),
    );
  }
}

class WooSignalButton extends StatelessWidget {
  const WooSignalButton({
    Key? key,
    this.title,
    this.action,
    this.textStyle,
    this.isLoading = false,
    this.bgColor,
  }) : super(key: key);

  final String? title;
  final Function? action;
  final TextStyle? textStyle;
  final Color? bgColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: (screenWidth >= 385 ? 55 : 49),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: EdgeInsets.all(8),
          elevation: 0,
          primary: bgColor,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? AppLoaderWidget()
            : AutoSizeText(
                title!,
                style: textStyle,
                maxLines: (screenWidth >= 385 ? 2 : 1),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
        onPressed: (action == null || isLoading == true)
            ? null
            : () async {
                await action!();
              },
      ),
    );
  }
}

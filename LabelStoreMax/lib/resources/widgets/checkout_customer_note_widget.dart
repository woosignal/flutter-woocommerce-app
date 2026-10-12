import 'package:flutter/material.dart';
import '/app/models/checkout_session.dart';
import '/resources/pages/checkout_confirmation_page.dart';
import '/resources/widgets/buttons/buttons.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CheckoutCustomerNote extends StatelessWidget {
  CheckoutCustomerNote({super.key, required this.checkoutSession}) {
    textEditingController.text = checkoutSession.customerNote ?? "";
  }

  final CheckoutSession checkoutSession;
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool hasCustomerNote = checkoutSession.customerNote != null;
    return Container(
      height: 50,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () => _actionCustomerNote(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                hasCustomerNote
                    ? "${'Order Note'.tr()}: ${checkoutSession.customerNote ?? ""}"
                    : 'Order Note'.tr(),
                style: Theme.of(context).textTheme.titleSmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            if (hasCustomerNote == true)
              IconButton(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  onPressed: _removeCustomerNote,
                  icon: Icon(
                    Icons.close,
                    size: 19,
                  )),
          ],
        ).paddingSymmetric(horizontal: 16),
      ),
    );
  }

  void _actionCustomerNote(BuildContext context) {
    // open modal to add customer note
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Wrap(
              spacing: 20,
              children: <Widget>[
                TextFormField(
                  autofocus: true,
                  maxLines: 3,
                  controller: textEditingController,
                  decoration: InputDecoration(
                    labelText: "Order Note".tr(),
                    hintText: "Enter order note".tr(),
                  ),
                  onChanged: (value) {
                    CheckoutSession.getInstance.customerNote = value;
                  },
                ),
                Padding(padding: EdgeInsets.only(top: 16)),
                Button.primary(
                    text: "Save Note".tr(),
                    onPressed: () {
                      if (CheckoutSession.getInstance.customerNote == "") {
                        CheckoutSession.getInstance.customerNote = null;
                      }
                      bool isSuccessful = FormValidator.maxLength(100)
                          .that(CheckoutSession.getInstance.customerNote ?? "",
                              "Order Note".tr())
                          .check()
                          .isValid;
                      if (isSuccessful == false) {
                        showToastNotification(context,
                            title: "Error".tr(),
                            description:
                                "Order note must be less than 100 characters"
                                    .tr(),
                            id: 'danger');
                        return;
                      }
                      StateAction.refreshPage(CheckoutConfirmationPage.path,
                          setState: () {});
                      Navigator.pop(context);
                    }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeCustomerNote() {
    CheckoutSession.getInstance.customerNote = null;
    StateAction.refreshPage(CheckoutConfirmationPage.path, setState: () {});
  }
}

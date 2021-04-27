import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/shared_pref/sp_auth.dart';
import 'package:flutter_app/resources/pages/account_detail.dart';
import 'package:flutter_app/resources/pages/account_landing.dart';
import 'package:flutter_app/resources/pages/cart.dart';
import 'package:flutter_app/resources/pages/home_search.dart';
import 'package:flutter_app/resources/widgets/notic_home_widget.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class NoticThemeWidget extends StatefulWidget {
  NoticThemeWidget(
      {Key key, @required this.globalKey, @required this.wooSignalApp})
      : super(key: key);
  final GlobalKey globalKey;
  final WooSignalApp wooSignalApp;

  @override
  _NoticThemeWidgetState createState() => _NoticThemeWidgetState();
}

class _NoticThemeWidgetState extends State<NoticThemeWidget> {
  Widget activeWidget;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _changeMainWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: activeWidget,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        unselectedItemColor: Colors.black54,
        fixedColor: Colors.black87,
        selectedLabelStyle: TextStyle(color: Colors.black),
        unselectedLabelStyle: TextStyle(
          color: Colors.black87,
        ),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          if (AppHelper.instance.appConfig.wpLoginEnabled == 1)
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account')
        ],
      ),
    );
  }

  _onTabTapped(int i) async {
    _currentIndex = i;
   await _changeMainWidget();
    setState(() {});
  }

  _changeMainWidget() async {
    switch (_currentIndex) {
      case 0:
        {
          activeWidget = NoticHomeWidget(wooSignalApp: widget.wooSignalApp);
          break;
        }
      case 1:
        {
          activeWidget = HomeSearchPage();
          break;
        }
      case 2:
        {
          activeWidget = CartPage();
          break;
        }
      case 3:
        {
          activeWidget = (await authCheck()) ? AccountDetailPage(showLeadingBackButton: false) : AccountLandingPage();
          break;
        }
    }
  }
}

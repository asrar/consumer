import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:consumer/BottomNavigation/Account/account_page.dart';
import 'package:consumer/BottomNavigation/MyDeliveries/my_deliveries.dart';
import 'package:flutter/material.dart';
import 'Home/home_page.dart';

class BottomNavigation extends StatefulWidget {
  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 1;
  final List<Widget> _children = <Widget>[
    MyDeliveriesPage(),
    HomeScreen(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> _bottomBarItems = [
      BottomNavigationBarItem(
        icon: FadedScaleAnimation(
          Image.asset('images/ic_feeds.png', scale: 3),
          durationInMilliseconds: 400,
        ),
        activeIcon: Image.asset('images/ic_feeds_active.png', scale: 3),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: FadedScaleAnimation(
          Image.asset('images/ic_home.png', scale: 3),
          durationInMilliseconds: 400,
        ),
        activeIcon: Image.asset('images/ic_home_active.png', scale: 3),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: FadedScaleAnimation(
          Image.asset('images/ic_profile.png', scale: 3),
          durationInMilliseconds: 400,
        ),
        activeIcon: Image.asset('images/ic_profile_active.png', scale: 3),
        label: '',
      ),
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: [
          _children[_currentIndex],
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavigationBar(
              items: _bottomBarItems,
              currentIndex: _currentIndex,
              showSelectedLabels: false,
              onTap: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}

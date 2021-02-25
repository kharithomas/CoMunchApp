import 'package:CoMunch/munch_icons.dart';
import 'package:CoMunch/shared/gradient_mask.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'helper/shared_prefs.dart';
import 'pages/discover_places_page.dart';
import 'pages/home_page.dart';
import 'pages/partners_page.dart';
import 'pages/profile_page.dart';

class MainView extends StatefulWidget {
  static const routeName = '/main-view';

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  PageController _pageController = PageController();
  final Shader _linearGradient = LinearGradient(
    colors: <Color>[
      Color(0xffEAA05D),
      Color(0xffE74E4D),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  // List of Screens
  final List<Widget> _pages = [
    HomePage(),
    DiscoverPlacesPage(),
    PartnersPage(),
    ProfilePage(profileName: sharedPrefs.getName, email: sharedPrefs.getEmail),
  ];

  var _selectedIndex = 0;
  // Updates UI to show active nav item
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Switches page to current nav item
  void _onNavItemTapped(int selectedIndex) {
    _pageController.jumpToPage(selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: _onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xffADADAD))),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavItemTapped,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          fixedColor: Colors.black,
          iconSize: 26,
          selectedFontSize: 12,
          selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              foreground: Paint()..shader = _linearGradient),
          unselectedLabelStyle: TextStyle(color: Colors.black),
          backgroundColor: Colors.white,
          items: [
            BottomNavigationBarItem(
                label: 'Chats',
                icon: _selectedIndex == 0
                    ? GradientMask(Icon(MunchIcons.chat, color: Colors.white))
                    : Icon(MunchIcons.chat_outline, color: Colors.black)),
            BottomNavigationBarItem(
                label: 'Discover',
                icon: _selectedIndex == 1
                    ? GradientMask(
                        Icon(MunchIcons.discovery, color: Colors.white))
                    : Icon(MunchIcons.discovery_outline, color: Colors.black)),
            BottomNavigationBarItem(
                label: 'Matches',
                icon: _selectedIndex == 2
                    ? GradientMask(Icon(MunchIcons.heart, color: Colors.white))
                    : Icon(MunchIcons.heart_outline, color: Colors.black)),
            BottomNavigationBarItem(
                label: 'Profile',
                icon: _selectedIndex == 3
                    ? GradientMask(
                        Icon(MunchIcons.profile, color: Colors.white))
                    : Icon(MunchIcons.profile_outline, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

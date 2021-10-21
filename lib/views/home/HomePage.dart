import 'package:famlicious/views/chat/chat_view.dart';
import 'package:famlicious/views/favourite/favourite_view.dart';
import 'package:famlicious/views/profile/profile_view.dart';
import 'package:famlicious/views/timeline/timeline_view.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Widget> screens = [
    TimelineView(),
    ChatView(),
    FavouriteView(),
    ProfileView(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            label: 'Timeline',
            icon: Icon(UniconsLine.history),
          ),
          BottomNavigationBarItem(
            label: 'Chat',
            icon: Icon(UniconsLine.comment),
          ),
          BottomNavigationBarItem(
            label: 'Favourite',
            icon: Icon(UniconsLine.heart),
          ),
          BottomNavigationBarItem(
            label: 'Account',
            icon: Icon(UniconsLine.user),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
    );
  }
}

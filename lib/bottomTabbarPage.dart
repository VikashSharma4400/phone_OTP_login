import 'package:blackcoffer_test_assignment/AddVideosPage.dart';
import 'package:flutter/material.dart';

import 'ExplorePage.dart';

class TabBarPage extends StatefulWidget {
  const TabBarPage({super.key});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {

  int index = 0;
  final pages = [
    const Explorepage(),
    const AddVideosPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar:
      NavigationBarTheme(
        data: NavigationBarThemeData(
          elevation: 100.0,
          indicatorColor: Colors.white70,
          backgroundColor: Colors.orange,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        child: NavigationBar(
          height: 60,
          selectedIndex: index,
          onDestinationSelected: (index) =>
              setState(() => this.index = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home,),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_library_outlined),
              label: 'Add Videos',
            ),
          ],
        ),
      ),
    );
  }
}

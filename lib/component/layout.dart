import 'package:aquatracking/component/custom_navigation_bar.dart';
import 'package:flutter/material.dart';

class Layout extends StatelessWidget {
  final Widget child;

  const Layout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      backgroundColor: Theme.of(context).backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {  },
        child: const Icon(Icons.add),
        elevation: 2,
        backgroundColor: Theme.of(context).highlightColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}
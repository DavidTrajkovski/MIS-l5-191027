import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/screens/calendar_screen.dart';
import '/providers/authentication_provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          AppBar(
            title: const Text('Exam Planner 191027'),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Exams'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Calendar'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/calendar');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Map'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/map');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/auth');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}

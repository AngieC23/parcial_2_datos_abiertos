import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/api_endpoints.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Parcial 2',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Datos Abiertos de Colombia',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Navegacion principal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            subtitle: const Text('Resumen de endpoints'),
            onTap: () {
              context.go('/');
              Navigator.pop(context);
            },
          ),
          const Divider(height: 20),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              'Endpoints',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          for (final endpoint in kApiEndpoints)
            ListTile(
              leading: Icon(endpoint.icon),
              title: Text(endpoint.title),
              subtitle: Text(endpoint.path),
              onTap: () {
                context.push('/list/${endpoint.key}');
                Navigator.pop(context);
              },
            ),
          const Divider(height: 20),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Proyecto estructurado por capas: config, models, services, routes y views.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

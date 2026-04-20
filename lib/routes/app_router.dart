import 'package:electiva_2026/views/home/home_screen.dart';
import 'package:electiva_2026/views/home/endpoint_detail_screen.dart';
import 'package:electiva_2026/views/home/endpoint_list_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/list/:endpoint',
      name: 'list',
      builder: (context, state) {
        final endpoint = state.pathParameters['endpoint']!;
        return EndpointListScreen(endpointKey: endpoint);
      },
    ),
    GoRoute(
      path: '/detail/:endpoint/:id',
      name: 'detail',
      builder: (context, state) {
        final endpoint = state.pathParameters['endpoint']!;
        final id = state.pathParameters['id']!;
        return EndpointDetailScreen(endpointKey: endpoint, itemId: id);
      },
    ),
  ],
);

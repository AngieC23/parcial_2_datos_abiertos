import 'package:flutter/material.dart';

class ApiEndpointConfig {
  const ApiEndpointConfig({
    required this.key,
    required this.title,
    required this.path,
    required this.description,
    required this.icon,
  });

  final String key;
  final String title;
  final String path;
  final String description;
  final IconData icon;
}

const List<ApiEndpointConfig> kApiEndpoints = [
  ApiEndpointConfig(
    key: 'departments',
    title: 'Departamentos',
    path: 'Department',
    description: 'Consulta nombre, capital y superficie de departamentos.',
    icon: Icons.map,
  ),
  ApiEndpointConfig(
    key: 'presidents',
    title: 'Presidentes',
    path: 'President',
    description: 'Explora periodos, biografias e imagenes presidenciales.',
    icon: Icons.account_balance,
  ),
  ApiEndpointConfig(
    key: 'regions',
    title: 'Regiones',
    path: 'Region',
    description: 'Visualiza regiones naturales de Colombia.',
    icon: Icons.public,
  ),
  ApiEndpointConfig(
    key: 'touristic-attractions',
    title: 'Atractivos Turisticos',
    path: 'TouristicAttraction',
    description: 'Conoce lugares de interes con descripcion e imagenes.',
    icon: Icons.place,
  ),
];

ApiEndpointConfig getEndpointByKey(String key) {
  return kApiEndpoints.firstWhere(
    (endpoint) => endpoint.key == key,
    orElse: () => kApiEndpoints.first,
  );
}

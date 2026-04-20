import 'package:electiva_2026/config/api_endpoints.dart';
import 'package:electiva_2026/services/api_colombia_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EndpointDetailScreen extends StatefulWidget {
  const EndpointDetailScreen({
    super.key,
    required this.endpointKey,
    required this.itemId,
  });

  final String endpointKey;
  final String itemId;

  @override
  State<EndpointDetailScreen> createState() => _EndpointDetailScreenState();
}

class _EndpointDetailScreenState extends State<EndpointDetailScreen> {
  final ApiColombiaService _service = ApiColombiaService();
  late Future<Map<String, dynamic>> _futureItem;

  void _reload() {
    setState(() {
      _futureItem = _service.getEndpointItemById(
        endpointKey: widget.endpointKey,
        id: widget.itemId,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _futureItem = _service.getEndpointItemById(
      endpointKey: widget.endpointKey,
      id: widget.itemId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final endpoint = getEndpointByKey(widget.endpointKey);
    final theme = Theme.of(context);
    final canGoBack = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Detalle: ${endpoint.title}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (canGoBack) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureItem,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text('No fue posible cargar el detalle.'),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final item = snapshot.data ?? const {};
          if (item.isEmpty) {
            return const Center(
              child: Text('No se encontro informacion del elemento.'),
            );
          }

          final raw = item['raw'] is Map<String, dynamic>
              ? item['raw'] as Map<String, dynamic>
              : item;
          final imageUrl = _extractImageUrl(raw);

          final sortedEntries = raw.entries.toList()
            ..sort((a, b) {
              final aPriority = _fieldPriority(a.key);
              final bPriority = _fieldPriority(b.key);
              if (aPriority != bPriority) {
                return aPriority.compareTo(bPriority);
              }
              return a.key.compareTo(b.key);
            });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: imageUrl.isEmpty
                      ? _buildImagePlaceholder(theme, 'Imagen no disponible')
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder(
                              theme,
                              'No se pudo cargar la imagen',
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      raw['name']?.toString() ??
                          raw['title']?.toString() ??
                          'Detalle',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ID: ${widget.itemId} | Recurso: ${endpoint.path}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final entry in sortedEntries)
                Card(
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ListTile(
                    minLeadingWidth: 0,
                    leading: Icon(
                      Icons.label_outline,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(_translateField(entry.key)),
                    subtitle: Text(_formatValue(entry.value)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) {
      return 'No disponible';
    }

    if (value is Map) {
      final values = value.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .toList();
      return values.join(' | ');
    }

    if (value is List) {
      return value.map((item) => item.toString()).join(', ');
    }

    return value.toString();
  }

  String _translateField(String field) {
    const labels = <String, String>{
      'id': 'Identificador',
      'name': 'Nombre',
      'lastName': 'Apellido',
      'description': 'Descripcion',
      'cityCapital': 'Capital',
      'surface': 'Superficie',
      'startPeriodDate': 'Inicio de periodo',
      'endPeriodDate': 'Fin de periodo',
      'politicalParty': 'Partido politico',
      'image': 'Imagen',
      'images': 'Imagenes',
      'city': 'Ciudad',
      'cities': 'Ciudades',
      'departments': 'Departamentos',
      'region': 'Region',
      'regionId': 'Identificador de region',
      'airports': 'Aeropuertos',
      'municipalities': 'Municipios',
      'naturalAreas': 'Areas naturales',
      'indigenousReservations': 'Resguardos indigenas',
      'maps': 'Mapas',
      'raw': 'Datos completos',
    };

    return labels[field] ?? field;
  }

  int _fieldPriority(String key) {
    const order = <String, int>{
      'id': 0,
      'name': 1,
      'lastName': 2,
      'startPeriodDate': 3,
      'endPeriodDate': 4,
      'politicalParty': 5,
      'description': 6,
      'region': 7,
      'regionId': 8,
    };

    return order[key] ?? 100;
  }

  String _extractImageUrl(Map<String, dynamic> raw) {
    final direct = raw['image']?.toString().trim() ?? '';
    if (direct.startsWith('http://') || direct.startsWith('https://')) {
      return direct;
    }

    final images = raw['images'];
    if (images is List) {
      for (final image in images) {
        final url = image.toString().trim();
        if (url.startsWith('http://') || url.startsWith('https://')) {
          return url;
        }
      }
    }

    return '';
  }

  Widget _buildImagePlaceholder(ThemeData theme, String message) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

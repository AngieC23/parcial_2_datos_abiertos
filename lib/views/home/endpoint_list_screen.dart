import 'package:electiva_2026/config/api_endpoints.dart';
import 'package:electiva_2026/services/api_colombia_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EndpointListScreen extends StatefulWidget {
  const EndpointListScreen({super.key, required this.endpointKey});

  final String endpointKey;

  @override
  State<EndpointListScreen> createState() => _EndpointListScreenState();
}

class _EndpointListScreenState extends State<EndpointListScreen> {
  final ApiColombiaService _service = ApiColombiaService();

  late Future<List<Map<String, dynamic>>> _futureItems;

  void _reload() {
    setState(() {
      _futureItems = _service.getEndpointItems(widget.endpointKey);
    });
  }

  @override
  void initState() {
    super.initState();
    _futureItems = _service.getEndpointItems(widget.endpointKey);
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
        title: Text('Listado: ${endpoint.title}'),
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureItems,
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
                    Text(
                      'Ocurrio un error al cargar la informacion.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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

          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('No hay registros para mostrar.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _futureItems;
            },
            child: ListView.builder(
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.tertiary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.dataset_linked_outlined,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${items.length} registros cargados en ${endpoint.title}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final item = items[index - 1];
                final imageUrl = item['image']?.toString() ?? '';
                final hasImage = imageUrl.startsWith('http');

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.16),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    leading: _ItemAvatar(
                      imageUrl: hasImage ? imageUrl : '',
                      backgroundColor: theme.colorScheme.secondaryContainer,
                    ),
                    title: Text(item['title']?.toString() ?? 'Sin titulo'),
                    subtitle: Text(
                      item['subtitle']?.toString() ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push(
                        '/detail/${widget.endpointKey}/${item['id']}',
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ItemAvatar extends StatelessWidget {
  const _ItemAvatar({required this.imageUrl, required this.backgroundColor});

  final String imageUrl;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white,
          size: 20,
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: backgroundColor,
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.broken_image_outlined,
                color: Colors.white,
                size: 20,
              ),
            );
          },
        ),
      ),
    );
  }
}

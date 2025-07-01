// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/notification/notification_model.dart';
import '../../../models/notification/notification_type.dart';
import '../../../providers/notification_provider.dart';
import '../widgets/custom_error.dart';
import '../widgets/loading_widget.dart';
import '../widgets/notification_filter.dart';
import '../widgets/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // ✅ OPTIMIZACIÓN: Solo inicializar si realmente es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

      // Solo inicializar si no hay notificaciones Y no está cargando Y no hay error
      if (notificationProvider.notifications.isEmpty &&
          !notificationProvider.isLoading &&
          notificationProvider.error == null) {
        notificationProvider.initialize();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // ✅ MEJORA: Separar AppBar para mejor legibilidad
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          // ✅ MEJORA: Mostrar contador de no leídas en el título
          final unreadCount = provider.unreadCount;
          return Text(
            unreadCount > 0 ? 'Notificaciones ($unreadCount)' : 'Notificaciones',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onSelected: (value) => _handleMenuAction(value, provider),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'mark_all_read',
                  enabled: provider.hasUnreadNotifications, // ✅ MEJORA: Deshabilitar si no hay no leídas
                  child: Row(
                    children: [
                      Icon(
                        Icons.done_all,
                        size: 20,
                        color: provider.hasUnreadNotifications ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Marcar todas como leídas',
                        style: TextStyle(
                          color: provider.hasUnreadNotifications ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'refresh', // ✅ NUEVA: Opción de refrescar
                  child: const Row(
                    children: [
                      Icon(Icons.refresh, size: 20, color: Colors.green),
                      SizedBox(width: 12),
                      Text('Actualizar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_all',
                  enabled: provider.notifications.isNotEmpty, // ✅ MEJORA: Solo si hay notificaciones
                  child: Row(
                    children: [
                      Icon(
                        Icons.clear_all,
                        size: 20,
                        color: provider.notifications.isNotEmpty ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Limpiar todas',
                        style: TextStyle(
                          color: provider.notifications.isNotEmpty ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
      bottom: NotificationFilterTabs(
        controller: _tabController,
      ),
    );
  }

  // ✅ MEJORA: Separar body para mejor organización
  Widget _buildBody() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingWidget(message: 'Cargando notificaciones...');
        }

        if (provider.error != null) {
          return CustomErrorWidget(
            message: provider.error!,
            onRetry: () => provider.refresh(),
          );
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildNotificationList(provider.notifications, 'Todas'),
            _buildNotificationList(provider.unreadNotifications, 'No leídas'),
            _buildNotificationList(provider.getTodaysNotifications(), 'Hoy'),
          ],
        );
      },
    );
  }

  // ✅ MEJORA: Agregar parámetro de tipo para mejor UX
  Widget _buildNotificationList(List<NotificationModel> notifications, String type) {
    if (notifications.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: () async {
        final provider = Provider.of<NotificationProvider>(context, listen: false);
        await provider.refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NotificationItem(
              notification: notification,
              onTap: () => _handleNotificationTap(notification),
              onMarkAsRead: () => _markAsRead(notification.id),
              onDelete: () => _deleteNotification(notification.id),
            ),
          );
        },
      ),
    );
  }

  // ✅ MEJORA: Estado vacío más específico
  Widget _buildEmptyState(String type) {
    String message;
    String subtitle;

    switch (type) {
      case 'No leídas':
        message = 'No hay notificaciones sin leer';
        subtitle = 'Todas tus notificaciones\nhan sido leídas';
        break;
      case 'Hoy':
        message = 'No hay notificaciones de hoy';
        subtitle = 'Cuando recibas notificaciones hoy\naparecerán aquí';
        break;
      default:
        message = 'No hay notificaciones';
        subtitle = 'Cuando recibas notificaciones\naparecerán aquí';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getEmptyStateIcon(type),
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NUEVA: Iconos específicos para cada estado vacío
  IconData _getEmptyStateIcon(String type) {
    switch (type) {
      case 'No leídas':
        return Icons.mark_email_read;
      case 'Hoy':
        return Icons.today;
      default:
        return Icons.notifications_none;
    }
  }

  void _handleMenuAction(String action, NotificationProvider provider) {
    switch (action) {
      case 'mark_all_read':
        if (provider.hasUnreadNotifications) {
          provider.markAllAsRead();
          _showSuccessSnackBar('Todas las notificaciones marcadas como leídas');
        }
        break;
      case 'refresh': // ✅ NUEVA: Acción de refrescar
        provider.refresh();
        _showSuccessSnackBar('Notificaciones actualizadas');
        break;
      case 'clear_all':
        if (provider.notifications.isNotEmpty) {
          _showClearAllDialog(provider);
        }
        break;
    }
  }

  // ✅ MEJORA: Método helper para SnackBars de éxito
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showClearAllDialog(NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar notificaciones'),
        content: Text(
          '¿Estás seguro de que quieres eliminar todas las ${provider.notifications.length} notificaciones? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todas las notificaciones eliminadas'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Marcar como leída al hacer tap
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Navegar según el tipo de notificación
    switch (notification.type) {
      case NotificationType.planApproved:
      case NotificationType.planRejected:
        _navigateToPlanDetails(notification);
        break;
      default:
        _showNotificationDetails(notification);
    }
  }

  void _navigateToPlanDetails(NotificationModel notification) {
    if (notification.planId != null) {
      Navigator.pushNamed(
        context,
        '/plan-details',
        arguments: {
          'planId': notification.planId,
          'fromNotification': true,
        },
      );
    } else {
      // ✅ MEJORA: Fallback si no hay planId
      _showNotificationDetails(notification);
    }
  }

  void _showNotificationDetails(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ✅ MEJORA: Badge de tipo de notificación
              _buildNotificationTypeBadge(notification.type),
              const SizedBox(height: 12),
              // Título
              Text(
                notification.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Fecha
              Text(
                notification.formattedDate,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              // ✅ MEJORA: Botón de acción si es necesario
              if (notification.planId != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToPlanDetails(notification);
                    },
                    child: const Text('Ver Plan'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ✅ NUEVA: Badge para tipo de notificación
  Widget _buildNotificationTypeBadge(NotificationType type) {
    Color color;
    String text;

    switch (type) {
      case NotificationType.planApproved:
        color = Colors.green;
        text = 'Plan Aprobado';
        break;
      case NotificationType.planRejected:
        color = Colors.red;
        text = 'Plan Rechazado';
        break;
      default:
        color = Colors.blue;
        text = 'General';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _markAsRead(String notificationId) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.markAsRead(notificationId);
  }

  void _deleteNotification(String notificationId) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.deleteNotification(notificationId);
  }
}
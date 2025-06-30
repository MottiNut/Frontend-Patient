// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:frontendpatient/shared/widgets/notification_widgets.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';


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
    _tabController = TabController(length: 4, vsync: this);

    // Inicializar notificaciones si no están inicializadas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      if (notificationProvider.notifications.isEmpty && !notificationProvider.isLoading) {
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black87),
                onSelected: (value) => _handleMenuAction(value, provider),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, size: 20, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('Marcar todas como leídas'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Limpiar todas'),
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
      ),
      body: Consumer<NotificationProvider>(
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
              _buildNotificationList(provider.notifications),
              _buildNotificationList(provider.unreadNotifications),
              _buildNotificationList(provider.getTodaysNotifications()),
              _buildNotificationList(provider.getWeekNotifications()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No hay notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Cuando recibas notificaciones\naparecerán aquí',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, NotificationProvider provider) {
    switch (action) {
      case 'mark_all_read':
        if (provider.hasUnreadNotifications) {
          provider.markAllAsRead();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todas las notificaciones marcadas como leídas'),
              backgroundColor: Colors.green,
            ),
          );
        }
        break;
      case 'clear_all':
        _showClearAllDialog(provider);
        break;
    }
  }

  void _showClearAllDialog(NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar notificaciones'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todas las notificaciones? Esta acción no se puede deshacer.',
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
      // Navegar a la pantalla de detalles del plan
      Navigator.pushNamed(
        context,
        '/plan-details',
        arguments: {
          'planId': notification.planId,
          'fromNotification': true,
        },
      );
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
            ],
          ),
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
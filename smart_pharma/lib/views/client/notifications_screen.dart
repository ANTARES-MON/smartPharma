import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

// IMPORT YOUR NOTIFICATION PROVIDER
import '../../providers/client_notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  // 🌍 Translation Helper for Backend Notifications
  String _translateNotificationText(BuildContext context, String text) {
    final l = AppLocalizations.of(context)!;
    
    // Replace common French patterns with localized versions
   if (text.contains('Commande envoyée')) {
      text = text.replaceAll('Commande envoyée', l.orderSent);
    }
    if (text.contains('Votre commande pour')) {
      // Pattern: "Votre commande pour Amoxicilline .500mg est en attente"
      final regex = RegExp(r'Votre commande pour (.+?) est (.+)');
      final match = regex.firstMatch(text);
      if (match != null) {
        final medication = match.group(1);
        final status = match.group(2);
        
        String localizedStatus = status ?? '';
        if (status?.contains('en attente') == true) {
          localizedStatus = l.isPending;
        } else if (status?.contains('Rejected') == true || status?.contains('Refusée') == true) {
          localizedStatus = l.isRejected;
        } else if (status?.contains('Accepted') == true || status?.contains('Acceptée') == true) {
          localizedStatus = l.isAccepted;
        }
        
        text = '${l.yourOrderFor} $medication $localizedStatus';
      }
    }
    if (text.contains('Mise à jour')) {
      text = text.replaceAll('Mise à jour', l.updateTitle);
    }
    
    return text;
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. WATCH THE LIST OF NOTIFICATIONS
    final notifications = ref.watch(clientNotificationProvider);

    // 2. CALCULATE UNREAD COUNT FOR HEADER
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // ==========================================
          // HEADER (MATCHING HOME/PROFILE STYLE)
          // ==========================================
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF0D9488)], // Emerald Gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                // Top Row: Back Button & Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      AppLocalizations.of(context)!.notifications,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Placeholder to balance the row (invisible icon)
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Action Buttons Row (Mark Read / Clear)
                if (notifications.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (unreadCount > 0) ...[
                          _headerActionButton(
                            context,
                            icon: LucideIcons.checkCheck,
                            label: AppLocalizations.of(context)!.markAllRead,
                            onTap: () => ref.read(clientNotificationProvider.notifier).markAllAsRead(),
                          ),
                          Container(height: 20, width: 1, color: Colors.white30, margin: const EdgeInsets.symmetric(horizontal: 12)),
                        ],
                        _headerActionButton(
                          context,
                          icon: LucideIcons.trash2,
                          label: AppLocalizations.of(context)!.clear,
                          onTap: () => _showClearDialog(context, ref),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ==========================================
          // LIST VIEW
          // ==========================================
          Expanded(
            child: notifications.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      // Sort: Newest first logic is usually handled in provider, 
                      // but typically index 0 is newest.
                      return _buildNotificationItem(context, ref, notifications[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Helper for Header Buttons
  Widget _headerActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.bellOff, size: 40, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noNotifications,
            style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SINGLE NOTIFICATION ITEM
  // ==========================================
  Widget _buildNotificationItem(BuildContext context, WidgetRef ref, AppNotification notification) {
    // Determine style (Color/Icon) based on content
    final style = _getNotificationStyle(notification.title, notification.message);
    final bool isRead = notification.isRead;

    return GestureDetector(
      onTap: () {
        // Mark as read on tap
        if (!isRead) {
          ref.read(clientNotificationProvider.notifier).markAsRead(notification.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? const Color(0xFFF3F4F6) : Colors.white, // Grey if read, White if new
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? Colors.transparent : style.bgColor, // Colored border if new
            width: 1,
          ),
          boxShadow: isRead 
            ? [] 
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isRead ? Colors.grey[300] : style.bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                style.icon, 
                color: isRead ? Colors.grey[600] : style.iconColor, 
                size: 20
              ),
            ),
            const SizedBox(width: 16),
            
            // CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _translateNotificationText(context, notification.title),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                            color: isRead ? Colors.grey[700] : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isRead ? Colors.grey[400] : style.iconColor,
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _translateNotificationText(context, notification.message),
                    style: TextStyle(
                      fontSize: 13,
                      color: isRead ? Colors.grey[500] : Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // UTILS
  // ==========================================

  // Confirm Clear All
  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Effacer l'historique ?"),
        content: const Text("Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(clientNotificationProvider.notifier).clearAll();
              Navigator.pop(ctx);
            },
            child: Text(AppLocalizations.of(context)!.clear, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Format Time Helper
  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return "À l'instant";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min";
    if (diff.inHours < 24) return "${diff.inHours} h";
    if (diff.inDays < 7) return "${diff.inDays} j";
    return DateFormat('dd/MM').format(date);
  }

  // Determine Icon & Color based on text keywords
  _NotificationStyle _getNotificationStyle(String title, String message) {
    final text = "$title $message".toLowerCase();

    // Success / Validated
    if (text.contains('accept') || text.contains('valid') || text.contains('confirm') || text.contains('prête')) {
      return _NotificationStyle(LucideIcons.checkCircle, const Color(0xFF10B981), const Color(0xFFDCFCE7));
    } 
    // Error / Refused
    else if (text.contains('refus') || text.contains('annul') || text.contains('reject') || text.contains('erreur')) {
      return _NotificationStyle(LucideIcons.xCircle, const Color(0xFFEF4444), const Color(0xFFFEE2E2));
    } 
    // Warning / Pending
    else if (text.contains('attente') || text.contains('cours')) {
      return _NotificationStyle(LucideIcons.clock, const Color(0xFFF59E0B), const Color(0xFFFEF3C7));
    }
    // Default Info
    return _NotificationStyle(LucideIcons.info, const Color(0xFF3B82F6), const Color(0xFFDBEAFE));
  }
}

class _NotificationStyle {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  _NotificationStyle(this.icon, this.iconColor, this.bgColor);
}
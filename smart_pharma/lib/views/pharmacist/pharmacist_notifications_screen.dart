import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../providers/pharmacist_notification_provider.dart';
import '../../l10n/app_localizations.dart';

class PharmacistNotificationsScreen extends ConsumerWidget {
  const PharmacistNotificationsScreen({super.key});

  // 🌍 Translation Helper for Backend Notifications
  String _translateNotificationText(BuildContext context, String text) {
    final l = AppLocalizations.of(context)!;
    
    // CASE-INSENSITIVE: Replace common French patterns with localized versions
    final textLower = text.toLowerCase();
    
    // Pattern 1: "Nouvelle Commande" (case insensitive)
    if (textLower.contains('nouvelle commande')) {
      text = text.replaceAll(RegExp(r'Nouvelle Commande', caseSensitive: false), l.newOrder);
    }
    
    // Pattern 2: "Vous avez reçu une commande" with flexible spacing
    if (textLower.contains('vous avez reçu') || textLower.contains('vous avez recu')) {
      // Match: "Vous avez reçu une commande : Ahmed Client a commandé..."
      final regex = RegExp(r'Vous avez reçu une commande\s*:?\s*(.+)', caseSensitive: false);
      final match = regex.firstMatch(text);
      if (match != null) {
        final orderDetails = match.group(1)?.trim() ?? '';
        text = '${l.youReceivedOrder} $orderDetails';
      } else {
        // Fallback: just replace the prefix
        text = text.replaceAll(RegExp(r'Vous avez reçu une commande', caseSensitive: false), l.youReceivedOrder);
      }
    }
    
    // Pattern 3: "a commandé" → "طلب" (ordered)
    if (textLower.contains('a commandé') || textLower.contains('a commande')) {
      text = text.replaceAll(RegExp(r'a commandé', caseSensitive: false), l.ordered);
    }
    
    return text;
  }


  // Pharmacist Theme Colors
  static const Color primaryBlue = Color(0xFF2563EB); // Blue 600
  static const Color darkBlue = Color(0xFF1E40AF);    // Blue 800

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. WATCH THE LIST OF NOTIFICATIONS
    final notificationState = ref.watch(pharmacistNotificationProvider);
    final notifications = notificationState.notifications;

    // 2. CALCULATE UNREAD COUNT FOR HEADER
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // ==========================================
          // HEADER (MATCHING CLIENT STYLE)
          // ==========================================
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, darkBlue], // Blue Gradient
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
                            onTap: () => ref.read(pharmacistNotificationProvider.notifier).markAllAsRead(),
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
            child: notificationState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
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
  Widget _buildNotificationItem(BuildContext context, WidgetRef ref, PharmacistNotification notification) {
    // ENHANCED LOGIC: Generic Title & Prefixed Message
    String displayTitle = _translateNotificationText(context, notification.title);
    String displayMessage = _translateNotificationText(context, notification.message);



    // Determine style (Color/Icon) based on content/type
    final style = _getNotificationStyle(notification.type, displayTitle, displayMessage);
    final bool isRead = notification.isRead;

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          ref.read(pharmacistNotificationProvider.notifier).markAsRead(notification.id);
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
                          displayTitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                            color: isRead ? Colors.grey[700] : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(context, notification.createdAt),
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
                    displayMessage,
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
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(pharmacistNotificationProvider.notifier).clearAll();
              Navigator.pop(ctx);
            },
            child: const Text("Effacer", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Format Time Helper
  String _formatTime(BuildContext context, DateTime date) {
    final diff = DateTime.now().difference(date);
    final localizations = AppLocalizations.of(context)!;
    if (diff.inSeconds < 60) return localizations.justNow;
    if (diff.inMinutes < 60) return "${diff.inMinutes} ${localizations.minUnit}";
    if (diff.inHours < 24) return "${diff.inHours} ${localizations.hourUnit}";
    if (diff.inDays < 7) return "${diff.inDays} j";
    return DateFormat('dd/MM').format(date);
  }

  // Determine Icon & Color based on type or keywords
  _NotificationStyle _getNotificationStyle(String type, String title, String message) {
    
    // Order specific style
    if (type == 'order' || title.contains("Commande")) {
      return _NotificationStyle(LucideIcons.shoppingBag, const Color(0xFF2563EB), const Color(0xFFEFF6FF)); // Blue
    }

    final text = "$title $message".toLowerCase();

    // Success / Validated
    if (text.contains('accept') || text.contains('valid') || text.contains('confirm') || text.contains('prête')) {
      return _NotificationStyle(LucideIcons.checkCircle, const Color(0xFF10B981), const Color(0xFFDCFCE7));
    } 
    // Error / Refused
    else if (text.contains('refus') || text.contains('annul') || text.contains('reject') || text.contains('erreur') || text.contains('alert')) {
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
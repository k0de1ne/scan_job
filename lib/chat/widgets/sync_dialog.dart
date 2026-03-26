import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scan_job/chat/cubit/chat_cubit.dart';
import 'package:scan_job/chat/cubit/sync_cubit.dart';
import 'package:scan_job/chat/services/webrtc_sync_service.dart';
import 'package:scan_job/l10n/l10n.dart';
import 'package:scan_job/theme/app_theme.dart';

class SyncDialog extends StatelessWidget {
  const SyncDialog({super.key});

  static Future<void> show(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();
    return showDialog<void>(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => SyncCubit(
          syncService: WebRtcSyncService(
            signalingUrl: 'https://144.31.188.34.sslip.io/sync', 
          ),
          onSessionsReceived: chatCubit.mergeSessions,
        ),
        child: const SyncDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<SyncCubit, SyncState>(
      listener: (context, state) {
        if (state.status == SyncStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.syncDialogStatusSuccess)),
          );
        }
      },
      child: AlertDialog(
        title: Text(l10n.syncDialogTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: BlocBuilder<SyncCubit, SyncState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusContent(context, state),
                  if (state.status == SyncStatus.connected) ...[
                    SizedBox(height: context.spacing.md),
                    ElevatedButton.icon(
                      onPressed: () {
                        final sessions = context.read<ChatCubit>().state.sessions;
                        context.read<SyncCubit>().sendSessions(sessions);
                      },
                      icon: const Icon(Icons.send),
                      label: Text(l10n.syncDialogSend),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        actions: [
          if (context.watch<SyncCubit>().state.status == SyncStatus.initial) ...[
            TextButton(
              onPressed: () => context.read<SyncCubit>().startGenerating(),
              child: Text(l10n.syncDialogGenerate),
            ),
            TextButton(
              onPressed: () => _startScanningFlow(context),
              child: Text(l10n.syncDialogScan),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.syncDialogClose),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusContent(BuildContext context, SyncState state) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    switch (state.status) {
      case SyncStatus.initial:
        return Text(l10n.syncDialogStatusInitial);
      case SyncStatus.generating:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, // Всегда белый фон для QR
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: state.roomId ?? '',
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black, // Всегда черный код
              ),
            ),
            SizedBox(height: context.spacing.md),
            SelectableText(
              'Room ID: ${state.roomId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: context.spacing.sm),
            Text(
              l10n.syncDialogStatusGenerating(state.roomId ?? ''),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
          ],
        );
      case SyncStatus.scanning:
      case SyncStatus.connecting:
        return Column(
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: context.spacing.md),
            Text(state.status == SyncStatus.scanning 
              ? l10n.syncDialogStatusScanning 
              : l10n.syncDialogStatusConnecting),
          ],
        );
      case SyncStatus.connected:
        return Column(
          children: [
            const Icon(Icons.link, color: Colors.green, size: 48),
            SizedBox(height: context.spacing.md),
            Text(l10n.syncDialogStatusConnected, style: const TextStyle(color: Colors.green)),
          ],
        );
      case SyncStatus.success:
        return Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: context.spacing.md),
            Text(l10n.syncDialogStatusSuccess),
          ],
        );
      case SyncStatus.failure:
        return Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: context.spacing.md),
            Text(l10n.syncDialogStatusFailure(state.error ?? 'Unknown error'), 
              style: TextStyle(color: colorScheme.error)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _showRoomIdInput(context),
              child: const Text('Try manual entry'),
            ),
          ],
        );
    }
  }

  Future<void> _startScanningFlow(BuildContext context) async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      await _showRoomIdInput(context);
      return;
    }

    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (!context.mounted) return;
      await _showScanner(context);
    } else {
      if (!context.mounted) return;
      await _showRoomIdInput(context);
    }
  }

  Future<void> _showScanner(BuildContext context) async {
    final syncCubit = context.read<SyncCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Scan QR Code', style: TextStyle(color: Colors.white)),
        ),
        body: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                syncCubit.startScanning(barcode.rawValue!);
                Navigator.pop(context);
                break;
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _showRoomIdInput(BuildContext context) async {
    final controller = TextEditingController();
    final syncCubit = context.read<SyncCubit>();
    
    await showDialog<void>(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text('Enter Room ID'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '123456789'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final roomId = controller.text.trim();
              if (roomId.isNotEmpty) {
                syncCubit.startScanning(roomId);
                Navigator.pop(innerContext);
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}

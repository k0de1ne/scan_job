import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:scan_job/chat/models/chat_session.dart';
import 'package:scan_job/chat/services/webrtc_sync_service.dart';

enum SyncStatus { initial, generating, scanning, connecting, connected, success, failure }

class SyncState extends Equatable {
  const SyncState({
    this.status = SyncStatus.initial,
    this.roomId,
    this.connectionState = RTCPeerConnectionState.RTCPeerConnectionStateNew,
    this.error,
  });

  final SyncStatus status;
  final String? roomId;
  final RTCPeerConnectionState connectionState;
  final String? error;

  @override
  List<Object?> get props => [status, roomId, connectionState, error];

  SyncState copyWith({
    SyncStatus? status,
    String? roomId,
    RTCPeerConnectionState? connectionState,
    String? error,
  }) {
    return SyncState(
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
      connectionState: connectionState ?? this.connectionState,
      error: error ?? this.error,
    );
  }
}

class SyncCubit extends Cubit<SyncState> {
  SyncCubit({
    required this.syncService,
    this.onSessionsReceived,
  }) : super(const SyncState());

  final WebRtcSyncService syncService;
  final void Function(List<ChatSession>)? onSessionsReceived;
  StreamSubscription<String>? _dataSubscription;
  StreamSubscription<RTCPeerConnectionState>? _stateSubscription;

  void startGenerating() {
    final roomId = DateTime.now().millisecondsSinceEpoch.toString();
    emit(state.copyWith(status: SyncStatus.generating, roomId: roomId));
    unawaited(_initConnection(roomId, isHost: true));
  }

  void startScanning(String roomId) {
    emit(state.copyWith(status: SyncStatus.scanning, roomId: roomId));
    unawaited(_initConnection(roomId, isHost: false));
  }

  Future<void> _initConnection(String roomId, {required bool isHost}) async {
    try {
      await _dataSubscription?.cancel();
      await _stateSubscription?.cancel();

      _stateSubscription = syncService.onConnectionState.listen((s) {
        emit(state.copyWith(connectionState: s));
        if (s == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          emit(state.copyWith(status: SyncStatus.connected));
        }
      });

      _dataSubscription = syncService.onDataReceived.listen((data) {
        try {
          final decoded = jsonDecode(data) as List<dynamic>;
          final sessions = decoded
              .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
              .toList();
          onSessionsReceived?.call(sessions);
          emit(state.copyWith(status: SyncStatus.success));
        } on Object catch (e) {
          emit(state.copyWith(status: SyncStatus.failure, error: 'Data parse error: $e'));
        }
      });

      await syncService.connect(roomId, isHost: isHost);
    } on Object catch (e) {
      emit(state.copyWith(status: SyncStatus.failure, error: e.toString()));
    }
  }

  void sendSessions(List<ChatSession> sessions) {
    final data = jsonEncode(sessions.map((s) => s.toJson()).toList());
    syncService.sendData(data);
  }

  @override
  Future<void> close() async {
    await _dataSubscription?.cancel();
    await _stateSubscription?.cancel();
    await syncService.dispose();
    return super.close();
  }
}

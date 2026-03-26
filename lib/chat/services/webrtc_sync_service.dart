import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebRtcSyncService {
  WebRtcSyncService({required this.signalingUrl});

  final String signalingUrl;
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  WebSocketChannel? _signalingChannel;
  
  final _onDataReceivedController = StreamController<String>.broadcast();
  Stream<String> get onDataReceived => _onDataReceivedController.stream;

  final _onConnectionStateController = StreamController<RTCPeerConnectionState>.broadcast();
  Stream<RTCPeerConnectionState> get onConnectionState => _onConnectionStateController.stream;

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  Future<void> connect(String roomId, {bool isHost = false}) async {
    final baseUri = Uri.parse(signalingUrl);
    final wsUri = Uri(
      scheme: baseUri.scheme.contains('s') ? 'wss' : 'ws',
      host: baseUri.host,
      port: baseUri.port != 0 ? baseUri.port : (baseUri.scheme.contains('s') ? 443 : 80),
      path: '${baseUri.path}/ws/$roomId'.replaceAll('//', '/'),
    );

    debugPrint('Connecting to Signaling (IO): $wsUri');
    
    // Используем IOWebSocketChannel для обхода проблем с сертификатами на Windows
    try {
      final client = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true; // Игнорируем ошибки SSL для MVP
      
      final webSocket = await WebSocket.connect(wsUri.toString(), customClient: client);
      _signalingChannel = IOWebSocketChannel(webSocket);
    } on Object catch (e) {
      debugPrint('Signaling Connection Failed: $e');
      _onConnectionStateController.add(RTCPeerConnectionState.RTCPeerConnectionStateFailed);
      return;
    }
    
    _peerConnection = await createPeerConnection(_configuration);
    
    _peerConnection!.onConnectionState = (state) {
      _onConnectionStateController.add(state);
    };

    _peerConnection!.onIceCandidate = (candidate) {
      _sendSignaling({'type': 'candidate', 'candidate': candidate.toMap()});
    };

    if (isHost) {
      _dataChannel = await _peerConnection!.createDataChannel(
        'sync_channel',
        RTCDataChannelInit(),
      );
      _setupDataChannel(_dataChannel!);
      
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      _sendSignaling({'type': 'offer', 'sdp': offer.sdp});
    } else {
      _peerConnection!.onDataChannel = (channel) {
        _dataChannel = channel;
        _setupDataChannel(_dataChannel!);
      };
    }

    _signalingChannel!.stream.listen(
      (message) async {
        final data = jsonDecode(message as String);
        switch (data['type']) {
          case 'offer':
            await _peerConnection!.setRemoteDescription(
              RTCSessionDescription(data['sdp'] as String, 'offer'),
            );
            final answer = await _peerConnection!.createAnswer();
            await _peerConnection!.setLocalDescription(answer);
            _sendSignaling({'type': 'answer', 'sdp': answer.sdp});
            break;
          case 'answer':
            await _peerConnection!.setRemoteDescription(
              RTCSessionDescription(data['sdp'] as String, 'answer'),
            );
            break;
          case 'candidate':
            final candidateMap = data['candidate'] as Map<String, dynamic>;
            await _peerConnection!.addCandidate(
              RTCIceCandidate(
                candidateMap['candidate'] as String,
                candidateMap['sdpMid'] as String,
                candidateMap['sdpMLineIndex'] as int,
              ),
            );
            break;
        }
      },
      onError: (Object e) {
        debugPrint('Signaling Stream Error: $e');
        _onConnectionStateController.add(RTCPeerConnectionState.RTCPeerConnectionStateFailed);
      },
      cancelOnError: true,
    );
  }

  void _setupDataChannel(RTCDataChannel channel) {
    channel.onMessage = (data) {
      _onDataReceivedController.add(data.text);
    };
  }

  void _sendSignaling(Map<String, dynamic> data) {
    try {
      _signalingChannel?.sink.add(jsonEncode(data));
    } on Object catch (e) {
      debugPrint('Error sending signaling: $e');
    }
  }

  void sendData(String data) {
    _dataChannel?.send(RTCDataChannelMessage(data));
  }

  Future<void> dispose() async {
    await _dataChannel?.close();
    await _peerConnection?.close();
    await _signalingChannel?.sink.close();
    await _onDataReceivedController.close();
    await _onConnectionStateController.close();
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../config/app_config.dart';

enum CallState { idle, connecting, ringing, inCall, ended, failed }

class IncomingCallData {
  final String callerId;
  final String callerName;
  final String callerRole;
  final String? orderId;

  IncomingCallData({
    required this.callerId,
    required this.callerName,
    this.callerRole = '',
    this.orderId,
  });
}

class CallService {
  static io.Socket? _socket;
  static RTCPeerConnection? _peerConnection;
  static MediaStream? _localStream;
  static MediaStream? _remoteStream;

  static CallState _state = CallState.idle;
  static String? _targetUserId;
  static String? _myUserId;
  static String? _myName;
  static DateTime? _callStartTime;
  static Timer? _durationTimer;
  static int _callDuration = 0;
  static bool _isMuted = false;

  static CallState get state => _state;
  static MediaStream? get localStream => _localStream;
  static MediaStream? get remoteStream => _remoteStream;
  static bool get isMuted => _isMuted;
  static int get callDuration => _callDuration;
  static DateTime? get callStartTime => _callStartTime;
  static String? get targetUserId => _targetUserId;

  static final StreamController<CallState> _stateController = StreamController<CallState>.broadcast();
  static Stream<CallState> get stateStream => _stateController.stream;

  static final StreamController<IncomingCallData> _incomingController = StreamController<IncomingCallData>.broadcast();
  static Stream<IncomingCallData> get incomingCallStream => _incomingController.stream;

  static final StreamController<int> _durationController = StreamController<int>.broadcast();
  static Stream<int> get durationStream => _durationController.stream;

  static Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      final user = jsonDecode(userData);
      _myUserId = user['_id'] ?? user['id'] ?? '';
      _myName = user['fullName'] ?? user['name'] ?? 'Customer';
    }
  }

  static Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;
    await _loadUserData();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || _myUserId == null) return;

    _socket = io.io(AppConfig.baseUrl, io.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .disableAutoConnect()
        .build());

    _socket!.onConnect((_) {
      debugPrint('CallService: socket connected');
    });

    _socket!.onDisconnect((_) {
      debugPrint('CallService: socket disconnected');
    });

    _socket!.on('call:incoming', (data) {
      debugPrint('CallService: incoming call $data');
      final call = IncomingCallData(
        callerId: data['callerId'] ?? '',
        callerName: data['callerName'] ?? 'Unknown',
        callerRole: data['callerRole'] ?? '',
        orderId: data['orderId'],
      );
      _incomingController.add(call);
    });

    _socket!.on('call:accepted', (data) {
      debugPrint('CallService: call accepted $data');
      _setState(CallState.connecting);
      _createOffer();
    });

    _socket!.on('call:rejected', (_) {
      debugPrint('CallService: call rejected');
      _setState(CallState.ended);
      _cleanup();
    });

    _socket!.on('call:unavailable', (data) {
      debugPrint('CallService: target unavailable $data');
      _setState(CallState.failed);
      _cleanup();
    });

    _socket!.on('call:sdp', (data) async {
      final sdp = data['sdp'];
      final type = data['type'];
      if (_peerConnection == null) return;

      if (type == 'offer') {
        final remoteDesc = RTCSessionDescription(sdp, 'offer');
        await _peerConnection!.setRemoteDescription(remoteDesc);
        final answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);
        _socket!.emit('call:sdp', {
          'targetUserId': data['senderId'],
          'sdp': answer.sdp,
          'type': 'answer',
        });
        _setState(CallState.inCall);
        _startDurationTimer();
      } else if (type == 'answer') {
        final remoteDesc = RTCSessionDescription(sdp, 'answer');
        await _peerConnection!.setRemoteDescription(remoteDesc);
        _setState(CallState.inCall);
        _startDurationTimer();
      }
    });

    _socket!.on('call:ice', (data) async {
      if (_peerConnection == null) return;
      final candidate = data['candidate'];
      if (candidate != null) {
        final iceCandidate = RTCIceCandidate(
          candidate['candidate'],
          candidate['sdpMid'],
          candidate['sdpMLineIndex'],
        );
        await _peerConnection!.addCandidate(iceCandidate);
      }
    });

    _socket!.on('call:ended', (_) {
      debugPrint('CallService: call ended by remote');
      _setState(CallState.ended);
      _cleanup();
    });

    _socket!.connect();
  }

  static Future<void> _setupPeerConnection() async {
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {'urls': 'stun:stun2.l.google.com:19302'},
      ],
    });

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    });

    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    _peerConnection!.onIceCandidate = (candidate) {
      if (_targetUserId != null) {
        _socket!.emit('call:ice', {
          'targetUserId': _targetUserId,
          'candidate': candidate.toMap(),
        });
      }
    };

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
      }
    };

    _peerConnection!.onIceConnectionState = (state) {
      debugPrint('CallService: ICE state $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
          state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
        endCall();
      }
    };
  }

  static Future<void> _createOffer() async {
    if (_peerConnection == null || _targetUserId == null) return;
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    _socket!.emit('call:sdp', {
      'targetUserId': _targetUserId,
      'sdp': offer.sdp,
      'type': 'offer',
    });
  }

  static Future<void> initiateCall(String targetUserId, {String? orderId}) async {
    await connect();
    if (_socket == null || !_socket!.connected) return;
    _setState(CallState.ringing);
    _targetUserId = targetUserId;
    await _setupPeerConnection();
    _socket!.emit('call:initiate', {
      'targetUserId': targetUserId,
      'orderId': orderId,
      'callerName': _myName,
      'callerRole': 'customer',
    });
  }

  static Future<void> acceptCall(IncomingCallData call) async {
    await connect();
    if (_socket == null || !_socket!.connected) return;
    _targetUserId = call.callerId;
    await _setupPeerConnection();
    _socket!.emit('call:accept', {'callerId': call.callerId});
  }

  static Future<void> rejectCall(String callerId) async {
    await connect();
    _socket?.emit('call:reject', {'callerId': callerId});
  }

  static Future<void> endCall() async {
    if (_targetUserId != null) {
      _socket?.emit('call:end', {'targetUserId': _targetUserId});
    }
    _setState(CallState.ended);
    await _cleanup();
  }

  static void toggleMute() {
    _isMuted = !_isMuted;
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !_isMuted;
    });
  }

  static void _startDurationTimer() {
    _callStartTime = DateTime.now();
    _callDuration = 0;
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_callStartTime != null) {
        _callDuration = DateTime.now().difference(_callStartTime!).inSeconds;
        _durationController.add(_callDuration);
      }
    });
  }

  static void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  static void _setState(CallState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  static Future<void> _cleanup() async {
    _stopDurationTimer();
    _callDuration = 0;
    _callStartTime = null;
    _isMuted = false;

    try {
      _localStream?.getTracks().forEach((track) => track.stop());
      await _localStream?.dispose();
    } catch (_) {}
    _localStream = null;

    try {
      await _remoteStream?.dispose();
    } catch (_) {}
    _remoteStream = null;

    try {
      await _peerConnection?.close();
      await _peerConnection?.dispose();
    } catch (_) {}
    _peerConnection = null;

    _targetUserId = null;
    if (_state != CallState.failed) {
      _setState(CallState.idle);
    }
  }

  static String formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static Future<void> dispose() async {
    await _cleanup();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    await _stateController.close();
    await _incomingController.close();
    await _durationController.close();
  }
}

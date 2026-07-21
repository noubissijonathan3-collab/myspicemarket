import 'dart:async';
import 'package:flutter/material.dart';
import '../services/call_service.dart';

class CallScreen extends StatefulWidget {
  final String targetUserId;
  final String targetName;
  final String? orderId;
  final bool isIncoming;
  final IncomingCallData? incomingCallData;

  const CallScreen({
    super.key,
    required this.targetUserId,
    required this.targetName,
    this.orderId,
    this.isIncoming = false,
    this.incomingCallData,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  StreamSubscription<CallState>? _stateSub;
  StreamSubscription<int>? _durationSub;
  CallState _callState = CallState.idle;
  int _duration = 0;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _stateSub = CallService.stateStream.listen((state) {
      if (mounted) setState(() => _callState = state);
      if (state == CallState.ended || state == CallState.failed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    });

    _durationSub = CallService.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _initCall();
  }

  Future<void> _initCall() async {
    if (widget.isIncoming && widget.incomingCallData != null) {
      await CallService.acceptCall(widget.incomingCallData!);
    } else {
      await CallService.initiateCall(
        widget.targetUserId,
        orderId: widget.orderId,
      );
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _durationSub?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _stateLabel() {
    switch (_callState) {
      case CallState.idle:
        return 'Initializing...';
      case CallState.connecting:
        return 'Connecting...';
      case CallState.ringing:
        return 'Ringing...';
      case CallState.inCall:
        return CallService.formatDuration(_duration);
      case CallState.ended:
        return 'Call Ended';
      case CallState.failed:
        return 'Unavailable';
    }
  }

  Color _stateColor() {
    switch (_callState) {
      case CallState.inCall:
        return const Color(0xFF198754);
      case CallState.ringing:
        return Colors.orange;
      case CallState.failed:
        return Colors.red;
      case CallState.ended:
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _endCall();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildCallerAvatar(),
              const SizedBox(height: 24),
              Text(
                widget.targetName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _stateColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_callState == CallState.ringing || _callState == CallState.connecting)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                      ),
                    if (_callState == CallState.ringing || _callState == CallState.connecting)
                      const SizedBox(width: 8),
                    Text(
                      _stateLabel(),
                      style: TextStyle(
                        color: _callState == CallState.inCall ? Colors.white70 : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              if (_callState == CallState.inCall)
                _buildCallerAvatar()
              else if (_callState == CallState.ringing && !widget.isIncoming)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: _buildAvatarCircle(),
                    );
                  },
                )
              else
                _buildAvatarCircle(),
              const Spacer(flex: 2),
              if (_callState == CallState.inCall)
                _buildInCallControls()
              else if (_callState == CallState.ringing && widget.isIncoming)
                _buildIncomingControls()
              else
                _buildEndButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCircle() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _stateColor().withOpacity(0.15),
      ),
      child: Icon(
        Icons.person,
        size: 80,
        color: _stateColor().withOpacity(0.6),
      ),
    );
  }

  Widget _buildCallerAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [_stateColor().withOpacity(0.8), _stateColor().withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _stateColor().withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.targetName.isNotEmpty ? widget.targetName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildInCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: _isMuted ? Icons.mic_off : Icons.mic,
          label: _isMuted ? 'Unmute' : 'Mute',
          onTap: () {
            setState(() => _isMuted = !_isMuted);
            CallService.toggleMute();
          },
        ),
        _buildEndButton(),
        _buildControlButton(
          icon: Icons.volume_up,
          label: 'Speaker',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildIncomingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.call_end,
          label: 'Decline',
          color: Colors.red,
          onTap: () {
            CallService.rejectCall(widget.incomingCallData?.callerId ?? widget.targetUserId);
            Navigator.pop(context);
          },
        ),
        _buildControlButton(
          icon: Icons.call,
          label: 'Accept',
          color: const Color(0xFF198754),
          onTap: () => _initCall(),
        ),
      ],
    );
  }

  Widget _buildEndButton() {
    return _buildControlButton(
      icon: Icons.call_end,
      label: 'End Call',
      color: Colors.red,
      onTap: _endCall,
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.withOpacity(0.15),
              border: Border.all(color: c.withOpacity(0.3)),
            ),
            child: Icon(icon, color: c, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: c.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }

  void _endCall() async {
    await CallService.endCall();
    if (mounted) Navigator.pop(context);
  }
}

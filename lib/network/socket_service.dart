import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:momos/network/api_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  // Singleton instance
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnecting = false;

  // Reconnection configuration
  static const int _maxReconnectAttempts = 5;
  static const int _reconnectDelayMs = 3000;
  static const int _connectionTimeoutMs = 10000;

  bool get isConnected => _socket?.connected ?? false;
  IO.Socket? get socket => _socket;

  final _orderStatusStreamController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get onOrderStatusReceived =>
      _orderStatusStreamController.stream;

  final _reservationStatusStreamController =
      StreamController<dynamic>.broadcast();
  Stream<dynamic> get onReservationStatusReceived =>
      _reservationStatusStreamController.stream;

  Future<void> connect({required String userToken}) async {
    // Prevent duplicate connections
    if (_socket != null && _socket!.connected) {
      debugPrint("SOCKET => Already connected.");
      return;
    }

    if (_isConnecting) {
      debugPrint("SOCKET => Connection already in progress...");
      return;
    }

    _isConnecting = true;

    // Clean up any existing dead socket instance
    _cleanupSocket();

    debugPrint("SOCKET URL => ${ApiServices.baseUrl}");
    debugPrint("USER TOKEN => $userToken");

    try {
      _socket = IO.io(
        ApiServices.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': userToken})
            .enableReconnection()
            .setReconnectionAttempts(_maxReconnectAttempts)
            .setReconnectionDelay(_reconnectDelayMs)
            .setTimeout(_connectionTimeoutMs)
            .disableAutoConnect()
            .build(),
      );

      // --- Connection Lifecycle Listeners ---
      _socket!.onConnect((_) {
        _isConnecting = false;
        debugPrint('✅ Socket connected successfully [ID: ${_socket?.id}]');
      });

      _socket!.onConnectError((data) {
        _isConnecting = false;
        debugPrint('❌ Socket Connect Error: $data');
      });

      _socket!.onError((data) {
        debugPrint('❌ Socket General Error: $data');
      });

      _socket!.onDisconnect((reason) {
        _isConnecting = false;
        debugPrint('🔌 Socket disconnected. Reason: $reason');
      });

      _socket!.onReconnectAttempt((attempt) {
        debugPrint(
          '🔄 Socket reconnect attempt: $attempt / $_maxReconnectAttempts',
        );
      });

      _socket!.onReconnect((_) {
        debugPrint('✅ Socket reconnected successfully');
      });

      _socket!.onReconnectFailed((_) {
        _isConnecting = false;
        debugPrint(
          '🛑 Socket reconnection failed after $_maxReconnectAttempts attempts. Giving up.',
        );
      });

      // --- Custom Event Listeners ---
      _socket!.on('authenticated', (data) {
        debugPrint('🛡️ Socket authenticated: $data');
      });

      _socket!.on('auth-error', (data) {
        debugPrint(
          '🚫 Socket Auth failed: ${data is Map ? data['message'] : data}',
        );
        disconnect();
      });

      _socket!.on('orderStatusUpdate', (data) {
        debugPrint('📦 Order status update: $data');
        if (!_orderStatusStreamController.isClosed) {
          _orderStatusStreamController.add(data);
        }
      });

      _socket!.on('bookingStatusUpdate', (data) {
        debugPrint('📦 Reservation status update: $data');
        if (!_reservationStatusStreamController.isClosed) {
          _reservationStatusStreamController.add(data);
        }
      });

      // Trigger connection explicitly
      _socket!.connect();
    } catch (e) {
      _isConnecting = false;
      debugPrint('🚨 Socket initialization exception: $e');
    }
  }

  // Chat room management
  void joinChatRoom({required String outlateId, required String userId}) {
    if (_socket != null && _socket!.connected) {
      debugPrint('🚪 Joining chat room: outletId=$outlateId, userId=$userId');
      _socket!.emit('join-chat-room', {
        'outlateId': outlateId,
        'userId': userId,
      });
    } else {
      debugPrint('⚠️ Cannot join chat room: Socket is not connected');
    }
  }

  void leaveChatRoom({required String outlateId, required String userId}) {
    if (_socket != null && _socket!.connected) {
      debugPrint('🚪 Leaving chat room: outletId=$outlateId, userId=$userId');
      _socket!.emit('leave-chat-room', {
        'outlateId': outlateId,
        'userId': userId,
      });
    }
  }

  void disconnect() {
    _cleanupSocket();
    _isConnecting = false;
  }

  void _cleanupSocket() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.clearListeners();
      _socket!.dispose();
      _socket = null;
    }
  }
}

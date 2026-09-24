// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/utils/const_key.dart';

// Connection states for the SocketService.
enum SocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class SocketService with WidgetsBindingObserver {
  // Singleton instance
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  SocketService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  IO.Socket? _socket;
  String? _cachedUserToken;
  bool _isConnecting = false;
  bool _intentionalDisconnect = false;
  bool _wasConnectedBefore = false;
  bool _isInChatRoom = false;

  SocketConnectionState _connectionState = SocketConnectionState.disconnected;

  // Reconnection configuration
  static const int _connectionTimeoutMs = 15000;
  static const int _initialReconnectDelayMs = 2000;
  static const int _maxReconnectDelayMs = 10000;

  Timer? _reconnectTimer;
  Timer? _connectTimeoutTimer;
  int _reconnectAttempts = 0;

  // Stream controllers
  final _connectionStateStreamController =
      StreamController<SocketConnectionState>.broadcast();
  final _reconnectedStreamController = StreamController<void>.broadcast();
  final _orderStatusStreamController = StreamController<dynamic>.broadcast();
  final _reservationStatusStreamController =
      StreamController<dynamic>.broadcast();
  final _chatMessageStreamController = StreamController<dynamic>.broadcast();

  // Public getters
  bool get isConnected =>
      _socket?.connected == true &&
      _connectionState == SocketConnectionState.connected;
  bool get isConnecting => _connectionState == SocketConnectionState.connecting;
  bool get isReconnecting =>
      _connectionState == SocketConnectionState.reconnecting;
  bool get isDisconnected =>
      _connectionState == SocketConnectionState.disconnected;

  SocketConnectionState get state => _connectionState;
  SocketConnectionState get connectionState => _connectionState;
  IO.Socket? get socket => _socket;

  Stream<SocketConnectionState> get onConnectionStateChanged =>
      _connectionStateStreamController.stream;
  Stream<void> get onReconnected => _reconnectedStreamController.stream;
  Stream<dynamic> get onOrderStatusReceived =>
      _orderStatusStreamController.stream;
  Stream<dynamic> get onReservationStatusReceived =>
      _reservationStatusStreamController.stream;
  Stream<dynamic> get onChatMessageReceived =>
      _chatMessageStreamController.stream;

  // Helper to safely retrieve token from GetStorage
  String? _getStoredToken() {
    try {
      final storage = GetStorage();
      if (storage.read(loginTrue) != true) return null;
      final raw = storage.read(userToken);
      if (raw == null || raw is! String || raw.isEmpty) return null;
      return raw.replaceFirst('Bearer ', '').trim();
    } catch (e) {
      debugPrint("SOCKET => Error reading stored token: $e");
      return null;
    }
  }

  // Update connection state and notify listeners
  void _updateState(SocketConnectionState newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      if (!_connectionStateStreamController.isClosed) {
        _connectionStateStreamController.add(newState);
      }
      debugPrint("SOCKET => Connection State: $newState");
    }
  }

  // Connect to the socket server using the provided or stored token
  Future<void> connect({String? userToken}) async {
    _intentionalDisconnect = false;

    final token = (userToken != null && userToken.isNotEmpty)
        ? userToken
        : (_cachedUserToken ?? _getStoredToken());

    if (token == null || token.isEmpty) {
      debugPrint("SOCKET => No user token available. Skipping connection.");
      _updateState(SocketConnectionState.disconnected);
      return;
    }

    // If token has changed, force a clean reconnection
    if (_cachedUserToken != null && _cachedUserToken != token) {
      debugPrint("SOCKET => Auth token changed. Re-initializing socket...");
      _cleanupSocket();
    }
    _cachedUserToken = token;

    // Prevent duplicate connections if already alive and connected
    if (_socket != null && _socket!.connected) {
      debugPrint("SOCKET => Already connected.");
      _updateState(SocketConnectionState.connected);
      return;
    }

    if (_isConnecting) {
      debugPrint("SOCKET => Connection already in progress...");
      return;
    }

    _isConnecting = true;
    _updateState(SocketConnectionState.connecting);

    // Clean up any existing dead socket instance before creating a new one
    _cleanupSocket();

    debugPrint("SOCKET URL => ${ApiServices.baseUrl}");

    try {
      _socket = IO.io(
        ApiServices.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableReconnection()
            .setReconnectionDelay(_initialReconnectDelayMs)
            .setReconnectionDelayMax(_maxReconnectDelayMs)
            .setRandomizationFactor(0.5)
            .setTimeout(_connectionTimeoutMs)
            .disableAutoConnect()
            .build(),
      );

      // Timeout safety watchdog for the initial connect attempt
      _connectTimeoutTimer?.cancel();
      _connectTimeoutTimer = Timer(
        const Duration(milliseconds: _connectionTimeoutMs + 3000),
        () {
          if (_isConnecting && !isConnected) {
            debugPrint("SOCKET => Connect attempt timed out.");
            _isConnecting = false;
            _updateState(SocketConnectionState.error);
            _scheduleReconnect();
          }
        },
      );

      // --- Connection Lifecycle Listeners ---
      _socket!.onConnect((_) {
        _isConnecting = false;
        _connectTimeoutTimer?.cancel();
        _cancelReconnectTimer();
        _updateState(SocketConnectionState.connected);
        debugPrint('✅ Socket connected successfully [ID: ${_socket?.id}]');

        // Re-join chat room if previously active
        if (_isInChatRoom) {
          debugPrint('🚪 Auto-joining chat room on connect');
          _socket?.emit('join-chat-room');
        }

        // Notify subscribers that connection is restored
        if (_wasConnectedBefore) {
          debugPrint('🔄 Socket reconnected: notifying listeners');
          if (!_reconnectedStreamController.isClosed) {
            _reconnectedStreamController.add(null);
          }
        }
        _wasConnectedBefore = true;
      });

      _socket!.onConnectError((data) {
        _isConnecting = false;
        _connectTimeoutTimer?.cancel();
        debugPrint('❌ Socket Connect Error: $data');
        _updateState(SocketConnectionState.error);
        _scheduleReconnect();
      });

      _socket!.onError((data) {
        debugPrint('❌ Socket General Error: $data');
        _updateState(SocketConnectionState.error);
      });

      _socket!.onDisconnect((reason) {
        _isConnecting = false;
        _connectTimeoutTimer?.cancel();
        debugPrint('🔌 Socket disconnected. Reason: $reason');

        if (_intentionalDisconnect) {
          _updateState(SocketConnectionState.disconnected);
        } else {
          _updateState(SocketConnectionState.reconnecting);
          // If server forcefully closed connection, auto-reconnect fallback
          if (reason == 'io server disconnect' || reason == 'forced close') {
            _scheduleReconnect();
          }
        }
      });

      _socket!.onReconnectAttempt((attempt) {
        debugPrint('🔄 Socket reconnect attempt: $attempt');
        _updateState(SocketConnectionState.reconnecting);
      });

      _socket!.onReconnect((_) {
        _isConnecting = false;
        _cancelReconnectTimer();
        _updateState(SocketConnectionState.connected);
        debugPrint('✅ Socket reconnected successfully');

        // Re-join chat room if active
        if (_isInChatRoom) {
          debugPrint('🚪 Auto-joining chat room on reconnect');
          _socket?.emit('join-chat-room');
        }

        // Notify listeners that reconnection occurred
        if (!_reconnectedStreamController.isClosed) {
          _reconnectedStreamController.add(null);
        }
      });

      _socket!.onReconnectFailed((_) {
        _isConnecting = false;
        debugPrint(
          '🛑 Socket built-in reconnect failed. Scheduling fallback...',
        );
        _updateState(SocketConnectionState.error);
        _scheduleReconnect();
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
        try {
          if (!_orderStatusStreamController.isClosed) {
            _orderStatusStreamController.add(data);
          }
        } catch (e) {
          debugPrint('❌ Error handling orderStatusUpdate: $e');
        }
      });

      _socket!.on('bookingStatusUpdate', (data) {
        debugPrint('📦 Reservation status update: $data');
        try {
          if (!_reservationStatusStreamController.isClosed) {
            _reservationStatusStreamController.add(data);
          }
        } catch (e) {
          debugPrint('❌ Error handling bookingStatusUpdate: $e');
        }
      });

      _socket!.on('newMessage', (data) {
        debugPrint('📦 New message: $data');
        try {
          if (!_chatMessageStreamController.isClosed) {
            _chatMessageStreamController.add(data);
          }
        } catch (e) {
          debugPrint('❌ Error handling newMessage: $e');
        }
      });

      // Trigger connection explicitly
      _socket!.connect();
    } catch (e) {
      _isConnecting = false;
      _connectTimeoutTimer?.cancel();
      debugPrint('🚨 Socket initialization exception: $e');
      _updateState(SocketConnectionState.error);
      _scheduleReconnect();
    }
  }

  // Manually trigger a reconnect
  Future<void> reconnect() async {
    debugPrint("SOCKET => Manual reconnect requested");
    _cleanupSocket();
    await connect();
  }

  // Schedule a fallback reconnect with exponential backoff
  void _scheduleReconnect() {
    if (_intentionalDisconnect) return;
    if (_reconnectTimer?.isActive ?? false) return;

    // Calculate delay with backoff: 3s, 6s, 12s, max 30s
    final delaySeconds = math.min(
      3 * math.pow(2, _reconnectAttempts).toInt(),
      30,
    );
    _reconnectAttempts++;

    debugPrint(
      "SOCKET => Scheduling fallback reconnect in ${delaySeconds}s (attempt #$_reconnectAttempts)",
    );
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (_intentionalDisconnect) return;
      if (!isConnected) {
        debugPrint("SOCKET => Executing fallback reconnect...");
        connect();
      }
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
  }

  // Check connection status on app resume and reconnect if dropped
  void _checkAndReconnectIfNeeded() {
    if (_intentionalDisconnect) return;
    final token = _cachedUserToken ?? _getStoredToken();
    if (token == null || token.isEmpty) return;

    if (_socket == null || !_socket!.connected) {
      debugPrint(
        "SOCKET => App resumed and socket is disconnected. Reconnecting...",
      );
      _cancelReconnectTimer();
      connect(userToken: token);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint(
        "SOCKET => App resumed from background. Checking connection...",
      );
      _checkAndReconnectIfNeeded();
    }
  }

  // Safe emit helper
  bool emit(String event, [dynamic data]) {
    if (_socket != null && _socket!.connected) {
      try {
        if (data != null) {
          _socket!.emit(event, data);
        } else {
          _socket!.emit(event);
        }
        return true;
      } catch (e) {
        debugPrint("⚠️ Socket emit error ($event): $e");
        return false;
      }
    } else {
      debugPrint("⚠️ Cannot emit '$event': Socket is not connected");
      return false;
    }
  }

  // Chat room management
  void joinChatRoom() {
    _isInChatRoom = true;
    if (isConnected) {
      debugPrint('🚪 Joining chat room');
      _socket!.emit('join-chat-room');
    } else {
      debugPrint('ℹ️ Chat room marked as active (will join when connected)');
    }
  }

  void leaveChatRoom() {
    _isInChatRoom = false;
    if (isConnected) {
      debugPrint('🚪 Leaving chat room');
      _socket!.emit('leave-chat-room');
    }
  }

  // Clean disconnect (e.g. on user logout)
  void disconnect() {
    _intentionalDisconnect = true;
    _isInChatRoom = false;
    _isConnecting = false;
    _cachedUserToken = null;
    _connectTimeoutTimer?.cancel();
    _cancelReconnectTimer();
    _cleanupSocket();
    _updateState(SocketConnectionState.disconnected);
  }

  void _cleanupSocket() {
    if (_socket != null) {
      try {
        _socket!.disconnect();
        _socket!.clearListeners();
        _socket!.dispose();
      } catch (e) {
        debugPrint("SOCKET => Error cleaning up socket: $e");
      } finally {
        _socket = null;
      }
    }
  }

  // Complete disposal
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
    _connectionStateStreamController.close();
    _reconnectedStreamController.close();
    _orderStatusStreamController.close();
    _reservationStatusStreamController.close();
    _chatMessageStreamController.close();
  }
}

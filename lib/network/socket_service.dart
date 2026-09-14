import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/utils/const_key.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:http/http.dart' as http;

// =============================================================================
// 1. Connection State
// =============================================================================

enum SocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

extension SocketConnectionStateX on SocketConnectionState {
  bool get isConnected => this == SocketConnectionState.connected;
  bool get isConnecting => this == SocketConnectionState.connecting;
  bool get isReconnecting => this == SocketConnectionState.reconnecting;
  bool get isDisconnected => this == SocketConnectionState.disconnected;
  bool get hasError => this == SocketConnectionState.error;
}

// =============================================================================
// 2. Event Names & Models (Order Management, Support Chat, Notifications)
// =============================================================================

class SocketEvents {
  // Support Chat
  static const String sendMessage = 'send_message';
  static const String receiveMessage = 'receive_message';

  // Order Management
  static const String subscribeOrder = 'subscribe_order';
  static const String unsubscribeOrder = 'unsubscribe_order';
  static const String orderStatusUpdate = 'order_status_update';

  // Notifications
  static const String newNotification = 'new_notification';
}

/// Chat message payload for Support Chat
class ChatMessagePayload {
  final String? messageId;
  final String text;
  final String? senderId;
  final String? senderName;
  final bool isUser;
  final String timestamp;

  ChatMessagePayload({
    this.messageId,
    required this.text,
    this.senderId,
    this.senderName,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessagePayload.fromJson(dynamic json) {
    if (json is String) {
      try {
        json = jsonDecode(json);
      } catch (_) {
        return ChatMessagePayload(
          text: json,
          isUser: false,
          timestamp: DateTime.now().toIso8601String(),
        );
      }
    }
    final map = json is Map ? json : <String, dynamic>{};
    return ChatMessagePayload(
      messageId: map['messageId']?.toString() ?? map['id']?.toString(),
      text: map['text']?.toString() ?? map['message']?.toString() ?? '',
      senderId: map['senderId']?.toString(),
      senderName: map['senderName']?.toString() ?? map['sender']?.toString(),
      isUser: map['isUser'] == true || map['senderType'] == 'user',
      timestamp:
          map['timestamp']?.toString() ??
          map['time']?.toString() ??
          DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (messageId != null) 'messageId': messageId,
    'text': text,
    if (senderId != null) 'senderId': senderId,
    if (senderName != null) 'senderName': senderName,
    'isUser': isUser,
    'timestamp': timestamp,
  };
}

/// Order status payload for Order Tracking
class OrderStatusPayload {
  final String orderId;
  final String status;
  final String? title;
  final String? description;
  final DateTime timestamp;

  OrderStatusPayload({
    required this.orderId,
    required this.status,
    this.title,
    this.description,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory OrderStatusPayload.fromJson(dynamic json) {
    if (json is String) {
      try {
        json = jsonDecode(json);
      } catch (_) {
        return OrderStatusPayload(orderId: '', status: json);
      }
    }
    final map = json is Map ? json : <String, dynamic>{};
    return OrderStatusPayload(
      orderId: map['orderId']?.toString() ?? map['id']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Unknown',
      title: map['title']?.toString(),
      description: map['description']?.toString() ?? map['message']?.toString(),
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'status': status,
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Notification payload for In-App Live Notifications
class NotificationPayload {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  NotificationPayload({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory NotificationPayload.fromJson(dynamic json) {
    if (json is String) {
      try {
        json = jsonDecode(json);
      } catch (_) {
        return NotificationPayload(id: '', title: '', body: json);
      }
    }
    final map = json is Map ? json : <String, dynamic>{};
    return NotificationPayload(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? map['message']?.toString() ?? '',
      data: map['data'] is Map<String, dynamic> ? map['data'] : null,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// =============================================================================
// 3. Subscription & Memory Leak Guard
// =============================================================================

typedef SocketEventHandler<T> = void Function(T data);

/// Subscription token to unsubscribe cleanly when screens close
class SocketSubscription {
  final String event;
  final void Function() onCancel;
  bool _isCancelled = false;

  SocketSubscription({required this.event, required this.onCancel});

  bool get isCancelled => _isCancelled;

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    onCancel();
  }
}

/// Container for managing and mass-cancelling feature subscriptions
class SocketSubscriptionBag {
  final List<SocketSubscription> _subscriptions = [];

  void add(SocketSubscription subscription) {
    if (subscription.isCancelled) return;
    _subscriptions.add(subscription);
  }

  void cancelAll() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  int get count => _subscriptions.where((s) => !s.isCancelled).length;
}

// =============================================================================
// 4. Safe Logging (Masks Tokens, Bearer headers, and Passwords)
// =============================================================================

class SocketLogger {
  static bool enableLogging = kDebugMode;
  static const String _tag = '[SocketService]';

  static final RegExp _jwtRegex = RegExp(
    r'eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+',
  );
  static final RegExp _bearerRegex = RegExp(
    r'Bearer\s+([a-zA-Z0-9_\-\.]+)',
    caseSensitive: false,
  );
  static final RegExp _sensitiveKeysRegex = RegExp(
    r'"(token|password|secretId|authorization|secret|accessToken|refreshToken)"\s*:\s*"([^"]+)"',
    caseSensitive: false,
  );

  static String sanitize(dynamic message) {
    if (message == null) return 'null';
    String text = message.toString();

    text = text.replaceAllMapped(_bearerRegex, (match) {
      final token = match.group(1) ?? '';
      return 'Bearer ${_maskString(token)}';
    });

    text = text.replaceAllMapped(_jwtRegex, (match) {
      return _maskString(match.group(0) ?? '');
    });

    text = text.replaceAllMapped(_sensitiveKeysRegex, (match) {
      final key = match.group(1);
      final value = match.group(2) ?? '';
      return '"$key": "${_maskString(value)}"';
    });

    return text;
  }

  static String _maskString(String value) {
    if (value.length <= 8) return '***';
    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }

  static void info(String message) {
    if (!enableLogging) return;
    debugPrint('$_tag ℹ️ ${sanitize(message)}');
  }

  static void success(String message) {
    if (!enableLogging) return;
    debugPrint('$_tag ✅ ${sanitize(message)}');
  }

  static void warning(String message) {
    if (!enableLogging) return;
    debugPrint('$_tag ⚠️ ${sanitize(message)}');
  }

  static void error(String message, [dynamic error]) {
    if (!enableLogging) return;
    debugPrint('$_tag ❌ ${sanitize(message)}');
    if (error != null) {
      debugPrint('$_tag ❌ Details: ${sanitize(error)}');
    }
  }

  static void event(String direction, String eventName, [dynamic data]) {
    if (!enableLogging) return;
    final sanitizedData = data != null ? sanitize(data) : 'no payload';
    debugPrint(
      '$_tag $direction Event: "$eventName" | Payload: $sanitizedData',
    );
  }
}

// =============================================================================
// 5. Centralized SocketService
// =============================================================================

/// Global, production-ready Socket.IO service for MomoApp.
/// Controls single socket connection, auth sync, lifecycle & multiplexed events.
class SocketService extends GetxService with WidgetsBindingObserver {
  static SocketService get to => Get.find<SocketService>();

  final GetStorage _storage = GetStorage();
  io.Socket? _socket;

  final Rx<SocketConnectionState> connectionState =
      SocketConnectionState.disconnected.obs;

  bool get isConnected => connectionState.value.isConnected;
  bool get isConnecting => connectionState.value.isConnecting;
  bool get isReconnecting => connectionState.value.isReconnecting;
  bool get isDisconnected => connectionState.value.isDisconnected;

  // Lock to prevent concurrent connect() calls
  bool _isConnectingLock = false;

  // Multiplexed listener registry: Event -> Handlers
  final Map<String, Set<SocketEventHandler<dynamic>>> _eventListeners = {};

  String? _currentToken;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    SocketLogger.info('SocketService initialized.');
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect(clearListeners: true);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      final isLoggedIn = _storage.read(loginTrue) == true;
      if (isLoggedIn && (isDisconnected || connectionState.value.hasError)) {
        SocketLogger.info('App resumed: reconnecting socket...');
        connect();
      }
    }
  }

  /// Establishes the single Socket.IO connection.
  Future<void> connect({
    String? customToken,
    bool forceReconnect = false,
  }) async {
    if (_isConnectingLock) {
      SocketLogger.warning('Connection attempt blocked: already in progress.');
      return;
    }

    if (_socket != null && _socket!.connected && !forceReconnect) {
      SocketLogger.info('Socket already connected. Duplicate connect ignored.');
      connectionState.value = SocketConnectionState.connected;
      return;
    }

    _isConnectingLock = true;
    connectionState.value = SocketConnectionState.connecting;

    try {
      final rawToken = customToken ?? _storage.read(userToken)?.toString();
      _currentToken = _extractRawToken(rawToken);
      final bearerToken = _currentToken != null
          ? 'Bearer $_currentToken'
          : null;

      if (_socket != null) {
        _teardownSocket();
      }

      print("USER TOKEN :- $bearerToken");

      await socketConnectApi(userToken: bearerToken);

      final url = ApiServices.socketUrl;
      SocketLogger.info('Connecting to Socket.IO at: $url');

      final optionsBuilder = io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(double.maxFinite.toInt())
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setTimeout(20000);

      final authMap = <String, dynamic>{};
      final headersMap = <String, String>{};

      if (_currentToken != null && _currentToken!.isNotEmpty) {
        authMap['token'] = _currentToken;
        if (bearerToken != null) {
          headersMap['Authorization'] = bearerToken;
        }
      }

      if (authMap.isNotEmpty) optionsBuilder.setAuth(authMap);
      if (headersMap.isNotEmpty) optionsBuilder.setExtraHeaders(headersMap);

      _socket = io.io(url, optionsBuilder.build());
      _bindSocketLifecycleEvents();
      _rebindAllRegisteredListeners();
      _socket?.connect();
    } catch (e) {
      connectionState.value = SocketConnectionState.error;
      SocketLogger.error('Socket connection error', e);
    } finally {
      _isConnectingLock = false;
    }
  }

  /// Disconnects the socket and optionally clears listeners
  void disconnect({bool clearListeners = false}) {
    SocketLogger.info(
      'Disconnecting socket (clearListeners=$clearListeners)...',
    );

    if (clearListeners) {
      _eventListeners.clear();
    }

    _teardownSocket();
    _currentToken = null;
    connectionState.value = SocketConnectionState.disconnected;
    _isConnectingLock = false;
  }

  /// Auth login hook
  Future<void> onLogin([String? token]) async {
    await connect(customToken: token, forceReconnect: true);
  }

  /// Auth logout hook
  void onLogout() {
    disconnect(clearListeners: true);
  }

  /// Subscribe to a socket event. Multiplexes single listener on native socket.
  SocketSubscription on<T>(String event, void Function(T data) handler) {
    void genericHandler(dynamic data) {
      try {
        if (data is T) {
          handler(data);
        } else if (T == String) {
          handler(data.toString() as T);
        } else {
          handler(data as T);
        }
      } catch (e) {
        SocketLogger.error('Error invoking handler for "$event"', e);
      }
    }

    final isFirstListener =
        !_eventListeners.containsKey(event) || _eventListeners[event]!.isEmpty;
    _eventListeners
        .putIfAbsent(event, () => <SocketEventHandler<dynamic>>{})
        .add(genericHandler);

    if (isFirstListener && _socket != null) {
      _attachSocketEventListener(event);
    }

    return SocketSubscription(
      event: event,
      onCancel: () => off(event, genericHandler),
    );
  }

  /// Remove listener or all listeners for an event
  void off(String event, [SocketEventHandler<dynamic>? handler]) {
    if (!_eventListeners.containsKey(event)) return;

    if (handler != null) {
      _eventListeners[event]?.remove(handler);
    } else {
      _eventListeners[event]?.clear();
    }

    if (_eventListeners[event] == null || _eventListeners[event]!.isEmpty) {
      _eventListeners.remove(event);
      _socket?.off(event);
      SocketLogger.info('Detached native listener for "$event".');
    }
  }

  /// Emit event to server with safe logging
  void emit(String event, [dynamic data, Function? ack]) {
    SocketLogger.event('📤 Outgoing', event, data);
    try {
      if (ack != null) {
        _socket?.emitWithAck(event, data, ack: ack);
      } else {
        if (data != null) {
          _socket?.emit(event, data);
        } else {
          _socket?.emit(event);
        }
      }
    } catch (e) {
      SocketLogger.error('Failed to emit "$event"', e);
    }
  }

  void _bindSocketLifecycleEvents() {
    final s = _socket;
    if (s == null) return;

    s.onConnect((_) {
      connectionState.value = SocketConnectionState.connected;
      SocketLogger.success('Socket Connected! ID: ${s.id}');
    });

    s.onDisconnect((data) {
      connectionState.value = SocketConnectionState.disconnected;
      SocketLogger.warning('Socket Disconnected: $data');
    });

    s.onConnectError((error) {
      connectionState.value = SocketConnectionState.error;
      SocketLogger.error('Socket Connect Error: $error');
    });

    s.onError((error) {
      connectionState.value = SocketConnectionState.error;
      SocketLogger.error('Socket Error: $error');
    });

    s.onReconnect((data) {
      connectionState.value = SocketConnectionState.connected;
      SocketLogger.success('Socket Reconnected successfully.');
    });

    s.onReconnectAttempt((attempt) {
      connectionState.value = SocketConnectionState.reconnecting;
      SocketLogger.info('Reconnecting attempt #$attempt...');
    });
  }

  void _attachSocketEventListener(String event) {
    _socket?.off(event);
    _socket?.on(event, (data) {
      SocketLogger.event('📥 Incoming', event, data);
      final handlers = _eventListeners[event];
      if (handlers != null && handlers.isNotEmpty) {
        final snapshot = List<SocketEventHandler<dynamic>>.from(handlers);
        for (final handler in snapshot) {
          try {
            handler(data);
          } catch (e) {
            SocketLogger.error('Handler error for "$event"', e);
          }
        }
      }
    });
  }

  void _rebindAllRegisteredListeners() {
    for (final event in _eventListeners.keys) {
      _attachSocketEventListener(event);
    }
  }

  void _teardownSocket() {
    if (_socket != null) {
      try {
        _socket?.clearListeners();
        _socket?.disconnect();
        _socket?.dispose();
      } catch (_) {}
      _socket = null;
    }
  }

  String? _extractRawToken(String? token) {
    if (token == null) return null;
    final trimmed = token.trim();
    if (trimmed.toLowerCase().startsWith('bearer ')) {
      return trimmed.substring(7).trim();
    }
    return trimmed;
  }

  Future<void> socketConnectApi({String? userToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiServices.connectSocket),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$userToken',
        },
      );
      print('socketConnect Response status: ${response.statusCode}');
      print('socketConnect Response body: ${response.body}');
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        print("API :-Socket Connected Successfully");
      } else {
        print("API :- Socket Not Connected");
      }
    } catch (e) {
      print('API :- SocketConnect Error: $e');
    }
  }
}

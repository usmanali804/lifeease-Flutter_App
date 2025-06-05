import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:logging/logging.dart';
import '../utils/token_manager.dart';
import '../network/connectivity_monitor.dart';
import '../config/environment_config.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  static WebSocketService get instance => _instance;
  final _logger = Logger('WebSocketService');

  late IO.Socket _socket;
  final ConnectivityMonitor _connectivityMonitor;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  final _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get connectionState => _connectionStateController.stream;

  // Message streams
  final _messageReceivedController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onMessageReceived =>
      _messageReceivedController.stream;

  final _typingStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onTypingStatus =>
      _typingStatusController.stream;

  final _taskUpdatesController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onTaskUpdates =>
      _taskUpdatesController.stream;

  final _userStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onUserStatus => _userStatusController.stream;
  WebSocketService._internal() : _connectivityMonitor = ConnectivityMonitor() {
    _setUpConnectivityListener();
  }

  void _setUpConnectivityListener() {
    _connectivityMonitor.addListener(() {
      if (_connectivityMonitor.hasConnection && !_isConnected) {
        connect();
      }
    });
  }

  Future<void> initialize() async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }

    _socket = IO.io(
      Environment.get('apiUrl'),
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .enableAutoConnect()
          .build(),
    );

    _setupEventHandlers();
    _startHeartbeat();
  }

  void _setupEventHandlers() {
    _socket.onConnect((_) {
      _logger.info('WebSocket connected');
      _isConnected = true;
      _connectionStateController.add(true);
      _reconnectTimer?.cancel();
    });
    _socket.onDisconnect((_) {
      _logger.info('WebSocket disconnected');
      _isConnected = false;
      _connectionStateController.add(false);
      _startReconnectTimer();
    });

    _socket.on('message:received', (data) {
      _messageReceivedController.add(data);
    });

    _socket.on('user:typing', (data) {
      _typingStatusController.add(data);
    });

    _socket.on('task:updated', (data) {
      _taskUpdatesController.add(data);
    });

    _socket.on('user:status', (data) {
      _userStatusController.add(data);
    });
    _socket.onError((error) {
      _logger.severe('WebSocket error: $error');
      _handleError(error);
    });
  }

  void connect() {
    if (!_isConnected) {
      _socket.connect();
    }
  }

  void disconnect() {
    _socket.disconnect();
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
  }

  void _startReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isConnected) {
        connect();
      } else {
        timer.cancel();
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _socket.emit('heartbeat');
      }
    });
  }

  void _handleError(dynamic error) {
    // Implement error handling logic
    _logger.severe('WebSocket error occurred: $error');
  }

  // Chat methods
  void joinChat(String conversationId) {
    _socket.emit('join:chat', {'conversationId': conversationId});
  }

  void sendMessage(String receiverId, Map<String, dynamic> message) {
    _socket.emit('message:send', {
      'receiverId': receiverId,
      'message': message,
    });
  }

  void sendTypingStatus(String receiverId, bool isTyping) {
    _socket.emit('user:typing', {
      'receiverId': receiverId,
      'isTyping': isTyping,
    });
  }

  // Task methods
  void subscribeToTaskUpdates(String taskId) {
    _socket.emit('task:subscribe', {'taskId': taskId});
  }

  void updateTask(String taskId, Map<String, dynamic> update) {
    _socket.emit('task:update', {'taskId': taskId, 'update': update});
  }

  void dispose() {
    disconnect();
    _connectionStateController.close();
    _messageReceivedController.close();
    _typingStatusController.close();
    _taskUpdatesController.close();
    _userStatusController.close();
  }
}

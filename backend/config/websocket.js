const socketIo = require('socket.io');
const jwt = require('jsonwebtoken');
const config = require('../config/config');

class WebSocketManager {
  static instance = null;
  
  constructor(server) {
    this.io = socketIo(server, {
      cors: {
        origin: config.corsOptions.origin,
        methods: ['GET', 'POST'],
        credentials: true
      }
    });
    
    this.userSockets = new Map(); // userId -> Set of socket ids
    this.socketUsers = new Map(); // socket id -> userId

    this.setupMiddleware();
    this.setupEventHandlers();
  }

  static getInstance(server) {
    if (!WebSocketManager.instance && server) {
      WebSocketManager.instance = new WebSocketManager(server);
    }
    return WebSocketManager.instance;
  }

  setupMiddleware() {
    this.io.use(async (socket, next) => {
      try {
        const token = socket.handshake.auth.token;
        if (!token) {
          throw new Error('Authentication token missing');
        }

        const decoded = jwt.verify(token, config.jwtSecret);
        socket.userId = decoded.userId;
        next();
      } catch (error) {
        next(new Error('Authentication failed'));
      }
    });
  }

  setupEventHandlers() {
    this.io.on('connection', (socket) => {
      console.log(`Client connected: ${socket.id}`);
      this.handleConnection(socket);

      // Handle chat events
      socket.on('join:chat', (data) => this.handleJoinChat(socket, data));
      socket.on('message:send', (data) => this.handleMessageSend(socket, data));
      socket.on('message:typing', (data) => this.handleTypingStatus(socket, data));

      // Handle task events
      socket.on('task:update', (data) => this.handleTaskUpdate(socket, data));
      socket.on('task:create', (data) => this.handleTaskCreate(socket, data));

      // Handle disconnection
      socket.on('disconnect', () => this.handleDisconnect(socket));
    });
  }

  handleConnection(socket) {
    const { userId } = socket;
    if (!this.userSockets.has(userId)) {
      this.userSockets.set(userId, new Set());
    }
    this.userSockets.get(userId).add(socket.id);
    this.socketUsers.set(socket.id, userId);

    // Notify user's contacts about online status
    this.broadcastUserStatus(userId, true);
  }

  handleDisconnect(socket) {
    const userId = this.socketUsers.get(socket.id);
    if (userId) {
      const userSockets = this.userSockets.get(userId);
      userSockets.delete(socket.id);
      
      if (userSockets.size === 0) {
        this.userSockets.delete(userId);
        // Notify user's contacts about offline status
        this.broadcastUserStatus(userId, false);
      }
      
      this.socketUsers.delete(socket.id);
    }
    console.log(`Client disconnected: ${socket.id}`);
  }

  async handleMessageSend(socket, data) {
    try {
      const { receiverId, message } = data;
      
      // Emit to all receiver's connected devices
      this.emitToUser(receiverId, 'message:received', {
        senderId: socket.userId,
        message
      });

      // Emit back to sender for confirmation
      socket.emit('message:sent', { success: true, messageId: message.id });
    } catch (error) {
      socket.emit('error', { message: 'Failed to send message' });
    }
  }

  handleTypingStatus(socket, data) {
    const { receiverId, isTyping } = data;
    this.emitToUser(receiverId, 'user:typing', {
      userId: socket.userId,
      isTyping
    });
  }

  handleTaskUpdate(socket, data) {
    const { taskId, update } = data;
    // Broadcast to all users who should receive this update
    this.io.emit('task:updated', { taskId, update });
  }

  handleJoinChat(socket, data) {
    const { conversationId } = data;
    socket.join(`chat:${conversationId}`);
    socket.to(`chat:${conversationId}`).emit('user:joined', {
      userId: socket.userId,
      conversationId
    });
  }

  // Utility methods
  emitToUser(userId, event, data) {
    const userSockets = this.userSockets.get(userId);
    if (userSockets) {
      userSockets.forEach(socketId => {
        this.io.to(socketId).emit(event, data);
      });
    }
  }

  broadcastUserStatus(userId, isOnline) {
    this.io.emit('user:status', { userId, isOnline });
  }

  // Public methods for external use
  notifyTaskAssigned(taskId, assignedToId, assignedById) {
    this.emitToUser(assignedToId, 'task:assigned', {
      taskId,
      assignedById
    });
  }

  notifyMessageRead(messageId, readById) {
    this.io.emit('message:read', { messageId, readById });
  }
}

module.exports = WebSocketManager;

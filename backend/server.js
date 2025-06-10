const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { createServer } = require('http');
const DatabaseManager = require('./config/database');
const WebSocketManager = require('./config/websocket');
const { initializeModels } = require('./models');
const authRoutes = require('./routes/auth.routes');
const taskRoutes = require('./routes/task.routes');
const chatRoutes = require('./routes/chat.routes');
const waterRoutes = require('./routes/water.routes');
const userRoutes = require('./routes/user.routes');
const rateLimiter = require('./middleware/rate-limiter.middleware');
const { errorHandler } = require('./middleware/error.middleware');

// Load environment variables and configuration
dotenv.config();
const config = require('./config/config');

const app = express();
const server = createServer(app);

// Debug logging for routes
const debugRouter = express.Router();
debugRouter.use((req, res, next) => {
  console.log('Debug - Current route:', req.originalUrl);
  next();
});
app.use(debugRouter);

// Initialize WebSocket
const wsManager = WebSocketManager.getInstance(server);

// Security Middleware
app.use(cors(config.corsOptions));
app.options('*', cors(config.corsOptions)); // Enable pre-flight for all routes
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(rateLimiter);

// Request logging in development
if (config.nodeEnv === 'development') {
  const morgan = require('morgan');
  app.use(morgan('dev'));
}

// Initialize database connection
const dbManager = DatabaseManager.getInstance();
dbManager.connect()
  .then(() => {
    console.log('Database connected successfully');
    return initializeModels();
  })
  .then(() => {
    console.log('Database models initialized successfully');
  })
  .catch((error) => {
    console.error('Failed to initialize database:', error);
    process.exit(1);
  });

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Initialize MongoDB connection when available
async function connectDB() {
  try {
    if (process.env.MONGODB_URI) {
      await mongoose.connect(process.env.MONGODB_URI);
      console.log('Connected to MongoDB');
    } else {
      console.log('MongoDB URI not provided - running without database');
    }
  } catch (err) {
    console.error('MongoDB connection error:', err);
    console.log('Server will continue without database connection');
  }
}

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/messages', chatRoutes);
app.use('/api/water-entries', waterRoutes);
app.use('/api/users', userRoutes);  // This will make user routes available at /api/users/profile

// Root API endpoint
app.get('/api', (req, res) => {  res.json({
    message: 'Welcome to Life Ease API',
    version: '1.0',
    endpoints: {
      auth: '/api/auth',
      tasks: '/api/tasks',
      messages: '/api/messages',
      waterEntries: '/api/water-entries',
      users: '/api/users'
    },
    documentation: 'For more information about specific endpoints, please refer to the API documentation'
  });
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Error handling middleware
app.use(errorHandler);

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Server accessible at http://192.168.1.119:${PORT}`);
  console.log(`API endpoints available at http://localhost:${PORT}/api`);
  console.log('Available routes:');
  console.log('  - /api/auth');
  console.log('  - /api/tasks');
  console.log('  - /api/messages');
  console.log('  - /api/water-entries');
});

// Handle uncaught exceptions and rejections
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (error) => {
  console.error('Unhandled Rejection:', error);
  process.exit(1);
});

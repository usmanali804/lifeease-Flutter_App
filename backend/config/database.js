const mongoose = require('mongoose');
const config = require('../config/config');

class DatabaseManager {
  constructor() {
    this.isConnected = false;
    this.connection = null;
    this.connectionRetries = 0;
    this.maxRetries = 5;
    this.retryDelay = 5000; // 5 seconds
  }

  static getInstance() {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }

  async connect() {
    try {
      if (this.isConnected) {
        console.log('Using existing database connection');
        return;
      }      // MongoDB connection options
      const options = {
        maxPoolSize: 10,
        serverSelectionTimeoutMS: 5000,
        socketTimeoutMS: 45000,
      };

      // Connect to MongoDB
      this.connection = await mongoose.connect(config.mongoUri, options);
      this.isConnected = true;
      
      console.log('Connected to MongoDB successfully');

      // Handle connection events
      mongoose.connection.on('connected', () => {
        console.log('MongoDB connected');
      });

      mongoose.connection.on('error', (err) => {
        console.error('MongoDB connection error:', err);
        this.isConnected = false;
      });

      mongoose.connection.on('disconnected', () => {
        console.log('MongoDB disconnected');
        this.isConnected = false;
      });

      // Handle application termination
      process.on('SIGINT', this.cleanup.bind(this));
      process.on('SIGTERM', this.cleanup.bind(this));

    } catch (error) {
      console.error('Database connection failed:', error);
      this.isConnected = false;
      throw error;
    }
  }

  async cleanup() {
    try {
      await mongoose.connection.close();
      console.log('MongoDB connection closed through app termination');
      process.exit(0);
    } catch (error) {
      console.error('Error during database cleanup:', error);
      process.exit(1);
    }
  }

  getConnection() {
    return this.connection;
  }

  isConnected() {
    return this.isConnected;
  }
}

module.exports = DatabaseManager;

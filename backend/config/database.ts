import mongoose from 'mongoose';
import { config } from './config';

export class DatabaseManager {
  private static instance: DatabaseManager;
  private isConnected: boolean;
  private connection: mongoose.Connection | null;
  private connectionRetries: number;
  private readonly maxRetries: number;
  private readonly retryDelay: number;

  private constructor() {
    this.isConnected = false;
    this.connection = null;
    this.connectionRetries = 0;
    this.maxRetries = 5;
    this.retryDelay = 5000; // 5 seconds
  }

  public static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }

  public async connect(): Promise<void> {
    try {
      if (this.isConnected) {
        console.log('Using existing database connection');
        return;
      }

      // MongoDB connection options
      const options: mongoose.ConnectOptions = {
        maxPoolSize: 10,
        serverSelectionTimeoutMS: 5000,
        socketTimeoutMS: 45000,
      };

      // Connect to MongoDB
      await mongoose.connect(config.mongoUri, options);
      this.connection = mongoose.connection;
      this.isConnected = true;
      this.connectionRetries = 0;
      
      console.log('Connected to MongoDB successfully');

      // Handle connection events
      this.connection.on('connected', () => {
        console.log('MongoDB connected');
        this.isConnected = true;
      });

      this.connection.on('error', (err) => {
        console.error('MongoDB connection error:', err);
        this.isConnected = false;
        this.handleConnectionError();
      });

      this.connection.on('disconnected', () => {
        console.log('MongoDB disconnected');
        this.isConnected = false;
        this.handleConnectionError();
      });

      // Handle application termination
      process.on('SIGINT', this.cleanup.bind(this));
      process.on('SIGTERM', this.cleanup.bind(this));

    } catch (error) {
      console.error('Database connection failed:', error);
      this.isConnected = false;
      await this.handleConnectionError();
    }
  }

  private async handleConnectionError(): Promise<void> {
    if (this.connectionRetries < this.maxRetries) {
      this.connectionRetries++;
      console.log(`Retrying connection (${this.connectionRetries}/${this.maxRetries}) in ${this.retryDelay}ms...`);
      await new Promise(resolve => setTimeout(resolve, this.retryDelay));
      await this.connect();
    } else {
      console.error(`Failed to connect after ${this.maxRetries} attempts`);
      process.exit(1);
    }
  }

  public async cleanup(): Promise<void> {
    try {
      if (this.connection) {
        await this.connection.close();
        console.log('MongoDB connection closed through app termination');
      }
      process.exit(0);
    } catch (error) {
      console.error('Error during database cleanup:', error);
      process.exit(1);
    }
  }

  public getConnection(): mongoose.Connection | null {
    return this.connection;
  }

  public getConnectionStatus(): boolean {
    return this.isConnected;
  }

  public async dropDatabase(): Promise<void> {
    if (process.env.NODE_ENV !== 'test') {
      throw new Error('Cannot drop database in non-test environment');
    }
    if (this.connection) {
      await this.connection.dropDatabase();
    }
  }
}

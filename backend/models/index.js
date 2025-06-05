const UserModel = require('./user.model');
const TaskModel = require('./task.model');
const MessageModel = require('./message.model');
const WaterEntryModel = require('./water-entry.model');

// Initialize models and add any necessary indexes
async function initializeModels() {
  try {
    // User indexes
    await UserModel.createIndexes();
    await UserModel.collection.createIndex({ email: 1 }, { unique: true });
    await UserModel.collection.createIndex({ 'profile.username': 1 }, { unique: true });

    // Task indexes
    await TaskModel.createIndexes();
    await TaskModel.collection.createIndex({ userId: 1, dueDate: 1 });
    await TaskModel.collection.createIndex({ status: 1 });

    // Message indexes
    await MessageModel.createIndexes();
    await MessageModel.collection.createIndex({ conversationId: 1, timestamp: -1 });
    await MessageModel.collection.createIndex({ 
      senderId: 1, 
      receiverId: 1, 
      timestamp: -1 
    });

    // Water Entry indexes
    await WaterEntryModel.createIndexes();
    await WaterEntryModel.collection.createIndex({ userId: 1, date: -1 });

    console.log('All database indexes created successfully');
  } catch (error) {
    console.error('Error creating database indexes:', error);
    throw error;
  }
}

module.exports = {
  UserModel,
  TaskModel,
  MessageModel,
  WaterEntryModel,
  initializeModels
};

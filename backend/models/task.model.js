const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    trim: true
  },
  status: {
    type: String,
    enum: ['pending', 'in_progress', 'completed', 'cancelled'],
    default: 'pending'
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high'],
    default: 'medium'
  },
  category: {
    type: String,
    required: true,
    trim: true
  },
  dueDate: {
    type: Date,
    required: true
  },
  completedDate: {
    type: Date
  },
  reminderTime: {
    type: Date
  },
  tags: [{
    type: String,
    trim: true
  }],
  attachments: [{
    name: String,
    url: String,
    type: String
  }],
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  isRecurring: {
    type: Boolean,
    default: false
  },
  recurringPattern: {
    frequency: {
      type: String,
      enum: ['daily', 'weekly', 'monthly', 'yearly']
    },
    interval: Number, // e.g., every 2 weeks
    endDate: Date
  }
}, {
  timestamps: true
});

// Indexes for better query performance
taskSchema.index({ user: 1, dueDate: 1 });
taskSchema.index({ user: 1, status: 1 });
taskSchema.index({ user: 1, category: 1 });

// Pre-save middleware to handle task completion
taskSchema.pre('save', function(next) {
  if (this.isModified('status') && this.status === 'completed') {
    this.completedDate = new Date();
  }
  next();
});

// Instance method to check if task is overdue
taskSchema.methods.isOverdue = function() {
  return this.status !== 'completed' && this.dueDate < new Date();
};

// Static method to find overdue tasks
taskSchema.statics.findOverdueTasks = function(userId) {
  return this.find({
    user: userId,
    status: { $ne: 'completed' },
    dueDate: { $lt: new Date() }
  });
};

// Method to format task for API response
taskSchema.methods.toJSON = function() {
  const task = this.toObject();
  task.id = task._id;
  delete task._id;
  delete task.__v;
  return task;
};

module.exports = mongoose.model('Task', taskSchema);

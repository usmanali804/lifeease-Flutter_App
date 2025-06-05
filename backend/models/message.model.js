const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  conversationId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    index: true
  },
  sender: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  receiver: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  content: {
    text: {
      type: String,
      trim: true
    },
    attachments: [{
      type: {
        type: String,
        enum: ['image', 'file', 'audio', 'location'],
        required: true
      },
      url: String,
      name: String,
      size: Number,
      mimeType: String
    }]
  },
  type: {
    type: String,
    enum: ['text', 'media', 'system'],
    default: 'text'
  },
  status: {
    type: String,
    enum: ['sent', 'delivered', 'read'],
    default: 'sent'
  },
  timestamp: {
    type: Date,
    default: Date.now,
    index: true
  },
  readAt: Date,
  deliveredAt: Date,
  metadata: {
    isEdited: {
      type: Boolean,
      default: false
    },
    editedAt: Date,
    replyTo: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Message'
    }
  },
  isSynced: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Compound indexes for efficient querying
messageSchema.index({ conversationId: 1, timestamp: -1 });
messageSchema.index({ sender: 1, receiver: 1, timestamp: -1 });

// Virtual for checking if message is read
messageSchema.virtual('isRead').get(function() {
  return this.status === 'read' && this.readAt != null;
});

// Method to mark message as delivered
messageSchema.methods.markDelivered = function() {
  if (this.status === 'sent') {
    this.status = 'delivered';
    this.deliveredAt = new Date();
    return this.save();
  }
  return Promise.resolve(this);
};

// Method to mark message as read
messageSchema.methods.markRead = function() {
  if (this.status !== 'read') {
    this.status = 'read';
    this.readAt = new Date();
    return this.save();
  }
  return Promise.resolve(this);
};

// Method to format message for API response
messageSchema.methods.toJSON = function() {
  const message = this.toObject();
  message.id = message._id;
  message.isRead = this.isRead;
  delete message._id;
  delete message.__v;
  return message;
};

module.exports = mongoose.model('Message', messageSchema);

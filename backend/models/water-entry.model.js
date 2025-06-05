const mongoose = require('mongoose');

const waterEntrySchema = new mongoose.Schema({
  amount: {
    type: Number,
    required: true,
    min: 0
  },
  unit: {
    type: String,
    required: true,
    enum: ['ml', 'oz'],
    default: 'ml'
  },
  type: {
    type: String,
    enum: ['water', 'coffee', 'tea', 'juice', 'other'],
    default: 'water'
  },
  timestamp: {
    type: Date,
    default: Date.now,
    required: true
  },
  note: {
    type: String,
    trim: true
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  location: {
    type: String,
    trim: true
  },
  temperature: {
    type: String,
    enum: ['cold', 'room', 'hot'],
    default: 'room'
  },
  reminderSet: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('WaterEntry', waterEntrySchema);

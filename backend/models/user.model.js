const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  password: {
    type: String,
    required: true,
    minlength: 8
  },
  profile: {
    username: {
      type: String,
      required: true,
      unique: true,
      trim: true
    },
    fullName: {
      type: String,
      required: true,
      trim: true
    },
    avatar: String,
    language: {
      type: String,
      default: 'en'
    },
    timezone: String
  },
  settings: {
    notifications: {
      push: { type: Boolean, default: true },
      email: { type: Boolean, default: true },
      taskReminders: { type: Boolean, default: true }
    },
    theme: {
      type: String,
      enum: ['light', 'dark', 'system'],
      default: 'system'
    }
  },
  refreshToken: String,
  isVerified: {
    type: Boolean,
    default: false
  },
  lastLogin: Date
}, {
  timestamps: true
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

// Method to generate profile data for client
userSchema.methods.toProfileJSON = function() {
  return {
    id: this._id,
    email: this.email,
    profile: this.profile,
    settings: this.settings,
    isVerified: this.isVerified,
    createdAt: this.createdAt,
    updatedAt: this.updatedAt
  };
};

// Method to generate auth response data
userSchema.methods.toAuthJSON = function(token) {
  return {
    user: this.toProfileJSON(),
    token: token
  };
};

module.exports = mongoose.model('User', userSchema);

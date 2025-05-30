const express = require('express');
const router = express.Router();
const Message = require('../models/message.model');
const authMiddleware = require('../middleware/auth.middleware');

// Apply auth middleware to all routes
router.use(authMiddleware);

// Get all messages
router.get('/', async (req, res) => {
  try {
    const messages = await Message.find()
      .sort({ timestamp: -1 })
      .populate('sender', 'name');
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching messages' });
  }
});

// Send a new message
router.post('/', async (req, res) => {
  try {
    const message = new Message({
      text: req.body.text,
      sender: req.user.userId,
      timestamp: new Date(),
      isSynced: true
    });
    await message.save();
    
    const populatedMessage = await Message.findById(message._id)
      .populate('sender', 'name');
    res.status(201).json(populatedMessage);
  } catch (error) {
    res.status(500).json({ message: 'Error sending message' });
  }
});

// Mark message as synced
router.patch('/:id/sync', async (req, res) => {
  try {
    const message = await Message.findByIdAndUpdate(
      req.params.id,
      { isSynced: true },
      { new: true }
    ).populate('sender', 'name');
    
    if (!message) {
      return res.status(404).json({ message: 'Message not found' });
    }
    res.json(message);
  } catch (error) {
    res.status(500).json({ message: 'Error updating message sync status' });
  }
});

module.exports = router;

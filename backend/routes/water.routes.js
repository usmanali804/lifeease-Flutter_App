const express = require('express');
const router = express.Router();
const WaterEntry = require('../models/water-entry.model');
const authMiddleware = require('../middleware/auth.middleware');

// Apply auth middleware to all routes
router.use(authMiddleware);

// Get all water entries
router.get('/', async (req, res) => {
  try {
    const entries = await WaterEntry.find({ user: req.user.userId })
      .sort({ timestamp: -1 });
    res.json(entries);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching water entries' });
  }
});

// Create a new water entry
router.post('/', async (req, res) => {
  try {
    const entry = new WaterEntry({
      ...req.body,
      user: req.user.userId
    });
    await entry.save();
    res.status(201).json(entry);
  } catch (error) {
    res.status(500).json({ message: 'Error creating water entry' });
  }
});

// Update a water entry
router.put('/:id', async (req, res) => {
  try {
    const entry = await WaterEntry.findOneAndUpdate(
      { _id: req.params.id, user: req.user.userId },
      req.body,
      { new: true }
    );
    if (!entry) {
      return res.status(404).json({ message: 'Water entry not found' });
    }
    res.json(entry);
  } catch (error) {
    res.status(500).json({ message: 'Error updating water entry' });
  }
});

// Delete a water entry
router.delete('/:id', async (req, res) => {
  try {
    const entry = await WaterEntry.findOneAndDelete({
      _id: req.params.id,
      user: req.user.userId
    });
    if (!entry) {
      return res.status(404).json({ message: 'Water entry not found' });
    }
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ message: 'Error deleting water entry' });
  }
});

module.exports = router;

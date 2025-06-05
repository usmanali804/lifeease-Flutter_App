const { DatabaseManager } = require('../config/database');

async function databaseMiddleware(req, res, next) {
  const dbManager = DatabaseManager.getInstance();

  if (!dbManager.getConnectionStatus()) {
    try {
      await dbManager.connect();
    } catch (error) {
      console.error('Database connection error in middleware:', error);
      return res.status(500).json({
        success: false,
        message: 'Database connection failed'
      });
    }
  }

  // Add database manager to request for use in routes
  req.dbManager = dbManager;
  next();
}

module.exports = databaseMiddleware;

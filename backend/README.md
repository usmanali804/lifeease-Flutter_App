# Life Ease Backend

REST API server for the Life Ease Flutter application.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
Create a `.env` file in the root directory with the following variables:
```
PORT=3000
MONGODB_URI=mongodb://localhost:27017/life_ease
JWT_SECRET=your_jwt_secret_key
JWT_REFRESH_SECRET=your_refresh_token_secret
```

3. Start the server:
- Development mode: `npm run dev`
- Production mode: `npm start`

## API Endpoints

### Authentication
- POST `/api/auth/register` - Register new user
- POST `/api/auth/login` - User login
- POST `/api/auth/refresh` - Refresh access token
- POST `/api/auth/logout` - User logout

### Tasks
- GET `/api/tasks` - Get all tasks
- POST `/api/tasks` - Create new task
- PUT `/api/tasks/:id` - Update task
- DELETE `/api/tasks/:id` - Delete task

### Water Tracking
- GET `/api/water-entries` - Get all water entries
- POST `/api/water-entries` - Add new water entry
- PUT `/api/water-entries/:id` - Update water entry
- DELETE `/api/water-entries/:id` - Delete water entry

### Chat
- GET `/api/messages` - Get all messages
- POST `/api/messages` - Send new message
- PATCH `/api/messages/:id/sync` - Mark message as synced

## Dependencies
- Express.js
- MongoDB/Mongoose
- JSON Web Token (JWT)
- CORS
- dotenv

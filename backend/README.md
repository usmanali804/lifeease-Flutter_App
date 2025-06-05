# Life Ease Backend

Backend server for the Life Ease Flutter application, providing a comprehensive API for user authentication, task management, water tracking, and real-time chat functionality.

## Features

- 🔐 JWT-based secure authentication
- 📝 Task management API
- 💧 Water intake tracking system
- 💬 Real-time chat with WebSocket
- 🔄 API rate limiting
- 📱 Cross-platform support
- 🌐 CORS enabled
- 🔍 Error tracking & logging
- 🔒 Input validation & sanitization

## Tech Stack

- Node.js & Express.js
- MongoDB with Mongoose
- Socket.IO for real-time communication
- JWT for authentication
- Express middleware for security

## Prerequisites

- Node.js (v14 or higher)
- MongoDB (v4.4 or higher)
- npm or yarn

## Setup

1. Clone the repository:
```bash
git clone https://github.com/usmanali804/lifeease-Flutter_App.git
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
Create a `.env` file in the root directory with the following variables:
```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
MONGODB_URI=mongodb://localhost:27017/life_ease

# JWT Configuration
JWT_SECRET=your_jwt_secret_key
JWT_REFRESH_SECRET=your_refresh_token_secret
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# WebSocket Configuration
WS_PORT=3001
```

4. Start the server:
- Development mode (with hot reload):
  ```bash
  npm run dev
  ```
- Production mode:
  ```bash
  npm start
  ```

## API Documentation

### Authentication Endpoints
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/register` | Register new user | No |
| POST | `/api/auth/login` | User login | No |
| POST | `/api/auth/refresh` | Refresh access token | No |
| POST | `/api/auth/logout` | User logout | Yes |

### Task Management
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/tasks` | Get all tasks | Yes |
| GET | `/api/tasks/:id` | Get task by ID | Yes |
| POST | `/api/tasks` | Create new task | Yes |
| PUT | `/api/tasks/:id` | Update task | Yes |
| DELETE | `/api/tasks/:id` | Delete task | Yes |

### Water Tracking
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/water-entries` | Get all water entries | Yes |
| GET | `/api/water-entries/:id` | Get entry by ID | Yes |
| POST | `/api/water-entries` | Add new water entry | Yes |
| PUT | `/api/water-entries/:id` | Update water entry | Yes |
| DELETE | `/api/water-entries/:id` | Delete water entry | Yes |

### Chat System
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/messages` | Get all messages | Yes |
| POST | `/api/messages` | Send new message | Yes |
| PATCH | `/api/messages/:id/sync` | Mark message as synced | Yes |
| WS | `/ws` | WebSocket connection | Yes |

## Project Structure
```
backend/
├── config/           # App configuration
│   ├── config.js     # Main config
│   ├── database.js   # DB config
│   └── websocket.js  # WebSocket config
├── middleware/       # Express middleware
│   ├── auth.middleware.js
│   ├── error.middleware.js
│   ├── rate-limiter.middleware.js
│   └── validation.middleware.js
├── models/          # Mongoose models
│   ├── message.model.js
│   ├── task.model.js
│   ├── user.model.js
│   └── water-entry.model.js
├── routes/          # API routes
│   ├── auth.routes.js
│   ├── chat.routes.js
│   ├── task.routes.js
│   └── water.routes.js
└── server.js        # Entry point
```

## Dependencies

### Core Dependencies
- `express` - Web framework
- `mongoose` - MongoDB ODM
- `jsonwebtoken` - JWT authentication
- `socket.io` - WebSocket support
- `cors` - Cross-Origin Resource Sharing
- `dotenv` - Environment configuration

### Development Dependencies
- `nodemon` - Hot reloading for development
- `morgan` - HTTP request logger
- `jest` - Testing framework

## Error Handling

The API uses standard HTTP status codes:
- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 500: Internal Server Error

## Security Features

- JWT-based authentication
- Password hashing
- Rate limiting
- CORS protection
- Input validation
- Error logging

## WebSocket Events

- `connection` - Client connected
- `disconnect` - Client disconnected
- `message` - New chat message
- `typing` - User typing indicator

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License.

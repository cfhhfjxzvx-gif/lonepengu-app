# LonePengu Backend API

Express.js + PostgreSQL backend for the LonePengu Flutter app.

## Quick Start

### 1. Prerequisites

- Node.js 18+
- PostgreSQL 14+

### 2. Create Database

```sql
CREATE DATABASE lonepengu_db;
```

### 3. Configure Environment

```bash
cp .env.example .env
# Edit .env with your PostgreSQL credentials
```

### 4. Install Dependencies

```bash
npm install
```

### 5. Initialize Database

```bash
npm run db:init
```

### 6. Start Server

```bash
# Development (with hot reload)
npm run dev

# Production
npm start
```

## API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Login/register user |
| POST | `/api/auth/logout` | Logout user |
| GET | `/api/auth/validate` | Validate session |
| POST | `/api/auth/refresh` | Refresh token |

### User

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/user/me` | Get current user |
| PUT | `/api/user/update` | Update profile |
| GET | `/api/user/preferences` | Get preferences |
| PUT | `/api/user/preferences` | Update preferences |
| GET | `/api/user/app-state` | Get app state |
| PUT | `/api/user/app-state` | Save app state |

## Login Request Example

```json
POST /api/auth/login
{
  "email": "user@example.com",
  "name": "John Doe",
  "auth_provider": "google",
  "provider_id": "google_user_id",
  "avatar_url": "https://..."
}
```

## Response Format

All responses follow this format:

```json
{
  "success": true,
  "data": { ... },
  "message": "Optional message"
}
```

Error responses:

```json
{
  "success": false,
  "message": "Error description",
  "code": "ERROR_CODE"
}
```

## Security Features

- ✅ JWT authentication
- ✅ Rate limiting
- ✅ Helmet security headers
- ✅ CORS protection
- ✅ Parameterized SQL queries
- ✅ Transaction support
- ✅ Token expiration

## Production Deployment

1. Set `NODE_ENV=production`
2. Use strong `JWT_SECRET`
3. Enable `DB_SSL=true`
4. Configure `CORS_ORIGIN` with your domain
5. Use a process manager (PM2)

```bash
npm install -g pm2
pm2 start server.js --name lonepengu-api
```

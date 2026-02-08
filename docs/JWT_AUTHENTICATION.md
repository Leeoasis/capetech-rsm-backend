# JWT Authentication API Documentation

This document describes the JWT authentication endpoints and how to test them.

## Overview

The authentication system uses JWT (JSON Web Tokens) with two token types:
- **Access Token**: Short-lived (15 minutes) for API requests
- **Refresh Token**: Long-lived (7 days) stored in database for obtaining new access tokens

## Endpoints

### 1. Login
**POST** `/api/v1/auth/login`

Authenticate a user and receive access and refresh tokens.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Success Response (200 OK):**
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "role": "admin",
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  },
  "access_token": "eyJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "abc123def456..."
}
```

**Error Response (401 Unauthorized):**
```json
{
  "error": {
    "message": "Invalid email or password",
    "details": {}
  }
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "password123"
  }'
```

---

### 2. Refresh Token
**POST** `/api/v1/auth/refresh`

Obtain a new access token using a refresh token.

**Request Body:**
```json
{
  "refresh_token": "abc123def456..."
}
```

**Success Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**Error Responses:**

**401 Unauthorized - Invalid token:**
```json
{
  "error": {
    "message": "Invalid refresh token",
    "details": {}
  }
}
```

**401 Unauthorized - Expired token:**
```json
{
  "error": {
    "message": "Refresh token expired",
    "details": {}
  }
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:3000/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "your_refresh_token_here"
  }'
```

---

### 3. Logout
**POST** `/api/v1/auth/logout`

Invalidate a refresh token (logout).

**Request Body:**
```json
{
  "refresh_token": "abc123def456..."
}
```

**Success Response (200 OK):**
```json
{
  "message": "Logged out successfully"
}
```

**Error Response (401 Unauthorized):**
```json
{
  "error": {
    "message": "Invalid refresh token",
    "details": {}
  }
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:3000/api/v1/auth/logout \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "your_refresh_token_here"
  }'
```

---

### 4. Get Current User
**GET** `/api/v1/auth/me`

Get information about the currently authenticated user.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200 OK):**
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "role": "admin",
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "error": {
    "message": "Missing or invalid token",
    "details": {}
  }
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer your_access_token_here"
```

---

## Authentication Flow

### Initial Login
1. User sends credentials to `/api/v1/auth/login`
2. Server validates credentials
3. Server generates:
   - Access token (JWT, 15 min expiry)
   - Refresh token (random, 7 days expiry, stored in DB)
4. Client stores both tokens securely

### Using Protected Endpoints
1. Client sends access token in `Authorization: Bearer <token>` header
2. Server validates token
3. If valid, request proceeds
4. If expired/invalid, client must refresh or re-login

### Refreshing Access Token
1. When access token expires, client sends refresh token to `/api/v1/auth/refresh`
2. Server validates refresh token from database
3. If valid and not expired, server issues new access token
4. Client uses new access token for subsequent requests

### Logout
1. Client sends refresh token to `/api/v1/auth/logout`
2. Server removes refresh token from database
3. Access token becomes invalid when it expires naturally

---

## Testing Checklist

- [ ] **Login with valid credentials**: Returns user data and tokens
- [ ] **Login with invalid credentials**: Returns 401 error
- [ ] **Access protected endpoint with valid token**: Returns data
- [ ] **Access protected endpoint without token**: Returns 401 error
- [ ] **Access protected endpoint with invalid token**: Returns 401 error
- [ ] **Access protected endpoint with expired token**: Returns 401 error
- [ ] **Refresh token with valid refresh token**: Returns new access token
- [ ] **Refresh token with invalid refresh token**: Returns 401 error
- [ ] **Refresh token with expired refresh token**: Returns 401 error
- [ ] **Logout with valid refresh token**: Successfully invalidates token
- [ ] **Logout with invalid refresh token**: Returns 401 error
- [ ] **Get current user info**: Returns authenticated user data

---

## Setup Instructions

### 1. Run Migrations
```bash
rails db:migrate
```

### 2. Create Test User
```bash
rails console
```

In the console:
```ruby
User.create!(
  email: 'admin@example.com',
  password: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  role: :admin
)
```

### 3. Start Server
```bash
rails server
```

### 4. Test the Endpoints
Use the cURL examples above or a tool like Postman to test the endpoints.

---

## Environment Variables

Ensure these are set in your `.env` file:

```env
JWT_SECRET_KEY=your_secret_key_here_change_this_in_production
JWT_ACCESS_TOKEN_EXPIRATION=900
JWT_REFRESH_TOKEN_EXPIRATION=604800
```

**Note:** Change `JWT_SECRET_KEY` to a secure random value in production:
```bash
rails secret
```

---

## Security Considerations

1. **HTTPS Only**: Always use HTTPS in production
2. **Secure Storage**: Store tokens securely on client (HttpOnly cookies or secure storage)
3. **Token Rotation**: Consider implementing refresh token rotation
4. **Rate Limiting**: Implement rate limiting on login endpoint
5. **Secret Key**: Use a strong, random secret key in production
6. **Token Expiry**: Adjust token expiration times based on security requirements
7. **CORS**: Configure CORS properly for your frontend domain

---

## Error Response Format

All errors follow this format:
```json
{
  "error": {
    "message": "Human-readable error message",
    "details": {}
  }
}
```

---

## Database Schema

### refresh_tokens table
- `id`: Primary key
- `user_id`: Foreign key to users table
- `token`: Unique string token
- `expires_at`: Timestamp when token expires
- `created_at`: Timestamp when token was created
- `updated_at`: Timestamp when token was updated

Indexes:
- Unique index on `token`
- Index on `user_id`

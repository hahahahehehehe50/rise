# Rise - Text-Only Social Media Platform

A minimal text-based social media platform compatible with Chrome for Android KitKat (4.4). Built with Node.js, Express, and Supabase.

## Features

- User registration and authentication
- Create and delete text posts
- Like posts
- Comment on posts
- User profiles
- View your own posts
- Responsive design for older mobile browsers

## Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Set Up Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to the SQL Editor in your Supabase dashboard
3. Run the SQL commands from `schema.sql` to create the database tables
4. Copy your project URL and anon key from Settings > API

### 3. Configure Environment Variables

Create a `.env` file in the project root:

```bash
cp .env.example .env
```

Edit `.env` and add your Supabase credentials:

```
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
PORT=3000
```

### 4. Run the Server

```bash
npm start
```

Or for development with auto-reload:

```bash
npm run dev
```

### 5. Access the App

Open your browser and navigate to:
```
http://localhost:3000
```

## Database Schema

The app uses the following tables:
- `users` - User accounts
- `posts` - Text posts
- `likes` - Post likes
- `comments` - Post comments
- `follows` - User following/subscribing

## API Endpoints

### Auth
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Users
- `GET /api/users/:id` - Get user profile
- `GET /api/users/:id/posts` - Get user's posts
- `GET /api/users/:id/followers` - Get user's followers
- `GET /api/users/:id/following` - Get users followed by user
- `POST /api/users/:id/follow` - Follow a user
- `DELETE /api/users/:id/follow` - Unfollow a user

### Posts
- `GET /api/posts` - Get all posts
- `POST /api/posts` - Create new post
- `DELETE /api/posts/:id` - Delete post
- `GET /api/feed/:userId` - Get feed from followed users

### Likes
- `POST /api/posts/:id/like` - Like a post
- `DELETE /api/posts/:id/like` - Unlike a post

### Comments
- `GET /api/posts/:id/comments` - Get post comments
- `POST /api/posts/:id/comments` - Add comment to post

## Compatibility

This app is designed to work on:
- Chrome for Android KitKat (4.4)
- Modern browsers (as fallback)

It uses vanilla JavaScript (ES5) and traditional DOM manipulation for maximum compatibility.

## Security Notes

- In production, use bcrypt for password hashing instead of storing plain text
- Implement proper session management and JWT tokens
- Add rate limiting to prevent abuse
- Use environment variables for all sensitive data
- Enable HTTPS in production

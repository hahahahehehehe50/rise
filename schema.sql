-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users
CREATE POLICY "Allow public read access on users"
  ON users FOR SELECT
  USING (true);

CREATE POLICY "Allow public insert on users"
  ON users FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow users to update their own profile"
  ON users FOR UPDATE
  USING (true);

-- Posts table
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on posts table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- RLS Policies for posts
CREATE POLICY "Allow public read access on posts"
  ON posts FOR SELECT
  USING (true);

CREATE POLICY "Allow authenticated users to create posts"
  ON posts FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow users to delete their own posts"
  ON posts FOR DELETE
  USING (true);

-- Likes table
CREATE TABLE likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, post_id)
);

-- Enable RLS on likes table
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

-- RLS Policies for likes
CREATE POLICY "Allow public read access on likes"
  ON likes FOR SELECT
  USING (true);

CREATE POLICY "Allow authenticated users to create likes"
  ON likes FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow users to delete their own likes"
  ON likes FOR DELETE
  USING (true);

-- Comments table
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on comments table
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- RLS Policies for comments
CREATE POLICY "Allow public read access on comments"
  ON comments FOR SELECT
  USING (true);

CREATE POLICY "Allow authenticated users to create comments"
  ON comments FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow users to delete their own comments"
  ON comments FOR DELETE
  USING (true);

-- Follows table (subscribers)
CREATE TABLE follows (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(follower_id, following_id),
  CHECK (follower_id != following_id)
);

-- Enable RLS on follows table
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;

-- RLS Policies for follows
CREATE POLICY "Allow public read access on follows"
  ON follows FOR SELECT
  USING (true);

CREATE POLICY "Allow authenticated users to create follows"
  ON follows FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow users to delete their own follows"
  ON follows FOR DELETE
  USING (true);

-- Insert fake users
INSERT INTO users (username, password_hash, bio) VALUES
  ('tech_guru', 'password123', 'Always exploring the latest in tech'),
  ('music_lover', 'password123', 'Life is better with good music'),
  ('foodie', 'password123', 'Eating my way around the world'),
  ('travel_bug', 'password123', 'Adventure awaits!'),
  ('fitness_fan', 'password123', 'No pain, no gain'),
  ('bookworm', 'password123', 'Lost in books'),
  ('gamer_pro', 'password123', 'Press start to continue'),
  ('art_creator', 'password123', 'Creating beauty every day'),
  ('nature_enthusiast', 'password123', 'The great outdoors calls'),
  ('code_master', 'password123', 'Debugging life one line at a time');

-- Insert fake posts
INSERT INTO posts (user_id, content) VALUES
  ((SELECT id FROM users WHERE username = 'tech_guru'), 'Just discovered an amazing new framework! The future of web development is here.'),
  ((SELECT id FROM users WHERE username = 'music_lover'), 'That new album dropped today and it is absolutely fire! 🎵'),
  ((SELECT id FROM users WHERE username = 'foodie'), 'Found the best pizza place in town. The cheese pull was unreal! 🍕'),
  ((SELECT id FROM users WHERE username = 'travel_bug'), 'Booking my next adventure! Thinking Japan or Iceland. Any suggestions? ✈️'),
  ((SELECT id FROM users WHERE username = 'fitness_fan'), 'Morning workout complete. 5km run and feeling great! 💪'),
  ((SELECT id FROM users WHERE username = 'bookworm'), 'Just finished reading "The Midnight Library". Highly recommend! 📚'),
  ((SELECT id FROM users WHERE username = 'gamer_pro'), 'Finally beat that boss after 50 tries! Victory tastes sweet! 🎮'),
  ((SELECT id FROM users WHERE username = 'art_creator'), 'Spent the whole day painting. Sometimes the canvas just speaks to you. 🎨'),
  ((SELECT id FROM users WHERE username = 'nature_enthusiast'), 'Sunrise hike was breathtaking. Nature never disappoints. 🌄'),
  ((SELECT id FROM users WHERE username = 'code_master'), 'Fixed a bug that was haunting me for days. The satisfaction is real! 🐛');

-- Indexes for better performance
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_likes_post_id ON likes(post_id);
CREATE INDEX idx_likes_user_id ON likes(user_id);
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_follows_follower_id ON follows(follower_id);
CREATE INDEX idx_follows_following_id ON follows(following_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

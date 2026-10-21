const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(express.static('public'));

// Supabase client
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

// Auth endpoints
app.post('/api/auth/register', async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Check if user exists
    const { data: existingUser } = await supabase
      .from('users')
      .select('id')
      .or(`username.eq.${username},email.eq.${email}`)
      .single();

    if (existingUser) {
      return res.status(400).json({ error: 'Username or email already exists' });
    }

    // Create user with Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
    });

    if (authError) throw authError;

    // Create user profile
    const { data: userData, error: userError } = await supabase
      .from('users')
      .insert({
        username,
        email,
        password_hash: password, // In production, use bcrypt
      })
      .select()
      .single();

    if (userError) throw userError;

    res.json({ user: userData, session: authData.session });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) throw error;

    // Get user profile
    const { data: userData } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    res.json({ user: userData, session: data.session });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// User endpoints
app.get('/api/users/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/users/:id/posts', async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase
      .from('posts')
      .select('*')
      .eq('user_id', id)
      .order('created_at', { ascending: false });

    if (error) throw error;
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Post endpoints
app.get('/api/posts', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('posts')
      .select(`
        *,
        users:users(id, username, avatar_url),
        likes:likes(count),
        comments:comments(count)
      `)
      .order('created_at', { ascending: false });

    if (error) throw error;
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/posts', async (req, res) => {
  try {
    const { user_id, content } = req.body;

    const { data, error } = await supabase
      .from('posts')
      .insert({ user_id, content })
      .select()
      .single();

    if (error) throw error;
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/posts/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { error } = await supabase
      .from('posts')
      .delete()
      .eq('id', id);

    if (error) throw error;
    res.json({ message: 'Post deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Like endpoints
app.post('/api/posts/:id/like', async (req, res) => {
  try {
    const { id } = req.params;
    const { user_id } = req.body;

    const { data, error } = await supabase
      .from('likes')
      .insert({ user_id, post_id: id })
      .select()
      .single();

    if (error) throw error;
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/posts/:id/like', async (req, res) => {
  try {
    const { id } = req.params;
    const { user_id } = req.body;

    const { error } = await supabase
      .from('likes')
      .delete()
      .eq('post_id', id)
      .eq('user_id', user_id);

    if (error) throw error;
    res.json({ message: 'Like removed' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Comment endpoints
app.get('/api/posts/:id/comments', async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase
      .from('comments')
      .select(`
        *,
        users:users(id, username, avatar_url)
      `)
      .eq('post_id', id)
      .order('created_at', { ascending: false });

    if (error) throw error;
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/posts/:id/comments', async (req, res) => {
  try {
    const { id } = req.params;
    const { user_id, content } = req.body;

    const { data, error } = await supabase
      .from('comments')
      .insert({ user_id, post_id: id, content })
      .select()
      .single();

    if (error) throw error;
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Follow endpoints
app.post('/api/users/:id/follow', async (req, res) => {
  try {
    const { id } = req.params;
    const { follower_id } = req.body;

    const { data, error } = await supabase
      .from('follows')
      .insert({ follower_id, following_id: id })
      .select()
      .single();

    if (error) throw error;
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/users/:id/follow', async (req, res) => {
  try {
    const { id } = req.params;
    const { follower_id } = req.body;

    const { error } = await supabase
      .from('follows')
      .delete()
      .eq('following_id', id)
      .eq('follower_id', follower_id);

    if (error) throw error;
    res.json({ message: 'Unfollowed' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/users/:id/followers', async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase
      .from('follows')
      .select(`
        follower:follower_id(id, username, avatar_url)
      `)
      .eq('following_id', id);

    if (error) throw error;
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/users/:id/following', async (req, res) => {
  try {
    const { id } = req.params;
    const { data, error } = await supabase
      .from('follows')
      .select(`
        following:following_id(id, username, avatar_url)
      `)
      .eq('follower_id', id);

    if (error) throw error;
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Feed endpoint (posts from followed users)
app.get('/api/feed/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    // Get followed users
    const { data: follows } = await supabase
      .from('follows')
      .select('following_id')
      .eq('follower_id', userId);

    const followingIds = follows ? follows.map(f => f.following_id) : [];

    // Get posts from followed users
    const { data, error } = await supabase
      .from('posts')
      .select(`
        *,
        users:users(id, username, avatar_url),
        likes:likes(count),
        comments:comments(count)
      `)
      .in('user_id', followingIds.length > 0 ? followingIds : ['00000000-0000-0000-0000-000000000000'])
      .order('created_at', { ascending: false });

    if (error) throw error;
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Rise server running on port ${PORT}`);
});

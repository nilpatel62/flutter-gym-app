-- Create workout_sessions table in Supabase
-- This table stores individual rep completions with user session data

CREATE TABLE IF NOT EXISTS workout_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_name TEXT NOT NULL,
  rep_number INTEGER NOT NULL,
  score INTEGER NOT NULL CHECK (score >= 0 AND score <= 100),
  date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Indexes for better query performance
  CONSTRAINT valid_exercise_name CHECK (exercise_name IN ('squat', 'pushup', 'deadlift')),
  CONSTRAINT valid_rep_number CHECK (rep_number > 0)
);

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_date ON workout_sessions(date DESC);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_exercise ON workout_sessions(user_id, exercise_name);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_date ON workout_sessions(user_id, date DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to insert their own workout sessions
CREATE POLICY "Users can insert their own workout sessions"
  ON workout_sessions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create policy to allow users to read their own workout sessions
CREATE POLICY "Users can read their own workout sessions"
  ON workout_sessions
  FOR SELECT
  USING (auth.uid() = user_id);

-- Create policy to allow users to update their own workout sessions (optional)
CREATE POLICY "Users can update their own workout sessions"
  ON workout_sessions
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create policy to allow users to delete their own workout sessions (optional)
CREATE POLICY "Users can delete their own workout sessions"
  ON workout_sessions
  FOR DELETE
  USING (auth.uid() = user_id);

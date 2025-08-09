-- Schema for Family Travel Tracker
-- Idempotent drops
DROP TABLE IF EXISTS visited_countries CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS countries CASCADE;

-- Countries lookup
CREATE TABLE IF NOT EXISTS countries (
  country_code CHAR(2) PRIMARY KEY,
  country_name TEXT NOT NULL UNIQUE,
  CHECK (country_code = UPPER(country_code))
);

-- Index to speed case-insensitive lookups by name
CREATE INDEX IF NOT EXISTS idx_countries_lower_name
  ON countries ((LOWER(country_name)));

-- Users
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  color VARCHAR(20),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Visits
CREATE TABLE IF NOT EXISTS visited_countries (
  id BIGSERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  country_code CHAR(2) NOT NULL REFERENCES countries(country_code) ON DELETE RESTRICT,
  visited_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_user_country UNIQUE (user_id, country_code)
);

-- Helpful indexes for common filters
CREATE INDEX IF NOT EXISTS idx_visited_user ON visited_countries(user_id);
CREATE INDEX IF NOT EXISTS idx_visited_country ON visited_countries(country_code);

-- View: per-user visit counts
CREATE OR REPLACE VIEW v_user_visit_counts AS
SELECT u.id AS user_id, u.name, u.color, COUNT(vc.country_code) AS visited_count
FROM users u
LEFT JOIN visited_countries vc ON vc.user_id = u.id
GROUP BY u.id, u.name, u.color;

-- Helper function: add a visit by fuzzy country name match
CREATE OR REPLACE FUNCTION add_visit_by_country_name(p_user_id INT, p_country_name TEXT)
RETURNS TABLE(country_code CHAR(2))
LANGUAGE plpgsql
AS $$
DECLARE
  v_code CHAR(2);
BEGIN
  SELECT country_code
    INTO v_code
  FROM countries
  WHERE LOWER(country_name) LIKE '%' || LOWER(p_country_name) || '%'
  ORDER BY country_name
  LIMIT 1;

  IF v_code IS NULL THEN
    RAISE EXCEPTION 'Country not found for %', p_country_name USING ERRCODE = 'NO_DATA_FOUND';
  END IF;

  INSERT INTO visited_countries (user_id, country_code)
  VALUES (p_user_id, v_code)
  ON CONFLICT ON CONSTRAINT unique_user_country DO NOTHING;

  RETURN QUERY SELECT v_code;
END;
$$; 
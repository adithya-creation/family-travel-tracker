-- Minimal seed data

-- Countries (add more as desired)
INSERT INTO countries (country_code, country_name) VALUES
 ('FR', 'France'),
 ('GB', 'United Kingdom'),
 ('CA', 'Canada'),
 ('US', 'United States'),
 ('DE', 'Germany'),
 ('JP', 'Japan'),
 ('IN', 'India'),
 ('CN', 'China'),
 ('BR', 'Brazil'),
 ('ES', 'Spain')
ON CONFLICT (country_code) DO NOTHING;

-- Users
INSERT INTO users (name, color) VALUES
 ('Angela', 'teal'),
 ('Jack', 'powderblue')
ON CONFLICT (name) DO NOTHING;

-- Visited
INSERT INTO visited_countries (user_id, country_code) VALUES
 ((SELECT id FROM users WHERE name = 'Angela'), 'FR'),
 ((SELECT id FROM users WHERE name = 'Angela'), 'GB'),
 ((SELECT id FROM users WHERE name = 'Jack'), 'CA'),
 ((SELECT id FROM users WHERE name = 'Jack'), 'FR')
ON CONFLICT ON CONSTRAINT unique_user_country DO NOTHING; 
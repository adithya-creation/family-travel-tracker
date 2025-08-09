## Family Travel Tracker (Node + Express + EJS + PostgreSQL)

A simple multi-user travel tracker for families. Each member can select a color and mark countries they have visited. The app renders a world map and highlights the selected user’s visited countries.

### Features
- **Multiple users**: switch between family members or add a new one
- **World map**: highlights visited countries per selected user
- **Add country by name**: fuzzy match against a `countries` table and saves the ISO-2 code

### Tech Stack
- **Server**: Node.js, Express, EJS
- **Database**: PostgreSQL (`pg`)
- **Styling**: CSS served from `public/`

### Prerequisites
- Node.js (v18+ recommended) and npm
- PostgreSQL 13+ running locally

### Install
```bash
npm install
```

### Configure Database
The app connects to PostgreSQL with the following defaults (see `index.js`):
- user: `postgres`
- host: `localhost`
- database: `world`
- password: `adithya`
- port: `5432`

If your local credentials differ, update the client config in `index.js` accordingly.

#### 1) Create/Ensure database exists
```sql
-- Create the database if you don't already have it
CREATE DATABASE world;
```

#### 2) Required tables and seed data
Run the relevant section from `queries.sql` (the block labeled “EXERCISE SOLUTION AND SETUP”) against your `world` database, or execute the SQL below.

```sql
-- Drop existing (if any)
DROP TABLE IF EXISTS visited_countries, users;

-- Users of the app
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(15) UNIQUE NOT NULL,
  color VARCHAR(15)
);

-- A join of users to ISO-2 country codes they visited
CREATE TABLE visited_countries (
  id SERIAL PRIMARY KEY,
  country_code CHAR(2) NOT NULL,
  user_id INTEGER REFERENCES users(id)
);

-- Minimal seed
INSERT INTO users (name, color)
VALUES ('Angela', 'teal'), ('Jack', 'powderblue');

INSERT INTO visited_countries (country_code, user_id)
VALUES ('FR', 1), ('GB', 1), ('CA', 2), ('FR', 2);
```

#### 3) Countries lookup table (required)
The route `POST /add` expects a `countries` table with `country_name` and `country_code` (ISO-2). Create and populate it (example below). You can replace the seed with a complete country list.

```sql
-- Countries lookup used when adding a country by name
CREATE TABLE IF NOT EXISTS countries (
  country_code CHAR(2) PRIMARY KEY,
  country_name TEXT NOT NULL
);

-- Minimal sample seed (replace with a full list as needed)
INSERT INTO countries (country_code, country_name) VALUES
 ('FR', 'France'),
 ('GB', 'United Kingdom'),
 ('CA', 'Canada'),
 ('US', 'United States'),
 ('DE', 'Germany'),
 ('JP', 'Japan');
```

### Run
```bash
node index.js
```
Visit `http://localhost:3000`.

### Usage
- On the home page, click a user tab to switch user or “Add Family Member” to create one.
- Use the input to type a country name (partial match is allowed, e.g., “fran” → France) and click Add.
- The map will highlight the newly added country for the selected user.

### Routes
- `GET /`: render home with world map for the current user
- `POST /add`: body `{ country }`; inserts the matched country’s ISO-2 into `visited_countries` for the current user
- `POST /user`: body either `{ add: 'new' }` to render the new-user form or `{ user: <id> }` to switch current user
- `POST /new`: body `{ name, color }`; creates a user and sets them as current

### Project Structure
- `index.js`: Express app, routes, PostgreSQL queries
- `views/`: EJS templates (`index.ejs`, `new.ejs`)
- `public/styles/`: CSS (`main.css`, `new.css`)
- `queries.sql`: helpful SQL snippets and the app schema/seeds

### Notes / Troubleshooting
- By default, the server runs on port `3000`.
- If adding a country fails, ensure the `countries` table exists and contains the name/code you expect. The app uses:
  ```sql
  SELECT country_code FROM countries WHERE LOWER(country_name) LIKE '%' || $1 || '%';
  ```
- If you get database connection errors, update the PostgreSQL client config in `index.js` to match your local setup.
- The new-user route uses the inserted row’s id. If needed, verify that your Postgres version supports `RETURNING` (it should) and that you are reading `result.rows[0].id`.

### License
ISC 

## SQL proficiency highlights
- Strong normalization and integrity: separate `users`, `countries`, `visited_countries` with FKs and unique constraints
- Indexing for performance: `LOWER(country_name)` index for searches; visit indexes for joins/filters
- Idempotent data operations: `ON CONFLICT` to avoid duplicates
- Encapsulated logic: `add_visit_by_country_name()` helper function
- Analytics: prebuilt queries for coverage, top travelers, and recency

Quick start for reviewers:
```bash
# Apply schema and seed
psql -U postgres -h localhost -d world -f sql/schema.sql
psql -U postgres -h localhost -d world -f sql/seed.sql

# Run analytics
psql -U postgres -h localhost -d world -f sql/analytics.sql | cat
``` 
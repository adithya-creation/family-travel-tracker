# SQL Design and Proficiency Highlights

This app is intentionally designed to showcase clean schema design, referential integrity, indexing strategy, and analytical queries in PostgreSQL.

## Schema Overview
- `countries(country_code, country_name)`
  - Primary key: `country_code CHAR(2)` (ISO-2)
  - `country_name` is `UNIQUE`
  - Check constraint enforces uppercase `country_code`
  - Index on `LOWER(country_name)` for fast case-insensitive lookup
- `users(id, name, color, created_at)`
  - `name` is `UNIQUE`
  - `created_at` defaults to `NOW()`
- `visited_countries(id, user_id, country_code, visited_at)`
  - FKs: `user_id -> users(id)` (ON DELETE CASCADE), `country_code -> countries(country_code)`
  - `UNIQUE(user_id, country_code)` prevents duplicates for a user
  - Indexes on `user_id` and `country_code`

See `sql/schema.sql` for the full DDL.

## Normalization and Integrity
- Countries are a canonical lookup, separating names/codes from visits
- `visited_countries` is a pure relation between `users` and `countries`
- Uniqueness and FK constraints ensure consistency without app logic

## Performance
- `idx_countries_lower_name` supports case-insensitive fuzzy searches like:
  ```sql
  SELECT country_code
  FROM countries
  WHERE LOWER(country_name) LIKE '%' || LOWER($1) || '%';
  ```
- Visit lookups benefit from `idx_visited_user` and `idx_visited_country`
- View `v_user_visit_counts` provides a pre-aggregated perspective

## Helper Function
`add_visit_by_country_name(user_id, country_name)` encapsulates the lookup + insert with conflict handling:
```sql
SELECT * FROM add_visit_by_country_name(1, 'fran'); -- returns FR
```
- Raises a clear exception if no country matches
- Uses `ON CONFLICT` to avoid duplicates

## Analytics Examples
See `sql/analytics.sql` for:
- Top travelers
- Users with no visits
- Most recent visits
- Coverage percentage per user
- Visit counts by country

## How to Run
```bash
# Apply schema
psql -U postgres -h localhost -d world -f sql/schema.sql

# Seed data
psql -U postgres -h localhost -d world -f sql/seed.sql

# Explore analytics
psql -U postgres -h localhost -d world -f sql/analytics.sql | cat
```

## Optional Improvements
- Use `citext` for case-insensitive country names
- Enforce color via domain or enumerated type
- Add triggers to validate country codes against ISO patterns
- Use partitioning if visit volume grows significantly 
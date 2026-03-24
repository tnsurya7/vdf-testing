# Flyway migrations

Migrations run **once per database**: Flyway records each applied version in `flyway_schema_history`. On restart it only runs **pending** migrations (versions not in that table).

## "relation flyway_schema_history does not exist"

That means **Flyway has never run** against the database you’re connected to. The table is created by Flyway the first time the app starts successfully.

- **In psql:** You might be in a different database than the app. Check with:
  ```sql
  SELECT current_database();
  ```
  Your `application.yml` has `jdbc:postgresql://localhost:5432/vdfnew` — so the app uses database **`vdfnew`**. Connect to that one:
  ```bash
  psql -U postgres -d vdfnew
  ```
- **If you use `application-dev.yml`** (profile `dev`), the app uses database **`vdf`**. Use `-d vdf` in that case.
- After starting the app once (so Flyway runs), `flyway_schema_history` will exist in that database and you can query it.

## Why a migration might not run on restart

1. **Already applied** – The version is already in `flyway_schema_history`. Flyway skips it. This is normal.
2. **Different database** – You ran the script manually on one DB (e.g. `vdfnew`) but the app uses another (e.g. with `spring.profiles.active=dev` → `vdf`). Flyway runs against the app’s datasource.
3. **Startup order** – Flyway runs early; if the app fails before or during migration, check the full stack trace.

## Check what Flyway has run

Against the same database the app uses (e.g. `vdfnew`):

```sql
SELECT installed_rank, version, description, success
FROM flyway_schema_history
ORDER BY installed_rank;
```

- If **V10** appears with `success = true`, Flyway has already applied it and will not run it again.
- If **V10** is missing, Flyway should run it on next startup (unless disabled or wrong DB).

## See Flyway activity on startup

In `application.yml` (or via env) set:

```yaml
logging:
  level:
    org.flywaydb: DEBUG
```

You’ll see lines like “Migrating schema to version 10” or “Schema is up to date. No migration necessary.”

## If you ran a migration manually

If you applied V10 by hand and want Flyway to treat it as applied (so it doesn’t run it again), you can record it:

```sql
-- Only if you already ran the V10 script manually and use the same DB as the app.
INSERT INTO flyway_schema_history (installed_rank, version, description, type, script, checksum, installed_by, execution_time, success)
VALUES (
  (SELECT COALESCE(MAX(installed_rank), 0) + 1 FROM flyway_schema_history),
  '10',
  'application workflow step drop and recreate check',
  'SQL',
  'V10__application_workflow_step_drop_and_recreate_check.sql',
  NULL,
  current_user,
  0,
  true
);
```

Then on restart Flyway will see V10 as applied and skip it.

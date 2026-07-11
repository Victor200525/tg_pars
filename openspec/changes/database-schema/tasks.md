## 1. Setup

- [ ] 1.1 Add PostgreSQL dependency (asyncpg or SQLAlchemy) to requirements
- [ ] 1.2 Create database connection module with connection pool
- [ ] 1.3 Add DATABASE_URL to config / environment

## 2. DDL — All Tables

- [ ] 2.1 Write full PostgreSQL DDL: `products`, `subscription_plans`, `addon_plans`
- [ ] 2.2 Write DDL: `clients`, `subscriptions`, `addon_purchases`
- [ ] 2.3 Write DDL: `channels`, `client_channels`
- [ ] 2.4 Write DDL: `keyword_filters`, `matches`
- [ ] 2.5 Write DDL: `request_usage_log`
- [ ] 2.6 Add indexes for: client_id FK lookups, (client_id, channel_id) UNIQUE, matches.matched_at
- [ ] 2.7 Write migration script (or init DB on first run)

## 3. Data Models

- [ ] 3.1 Create SQLAlchemy models for all tables (or raw asyncpg row factories)
- [ ] 3.2 Add type hints and validation methods

## 4. Client & Channel Management

- [ ] 4.1 Implement CRUD for clients (create, activate, deactivate, list)
- [ ] 4.2 Implement CRUD for channels (create with username normalization, list, deactivate)
- [ ] 4.3 Implement subscribe/unsubscribe (client_channels add/soft-delete)

## 5. Subscription & Addon Logic

- [ ] 5.1 Implement CRUD for products + subscription_plans + addon_plans
- [ ] 5.2 Implement purchase: create subscription record with snapshot of plan limits
- [ ] 5.3 Implement purchase: create addon_purchases record
- [ ] 5.4 Implement atomic request consumption (subscription first, then addon) — stored procedure or app-level transaction

## 6. Keyword Matching

- [ ] 6.1 Implement CRUD for keyword_filters (per client, optionally per channel)
- [ ] 6.2 Implement match recording: scan message text against client's keyword_filters, write to `matches`

## 7. Parser Integration

- [ ] 7.1 Refactor parser to query DB for active (client, channel) pairs instead of hardcoded chat
- [ ] 7.2 Integrate request consumption check before each parse cycle
- [ ] 7.3 Replace `last_id.txt` with per-channel last_id tracking (add `last_parsed_msg_id` to `channels` or separate table)
- [ ] 7.4 Wire keyword matching into the parse loop
- [ ] 7.5 Handle multi-client broadcast: parse channel once, match per client

## 8. Testing

- [ ] 8.1 Unit tests for models and validation
- [ ] 8.2 Integration tests for atomic request consumption
- [ ] 8.3 Integration tests for keyword matching workflow
- [ ] 8.4 Test concurrent request deduction

## 9. Cleanup

- [ ] 9.1 Remove old `config.json` and `last_id.txt` usage
- [ ] 9.2 Remove old `storage.py` functions (load_config, save_config, etc.)
- [ ] 9.3 Update `settings.py` — remove unused constants, add DB-related settings

-- Migration: Database schema for Telegram Parser SaaS
-- Описание: Полная схема БД для мульти-клиентного парсинга Telegram

-- ============================================================
-- 1. Products — корень Class Table Inheritance
-- ============================================================
CREATE TABLE products (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_type    VARCHAR(20) NOT NULL CHECK (product_type IN ('subscription', 'addon')),
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    price           DECIMAL(10,2) NOT NULL,
    dodo_product_id VARCHAR(255),
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 2. Subscription plans (дочерняя от products)
-- ============================================================
CREATE TABLE subscription_plans (
    id                UUID PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    request_limit     INTEGER NOT NULL CHECK (request_limit > 0),
    symbol_limit      BIGINT NOT NULL CHECK (symbol_limit >= 0),
    filestorage_limit BIGINT NOT NULL CHECK (filestorage_limit >= 0),
    period_days       INTEGER NOT NULL CHECK (period_days > 0)
);

-- ============================================================
-- 3. Addon plans (дочерняя от products)
-- ============================================================
CREATE TABLE addon_plans (
    id           UUID PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    request_qty  INTEGER NOT NULL CHECK (request_qty > 0)
);

-- ============================================================
-- 4. Clients
-- ============================================================
CREATE TABLE clients (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name       VARCHAR(255) NOT NULL,
    contact    VARCHAR(255),
    is_active  BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 5. Subscriptions (подписка клиента — snapshot лимитов)
-- ============================================================
CREATE TABLE subscriptions (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id      UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    plan_id        UUID NOT NULL REFERENCES subscription_plans(id),
    total_requests INTEGER NOT NULL,
    used_requests  INTEGER NOT NULL DEFAULT 0 CHECK (used_requests >= 0),
    start_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date       DATE NOT NULL,
    is_active      BOOLEAN NOT NULL DEFAULT true,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 6. Addon purchases (купленные пакеты запросов)
-- ============================================================
CREATE TABLE addon_purchases (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id       UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    addon_plan_id   UUID NOT NULL REFERENCES addon_plans(id),
    total_requests  INTEGER NOT NULL,
    used_requests   INTEGER NOT NULL DEFAULT 0 CHECK (used_requests >= 0),
    is_used_up      BOOLEAN NOT NULL DEFAULT false,
    purchase_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    expires_at      DATE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 7. Channels (глобальный реестр Telegram-каналов)
-- ============================================================
CREATE TABLE channels (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username   VARCHAR(255) NOT NULL UNIQUE,
    title      VARCHAR(255),
    is_active  BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 8. Client channels (many-to-many: клиент <-> канал)
-- ============================================================
CREATE TABLE client_channels (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id  UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    channel_id UUID NOT NULL REFERENCES channels(id) ON DELETE CASCADE,
    is_active  BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(client_id, channel_id)
);

-- ============================================================
-- 9. Keyword filters (ключевые слова для поиска)
-- ============================================================
CREATE TABLE keyword_filters (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id  UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    channel_id UUID REFERENCES channels(id) ON DELETE CASCADE,
    keyword    VARCHAR(255) NOT NULL,
    is_active  BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 10. Matches (срабатывания — найденные сообщения)
-- ============================================================
CREATE TABLE matches (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id        UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    channel_id       UUID NOT NULL REFERENCES channels(id) ON DELETE CASCADE,
    keyword_filter_id UUID REFERENCES keyword_filters(id),
    telegram_msg_id  BIGINT NOT NULL,
    message_text     TEXT,
    message_link     TEXT,
    matched_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 11. Request usage log (аудит расходования запросов)
-- ============================================================
CREATE TABLE request_usage_log (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id          UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    channel_id         UUID NOT NULL REFERENCES channels(id) ON DELETE CASCADE,
    subscription_id    UUID REFERENCES subscriptions(id),
    addon_purchase_id  UUID REFERENCES addon_purchases(id),
    consumed_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- Indexes
-- ============================================================
CREATE INDEX idx_subscriptions_client_id      ON subscriptions(client_id);
CREATE INDEX idx_subscriptions_is_active      ON subscriptions(is_active);
CREATE INDEX idx_addon_purchases_client_id    ON addon_purchases(client_id);
CREATE INDEX idx_addon_purchases_is_used_up   ON addon_purchases(is_used_up);
CREATE INDEX idx_client_channels_client_id    ON client_channels(client_id);
CREATE INDEX idx_client_channels_channel_id   ON client_channels(channel_id);
CREATE INDEX idx_keyword_filters_client_id    ON keyword_filters(client_id);
CREATE INDEX idx_keyword_filters_channel_id   ON keyword_filters(channel_id);
CREATE INDEX idx_matches_client_id            ON matches(client_id);
CREATE INDEX idx_matches_channel_id           ON matches(channel_id);
CREATE INDEX idx_matches_matched_at           ON matches(matched_at);
CREATE INDEX idx_request_usage_log_client_id  ON request_usage_log(client_id);
CREATE INDEX idx_request_usage_log_consumed_at ON request_usage_log(consumed_at);

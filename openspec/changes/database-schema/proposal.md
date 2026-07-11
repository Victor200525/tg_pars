## Why

Текущий парсер Telegram — CLI-инструмент для одного пользователя и одного чата (настройки в JSON/txt файлах). Нужна реляционная база данных для превращения его в SaaS-сервис с клиентами, подписками, аддонами, гибкой системой каналов и отслеживанием срабатываний по ключевым словам.

## What Changes

- Внедрение PostgreSQL как постоянного хранилища
- **Новые таблицы**: `products`, `subscription_plans`, `addon_plans`, `clients`, `subscriptions`, `addon_purchases`, `channels`, `client_channels`, `keyword_filters`, `matches`, `request_usage_log`
- **BREAKING**: полная смена архитектуры хранения, старые файлы несовместимы

## Capabilities

### New Capabilities

- `client-management`: регистрация, активация/деактивация клиентов
- `subscription-plans`: управление продуктами, планами подписки, аддонами
- `channel-subscriptions`: привязка клиентов к каналам для парсинга
- `keyword-matching`: фильтрация сообщений по ключевым словам и запись срабатываний
- `request-tracking`: учёт расходуемых запросов (подписка + аддоны), контроль лимитов

### Modified Capabilities

*Нет существующих specs — проект с нуля*

## Impact

- **Ядро**: замена файлового storage на PostgreSQL
- **Нет обратной совместимости** со старым форматом данных

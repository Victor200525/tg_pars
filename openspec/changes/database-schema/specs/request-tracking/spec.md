## ADDED Requirements

### Requirement: Each parse cycle consumes one request per (client, channel)
The system SHALL decrement the request counter atomically for each parse cycle executed.

#### Scenario: Consume request from subscription
- **WHEN** a parse cycle starts for client A on channel X
- **THEN** the system atomically increments `subscriptions.used_requests` by 1
- **AND** the system logs the consumption in `request_usage_log`

### Requirement: Spillage — try subscription first, then addon
If the subscription request pool is exhausted, the system SHALL try the oldest active addon purchase.

#### Scenario: Exhausted subscription, use addon
- **WHEN** subscription.used_requests = subscription.total_requests
- **AND** client has an active addon_purchase with used_requests < total_requests
- **THEN** the system increments `addon_purchases.used_requests` by 1
- **AND** if used_requests = total_requests, sets is_used_up=true

### Requirement: Block client when all pools exhausted
If no subscription and no addon have remaining requests, the system SHALL NOT dispatch a parse cycle for that client.

#### Scenario: No requests remaining
- **WHEN** subscription is exhausted AND no addon has remaining requests
- **THEN** the system skips parsing for this client for this cycle
- **AND** logs a warning or sets a flag

### Requirement: Request consumption is atomic
The system SHALL use database-level atomic operations (UPDATE ... SET used_requests = used_requests + 1) to prevent race conditions.

#### Scenario: Concurrent cycles
- **WHEN** two parse cycles for the same client try to consume the last request concurrently
- **THEN** exactly one succeeds
- **AND** the second is redirected to addon or blocked

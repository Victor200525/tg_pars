## ADDED Requirements

### Requirement: Channels are a global registry
The system SHALL maintain a unique registry of Telegram channels, deduplicated by username.

#### Scenario: Add new channel
- **WHEN** a channel @durov is added to the system
- **THEN** a record is created in `channels` with username='@durov', is_active=true

#### Scenario: Prevent duplicate channel
- **WHEN** the same channel @durov is added again (with or without @)
- **THEN** the system normalizes the username and returns the existing channel record

### Requirement: Client subscribes to channels via client_channels
The many-to-many relationship SHALL be stored in `client_channels` with an active flag.

#### Scenario: Subscribe client to channel
- **WHEN** a client subscribes to a channel
- **THEN** a record is created in `client_channels` linking client_id and channel_id with is_active=true

#### Scenario: Unsubscribe from channel
- **WHEN** a client unsubscribes from a channel
- **THEN** `client_channels.is_active` is set to false (record is not deleted)

### Requirement: A channel is parsed once, matched per client
The parser SHALL fetch messages from each active channel once per cycle, then filter matches per subscribed client.

#### Scenario: Parse cycle for shared channel
- **WHEN** 3 clients are subscribed to @news
- **THEN** the parser fetches @news messages once
- **AND** matches are checked against each client's keyword_filters separately

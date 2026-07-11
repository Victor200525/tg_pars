## ADDED Requirements

### Requirement: Clients define keyword filters per channel or globally
The system SHALL let clients define keywords to match in messages. A filter can apply to all subscribed channels or a specific one.

#### Scenario: Create global keyword filter
- **WHEN** a client adds keyword "бонус" without specifying a channel
- **THEN** a record is created in `keyword_filters` with client_id, keyword='бонус', channel_id=NULL

#### Scenario: Create channel-specific filter
- **WHEN** a client adds keyword "акция" for channel @news only
- **THEN** a record is created in `keyword_filters` with client_id, channel_id, keyword='акция'

### Requirement: Matches are recorded when a keyword is found
When a new message matches a client's keyword filter, the system SHALL record it in `matches`.

#### Scenario: Match recorded
- **WHEN** a message in a subscribed channel contains a keyword from the client's filter
- **THEN** a record is created in `matches` with client_id, channel_id, keyword_filter_id, telegram_msg_id, message_text, matched_at=now()

### Requirement: Matches are read-only after creation
The system SHALL NOT allow deletion or modification of match records.

#### Scenario: Attempt to modify match
- **WHEN** a client tries to delete a match record
- **THEN** the system denies the operation (matches are append-only)

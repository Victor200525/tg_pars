## ADDED Requirements

### Requirement: System can register a client
The system SHALL store clients with unique identifier, name, contact info, and active status.

#### Scenario: Register new client
- **WHEN** a new client is added via the system
- **THEN** a record is created in `clients` table with id, name, contact, is_active=true, created_at=now()

### Requirement: Client can be deactivated
The system SHALL support activating/deactivating a client without deleting data.

#### Scenario: Deactivate client
- **WHEN** a client is deactivated
- **THEN** `clients.is_active` is set to false
- **AND** no new parsing cycles are dispatched for this client

### Requirement: Client data is immutable after creation
The system SHALL NOT delete client records — only soft-deactivate.

#### Scenario: Soft delete via deactivation
- **WHEN** a client is "deleted"
- **THEN** the record remains in `clients` with is_active=false

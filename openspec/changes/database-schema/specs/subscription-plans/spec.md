## ADDED Requirements

### Requirement: Products are the universal entry for all billable items
The system SHALL use a `products` table as the root for both subscription plans and addon plans (Class Table Inheritance).

#### Scenario: Create subscription product
- **WHEN** a new subscription plan is created
- **THEN** a record is inserted into `products` with product_type='subscription'
- **AND** a corresponding record is inserted into `subscription_plans` with the same id

#### Scenario: Create addon product
- **WHEN** a new addon plan is created
- **THEN** a record is inserted into `products` with product_type='addon'
- **AND** a corresponding record is inserted into `addon_plans` with the same id

### Requirement: Subscription plan defines periodic limits
A subscription plan SHALL define request_limit, symbol_limit, filestorage_limit, and period_days.

#### Scenario: Create subscription with limits
- **WHEN** admin creates a subscription plan with request_limit=1000, period_days=30
- **THEN** the subscription_plans table stores these values
- **AND** when a client purchases this plan, a snapshot of these limits is copied to `subscriptions`

### Requirement: Addon plan defines a one-time request pool
An addon plan SHALL define a quantity of requests (request_qty) that are added as a separate pool.

#### Scenario: Purchase addon
- **WHEN** a client purchases an addon with request_qty=500
- **THEN** a record is created in `addon_purchases` with total_requests=500, used_requests=0, is_used_up=false

### Requirement: Deactivating a product prevents new purchases
Setting a product's is_active=false SHALL prevent clients from purchasing it.

#### Scenario: Purchase deactivated product
- **WHEN** a client attempts to purchase a product with is_active=false
- **THEN** the system rejects the purchase

CREATE TABLE IF NOT EXISTS ranches (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    listing_key VARCHAR(64) NOT NULL,
    name VARCHAR(80) NOT NULL,
    type VARCHAR(32) NOT NULL,
    status VARCHAR(24) NOT NULL DEFAULT 'active',
    owner_character_id VARCHAR(64) NOT NULL,
    region_key VARCHAR(48) NOT NULL,
    x DECIMAL(10,4) NOT NULL, y DECIMAL(10,4) NOT NULL, z DECIMAL(10,4) NOT NULL, heading DECIMAL(7,3) NOT NULL DEFAULT 0,
    acquisition_price DECIMAL(18,2) NOT NULL, cash_balance DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    level SMALLINT UNSIGNED NOT NULL DEFAULT 1, reputation INT NOT NULL DEFAULT 0,
    last_simulated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, version INT UNSIGNED NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), UNIQUE KEY uq_ranches_listing_key (listing_key), KEY idx_ranches_owner (owner_character_id), KEY idx_ranches_status_region (status, region_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ranch_members (
    ranch_id BIGINT UNSIGNED NOT NULL, character_id VARCHAR(64) NOT NULL, role_key VARCHAR(32) NOT NULL,
    ownership_percent DECIMAL(5,2) NOT NULL DEFAULT 0.00, status VARCHAR(16) NOT NULL DEFAULT 'active',
    joined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, left_at DATETIME NULL,
    PRIMARY KEY (ranch_id, character_id), KEY idx_ranch_members_character (character_id, status),
    CONSTRAINT fk_ranch_members_ranch FOREIGN KEY (ranch_id) REFERENCES ranches(id) ON DELETE CASCADE,
    CONSTRAINT chk_ranch_member_share CHECK (ownership_percent >= 0 AND ownership_percent <= 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ranch_role_permissions (
    ranch_id BIGINT UNSIGNED NOT NULL, role_key VARCHAR(32) NOT NULL, permission_key VARCHAR(64) NOT NULL, allowed TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (ranch_id, role_key, permission_key),
    CONSTRAINT fk_ranch_permissions_ranch FOREIGN KEY (ranch_id) REFERENCES ranches(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ranch_leases (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, ranch_id BIGINT UNSIGNED NOT NULL, landlord_character_id VARCHAR(64) NOT NULL,
    tenant_character_id VARCHAR(64) NOT NULL, rent_amount DECIMAL(18,2) NOT NULL, deposit_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    starts_at DATETIME NOT NULL, ends_at DATETIME NOT NULL, status VARCHAR(16) NOT NULL DEFAULT 'active', created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_ranch_leases_tenant (tenant_character_id, status), KEY idx_ranch_leases_expiry (status, ends_at),
    CONSTRAINT fk_ranch_leases_ranch FOREIGN KEY (ranch_id) REFERENCES ranches(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ranch_ledger (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, ranch_id BIGINT UNSIGNED NOT NULL, actor_character_id VARCHAR(64) NULL,
    entry_type VARCHAR(32) NOT NULL, amount DECIMAL(18,2) NOT NULL, balance_after DECIMAL(18,2) NOT NULL,
    reference_type VARCHAR(32) NULL, reference_id VARCHAR(64) NULL, description VARCHAR(255) NOT NULL, occurred_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_ranch_ledger_ranch_time (ranch_id, occurred_at),
    CONSTRAINT fk_ranch_ledger_ranch FOREIGN KEY (ranch_id) REFERENCES ranches(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ranch_transactions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, idempotency_key CHAR(36) NOT NULL, ranch_id BIGINT UNSIGNED NULL,
    transaction_type VARCHAR(32) NOT NULL, status VARCHAR(16) NOT NULL, actor_character_id VARCHAR(64) NULL, payload_json JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, completed_at DATETIME NULL,
    PRIMARY KEY (id), UNIQUE KEY uq_ranch_transactions_idempotency (idempotency_key), KEY idx_ranch_transactions_ranch (ranch_id, created_at),
    CONSTRAINT fk_ranch_transactions_ranch FOREIGN KEY (ranch_id) REFERENCES ranches(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ranch_audit_log (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, ranch_id BIGINT UNSIGNED NULL, actor_character_id VARCHAR(64) NULL,
    action VARCHAR(64) NOT NULL, target_type VARCHAR(48) NULL, target_id VARCHAR(64) NULL, payload_json JSON NULL,
    occurred_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_ranch_audit_ranch_time (ranch_id, occurred_at), KEY idx_ranch_audit_actor_time (actor_character_id, occurred_at),
    CONSTRAINT fk_ranch_audit_ranch FOREIGN KEY (ranch_id) REFERENCES ranches(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ranch_pastures (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, ranch_id BIGINT UNSIGNED NOT NULL, name VARCHAR(80) NOT NULL,
    x DECIMAL(10,4) NOT NULL, y DECIMAL(10,4) NOT NULL, z DECIMAL(10,4) NOT NULL, radius DECIMAL(8,2) NOT NULL,
    capacity SMALLINT UNSIGNED NOT NULL, fertility DECIMAL(5,2) NOT NULL DEFAULT 100.00, quality DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    condition_value DECIMAL(5,2) NOT NULL DEFAULT 100.00, last_simulated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_ranch_pastures_ranch (ranch_id),
    CONSTRAINT fk_ranch_pastures_ranch FOREIGN KEY (ranch_id) REFERENCES ranches(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ranch_water_sources (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, ranch_id BIGINT UNSIGNED NOT NULL, pasture_id BIGINT UNSIGNED NULL,
    source_type VARCHAR(32) NOT NULL DEFAULT 'trough', x DECIMAL(10,4) NOT NULL, y DECIMAL(10,4) NOT NULL, z DECIMAL(10,4) NOT NULL,
    capacity DECIMAL(14,3) NOT NULL, current_amount DECIMAL(14,3) NOT NULL DEFAULT 0, quality DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    state VARCHAR(16) NOT NULL DEFAULT 'active', updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_ranch_water_ranch (ranch_id),
    CONSTRAINT fk_ranch_water_ranch FOREIGN KEY (ranch_id) REFERENCES ranches(id) ON DELETE CASCADE,
    CONSTRAINT fk_ranch_water_pasture FOREIGN KEY (pasture_id) REFERENCES ranch_pastures(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ranch_inventory (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, ranch_id BIGINT UNSIGNED NOT NULL, item_key VARCHAR(64) NOT NULL,
    quality DECIMAL(5,2) NOT NULL DEFAULT 100.00, quantity DECIMAL(14,3) NOT NULL DEFAULT 0, reserved_quantity DECIMAL(14,3) NOT NULL DEFAULT 0,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), UNIQUE KEY uq_ranch_inventory_item (ranch_id, item_key, quality), KEY idx_ranch_inventory_ranch (ranch_id),
    CONSTRAINT fk_ranch_inventory_ranch FOREIGN KEY (ranch_id) REFERENCES ranches(id) ON DELETE CASCADE,
    CONSTRAINT chk_ranch_inventory_amount CHECK (quantity >= 0 AND reserved_quantity >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ranch_animals (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, ranch_id BIGINT UNSIGNED NOT NULL, pasture_id BIGINT UNSIGNED NULL,
    species_key VARCHAR(32) NOT NULL, breed_key VARCHAR(48) NULL, sex VARCHAR(16) NOT NULL, name VARCHAR(80) NOT NULL,
    born_at DATETIME NOT NULL, weight DECIMAL(10,3) NOT NULL, health DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    hunger DECIMAL(5,2) NOT NULL DEFAULT 0.00, thirst DECIMAL(5,2) NOT NULL DEFAULT 0.00, happiness DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    stress DECIMAL(5,2) NOT NULL DEFAULT 0.00, hygiene DECIMAL(5,2) NOT NULL DEFAULT 100.00, quality DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    genetics_json JSON NULL, state VARCHAR(24) NOT NULL DEFAULT 'pasture', x DECIMAL(10,4) NULL, y DECIMAL(10,4) NULL, z DECIMAL(10,4) NULL,
    last_simulated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, version INT UNSIGNED NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_ranch_animals_ranch_state (ranch_id, state), KEY idx_ranch_animals_pasture (pasture_id), KEY idx_ranch_animals_simulation (last_simulated_at),
    CONSTRAINT fk_ranch_animals_ranch FOREIGN KEY (ranch_id) REFERENCES ranches(id) ON DELETE CASCADE,
    CONSTRAINT fk_ranch_animals_pasture FOREIGN KEY (pasture_id) REFERENCES ranch_pastures(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ranch_animal_care_log (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, animal_id BIGINT UNSIGNED NULL, ranch_id BIGINT UNSIGNED NOT NULL,
    actor_character_id VARCHAR(64) NULL, action_type VARCHAR(32) NOT NULL, item_key VARCHAR(64) NULL, quantity DECIMAL(14,3) NULL,
    payload_json JSON NULL, occurred_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), KEY idx_animal_care_ranch_time (ranch_id, occurred_at), KEY idx_animal_care_animal_time (animal_id, occurred_at),
    CONSTRAINT fk_animal_care_ranch FOREIGN KEY (ranch_id) REFERENCES ranches(id) ON DELETE CASCADE,
    CONSTRAINT fk_animal_care_animal FOREIGN KEY (animal_id) REFERENCES ranch_animals(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

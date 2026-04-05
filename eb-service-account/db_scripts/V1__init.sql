-- Flyway baseline init script for eb-service-account

CREATE TABLE eb_account (
    id BIGINT UNSIGNED NOT NULL,
    account_no VARCHAR(32) NOT NULL,
    user_no VARCHAR(32) NOT NULL,
    account_type TINYINT UNSIGNED NOT NULL,
    currency CHAR(3) NOT NULL,
    status TINYINT UNSIGNED NOT NULL DEFAULT 1,
    available_balance DECIMAL(19,4) NOT NULL DEFAULT 0.0000,
    frozen_balance DECIMAL(19,4) NOT NULL DEFAULT 0.0000,
    version INT UNSIGNED NOT NULL DEFAULT 0,
    opened_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    closed_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_eb_account_account_no (account_no),
    KEY idx_eb_account_user_status (user_no, status),
    KEY idx_eb_account_account_type_status (account_type, status),
    KEY idx_eb_account_currency_status (currency, status),
    KEY idx_eb_account_status (status)
) ENGINE=InnoDB;

CREATE TABLE eb_account_balance_change (
    id BIGINT UNSIGNED NOT NULL,
    change_no VARCHAR(32) NOT NULL,
    account_no VARCHAR(32) NOT NULL,
    change_type TINYINT UNSIGNED NOT NULL,
    direction TINYINT UNSIGNED NOT NULL,
    amount DECIMAL(19,4) NOT NULL,
    before_available_balance DECIMAL(19,4) NOT NULL,
    after_available_balance DECIMAL(19,4) NOT NULL,
    before_frozen_balance DECIMAL(19,4) NOT NULL,
    after_frozen_balance DECIMAL(19,4) NOT NULL,
    biz_no VARCHAR(32) NULL,
    request_id VARCHAR(64) NULL,
    trace_id VARCHAR(64) NULL,
    occurred_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_eb_account_balance_change_no (change_no),
    KEY idx_eb_account_balance_change_account_time (account_no, occurred_at),
    KEY idx_eb_account_balance_change_type_time (change_type, occurred_at),
    KEY idx_eb_account_balance_change_biz_no (biz_no),
    KEY idx_eb_account_balance_change_request_id (request_id),
    KEY idx_eb_account_balance_change_trace_id (trace_id)
) ENGINE=InnoDB;

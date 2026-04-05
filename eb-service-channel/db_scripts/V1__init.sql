-- Flyway baseline init script for eb-service-channel

CREATE TABLE eb_channel_partner (
    id BIGINT UNSIGNED NOT NULL,
    partner_code VARCHAR(32) NOT NULL,
    partner_name VARCHAR(64) NOT NULL,
    partner_type TINYINT UNSIGNED NOT NULL,
    base_url VARCHAR(255) NOT NULL,
    auth_type TINYINT UNSIGNED NOT NULL,
    secret_ref VARCHAR(128) NOT NULL,
    timeout_ms INT UNSIGNED NOT NULL DEFAULT 3000,
    status TINYINT UNSIGNED NOT NULL DEFAULT 1,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_eb_channel_partner_code (partner_code),
    KEY idx_eb_channel_partner_type_status (partner_type, status),
    KEY idx_eb_channel_partner_status (status)
) ENGINE=InnoDB;

CREATE TABLE eb_channel_transfer_request (
    id BIGINT UNSIGNED NOT NULL,
    channel_request_no VARCHAR(32) NOT NULL,
    transfer_no VARCHAR(32) NOT NULL,
    partner_code VARCHAR(32) NOT NULL,
    partner_order_no VARCHAR(64) NULL,
    request_type TINYINT UNSIGNED NOT NULL,
    request_status TINYINT UNSIGNED NOT NULL,
    retry_count INT UNSIGNED NOT NULL DEFAULT 0,
    http_status SMALLINT UNSIGNED NULL,
    channel_status_code VARCHAR(32) NULL,
    channel_status_message VARCHAR(255) NULL,
    request_payload_json JSON NULL,
    response_payload_json JSON NULL,
    sent_at DATETIME(3) NULL,
    last_callback_at DATETIME(3) NULL,
    finished_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_eb_channel_transfer_request_no (channel_request_no),
    UNIQUE KEY uk_eb_channel_transfer_partner_order (partner_code, partner_order_no),
    KEY idx_eb_channel_transfer_transfer_no (transfer_no),
    KEY idx_eb_channel_transfer_partner_status (partner_code, request_status),
    KEY idx_eb_channel_transfer_status_updated (request_status, updated_at)
) ENGINE=InnoDB;

CREATE TABLE eb_channel_callback_record (
    id BIGINT UNSIGNED NOT NULL,
    callback_no VARCHAR(32) NOT NULL,
    partner_code VARCHAR(32) NOT NULL,
    callback_dedup_key VARCHAR(64) NOT NULL,
    partner_order_no VARCHAR(64) NULL,
    transfer_no VARCHAR(32) NULL,
    callback_type TINYINT UNSIGNED NOT NULL,
    callback_status TINYINT UNSIGNED NOT NULL,
    signature_status TINYINT UNSIGNED NOT NULL,
    raw_payload_json JSON NULL,
    received_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    processed_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_eb_channel_callback_no (callback_no),
    UNIQUE KEY uk_eb_channel_callback_dedup (partner_code, callback_dedup_key),
    KEY idx_eb_channel_callback_partner_order (partner_code, partner_order_no),
    KEY idx_eb_channel_callback_transfer_time (transfer_no, received_at),
    KEY idx_eb_channel_callback_status_time (callback_status, received_at)
) ENGINE=InnoDB;

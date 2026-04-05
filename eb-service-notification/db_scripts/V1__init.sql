-- Flyway baseline init script for eb-service-notification

CREATE TABLE eb_notification_template (
    id BIGINT UNSIGNED NOT NULL,
    template_code VARCHAR(32) NOT NULL,
    template_name VARCHAR(64) NOT NULL,
    channel_type TINYINT UNSIGNED NOT NULL,
    lang_code VARCHAR(16) NOT NULL DEFAULT 'zh-CN',
    title_template VARCHAR(255) NOT NULL,
    body_template TEXT NOT NULL,
    status TINYINT UNSIGNED NOT NULL DEFAULT 1,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_eb_notification_template_code (template_code),
    KEY idx_eb_notification_template_channel_status (channel_type, status),
    KEY idx_eb_notification_template_status (status)
) ENGINE=InnoDB;

CREATE TABLE eb_notification_message (
    id BIGINT UNSIGNED NOT NULL,
    message_no VARCHAR(32) NOT NULL,
    biz_no VARCHAR(32) NULL,
    biz_type TINYINT UNSIGNED NOT NULL,
    template_code VARCHAR(32) NOT NULL,
    recipient_no VARCHAR(64) NOT NULL,
    channel_type TINYINT UNSIGNED NOT NULL,
    send_status TINYINT UNSIGNED NOT NULL,
    retry_count INT UNSIGNED NOT NULL DEFAULT 0,
    max_retry_count INT UNSIGNED NOT NULL DEFAULT 0,
    payload_json JSON NULL,
    fail_reason_code VARCHAR(32) NULL,
    fail_reason_message VARCHAR(255) NULL,
    next_retry_at DATETIME(3) NULL,
    sent_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_eb_notification_message_no (message_no),
    KEY idx_eb_notification_message_biz_no (biz_no),
    KEY idx_eb_notification_message_biz_type_time (biz_type, created_at),
    KEY idx_eb_notification_message_template_code (template_code),
    KEY idx_eb_notification_message_recipient_time (recipient_no, created_at),
    KEY idx_eb_notification_message_channel_status (channel_type, send_status),
    KEY idx_eb_notification_message_status_retry (send_status, next_retry_at)
) ENGINE=InnoDB;

-- Flyway baseline init script for eb-service-audit

CREATE TABLE eb_audit_log (
    id BIGINT UNSIGNED NOT NULL,
    audit_no VARCHAR(32) NOT NULL,
    operator_type TINYINT UNSIGNED NOT NULL,
    operator_no VARCHAR(32) NULL,
    action_code VARCHAR(32) NOT NULL,
    target_type VARCHAR(32) NULL,
    target_no VARCHAR(32) NULL,
    request_id VARCHAR(64) NULL,
    trace_id VARCHAR(64) NULL,
    result_status TINYINT UNSIGNED NOT NULL,
    client_ip VARCHAR(45) NULL,
    detail_json JSON NULL,
    occurred_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_eb_audit_log_no (audit_no),
    KEY idx_eb_audit_log_operator_time (operator_no, occurred_at),
    KEY idx_eb_audit_log_action_time (action_code, occurred_at),
    KEY idx_eb_audit_log_target_time (target_type, target_no, occurred_at),
    KEY idx_eb_audit_log_request_id (request_id),
    KEY idx_eb_audit_log_trace_id (trace_id),
    KEY idx_eb_audit_log_result_time (result_status, occurred_at)
) ENGINE=InnoDB;

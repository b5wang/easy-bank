-- Flyway baseline init script for eb-service-risk

CREATE TABLE eb_risk_rule (
    id BIGINT UNSIGNED NOT NULL,
    rule_code VARCHAR(32) NOT NULL,
    rule_name VARCHAR(64) NOT NULL,
    rule_scene TINYINT UNSIGNED NOT NULL,
    rule_type TINYINT UNSIGNED NOT NULL,
    rule_config_json JSON NULL,
    action_type TINYINT UNSIGNED NOT NULL,
    priority SMALLINT UNSIGNED NOT NULL DEFAULT 100,
    status TINYINT UNSIGNED NOT NULL DEFAULT 1,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_eb_risk_rule_code (rule_code),
    KEY idx_eb_risk_rule_scene_status_pri (rule_scene, status, priority),
    KEY idx_eb_risk_rule_status (status)
) ENGINE=InnoDB;

CREATE TABLE eb_risk_decision (
    id BIGINT UNSIGNED NOT NULL,
    decision_no VARCHAR(32) NOT NULL,
    risk_scene TINYINT UNSIGNED NOT NULL,
    biz_no VARCHAR(32) NULL,
    request_id VARCHAR(64) NULL,
    user_no VARCHAR(32) NULL,
    account_no VARCHAR(32) NULL,
    decision_result TINYINT UNSIGNED NOT NULL,
    risk_score DECIMAL(8,2) NULL,
    reason_code VARCHAR(32) NULL,
    reason_message VARCHAR(255) NULL,
    hit_rule_snapshot_json JSON NULL,
    trace_id VARCHAR(64) NULL,
    decided_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_eb_risk_decision_no (decision_no),
    KEY idx_eb_risk_decision_scene_result_time (risk_scene, decision_result, decided_at),
    KEY idx_eb_risk_decision_biz_no (biz_no),
    KEY idx_eb_risk_decision_request_id (request_id),
    KEY idx_eb_risk_decision_user_time (user_no, decided_at),
    KEY idx_eb_risk_decision_account_time (account_no, decided_at),
    KEY idx_eb_risk_decision_trace_id (trace_id)
) ENGINE=InnoDB;

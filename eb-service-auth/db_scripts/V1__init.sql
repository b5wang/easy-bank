-- Flyway baseline init script for eb-service-auth

CREATE TABLE eb_user (
    id BIGINT UNSIGNED NOT NULL,
    user_no VARCHAR(32) NOT NULL,
    username VARCHAR(64) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    password_algo VARCHAR(32) NOT NULL,
    display_name VARCHAR(64) NOT NULL,
    status TINYINT UNSIGNED NOT NULL DEFAULT 1,
    failed_login_count INT UNSIGNED NOT NULL DEFAULT 0,
    locked_until DATETIME(3) NULL,
    last_login_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_eb_user_user_no (user_no),
    UNIQUE KEY uk_eb_user_username (username),
    KEY idx_eb_user_status (status)
) ENGINE=InnoDB;

CREATE TABLE eb_role (
    id BIGINT UNSIGNED NOT NULL,
    role_code VARCHAR(32) NOT NULL,
    role_name VARCHAR(64) NOT NULL,
    status TINYINT UNSIGNED NOT NULL DEFAULT 1,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_eb_role_role_code (role_code),
    KEY idx_eb_role_status (status)
) ENGINE=InnoDB;

CREATE TABLE eb_user_role (
    id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    role_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_eb_user_role_user_role (user_id, role_id),
    KEY idx_eb_user_role_role_id (role_id)
) ENGINE=InnoDB;

CREATE TABLE eb_login_attempt (
    id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NULL,
    username_snapshot VARCHAR(64) NOT NULL,
    request_id VARCHAR(64) NOT NULL,
    client_ip VARCHAR(45) NOT NULL,
    result_status TINYINT UNSIGNED NOT NULL,
    failure_code VARCHAR(32) NULL,
    trace_id VARCHAR(64) NULL,
    attempted_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY idx_eb_login_attempt_user_time (user_id, attempted_at),
    KEY idx_eb_login_attempt_username_time (username_snapshot, attempted_at),
    KEY idx_eb_login_attempt_ip_time (client_ip, attempted_at),
    KEY idx_eb_login_attempt_result_time (result_status, attempted_at),
    KEY idx_eb_login_attempt_request_id (request_id),
    KEY idx_eb_login_attempt_trace_id (trace_id)
) ENGINE=InnoDB;

CREATE TABLE eb_user_session (
    id BIGINT UNSIGNED NOT NULL,
    session_no VARCHAR(32) NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    access_jti VARCHAR(64) NOT NULL,
    refresh_token_hash CHAR(64) NULL,
    session_status TINYINT UNSIGNED NOT NULL DEFAULT 1,
    issued_at DATETIME(3) NOT NULL,
    expire_at DATETIME(3) NOT NULL,
    last_seen_at DATETIME(3) NULL,
    client_ip VARCHAR(45) NULL,
    user_agent VARCHAR(255) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_eb_user_session_session_no (session_no),
    UNIQUE KEY uk_eb_user_session_access_jti (access_jti),
    UNIQUE KEY uk_eb_user_session_refresh_hash (refresh_token_hash),
    KEY idx_eb_user_session_user_status_expire (user_id, session_status, expire_at),
    KEY idx_eb_user_session_status_expire (session_status, expire_at),
    KEY idx_eb_user_session_expire_at (expire_at)
) ENGINE=InnoDB;

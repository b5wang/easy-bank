# 数据结构设计概览
*Data Model Overview*

## 1. 文档目标
*Document Goal*

根据当前协作约定，在进入编码之前必须先明确业务数据对象及其关系。这份文档用于给出本项目第一版数据库结构设计概览，明确每个微服务拥有哪些核心表，以及不同业务对象之间如何关联。  
According to the current collaboration rules, the business data objects and their relationships must be defined before coding begins. This document provides the first-pass database design overview for the project and clarifies which core tables belong to each microservice and how the business objects relate to one another.

这里的设计目标不是追求生产级细节完整度，而是给出一版足够清晰、能直接映射到 `MySQL 8.4 + Flyway` 的核心表设计，帮助后续进入数据库脚本和 JPA 映射阶段。  
The goal here is not to capture every production-grade detail. It is to provide a clear first version of the core table design that can be mapped directly to `MySQL 8.4 + Flyway`, so later work can move into migration scripts and JPA mappings with less ambiguity.

## 2. 数据归属与建模原则
*Data Ownership and Modeling Principles*

### 2.1 关联关系规则
*Relationship Rules*

所有表统一不建立数据库外键约束，哪怕两个表位于同一个微服务数据库中，也不通过数据库外键维护关联。表之间的关联由 Java 代码、业务唯一键、状态机和应用层校验来控制。  
No database foreign-key constraints should be created anywhere, even when two tables belong to the same microservice database. Table relationships are controlled through Java code, business identifiers, state transitions, and application-layer validation.

跨服务关联优先使用业务唯一键，例如 `user_no`、`account_no`、`transfer_no`、`request_id`、`partner_code`，而不是直接依赖另一服务库中的自增主键或外键引用。  
Cross-service relationships should prefer business identifiers such as `user_no`, `account_no`, `transfer_no`, `request_id`, and `partner_code` rather than relying on another service database’s local primary key or foreign-key reference.

同一服务内部如果确实需要表达从属关系，可以保留 `*_id`、`*_no` 或 `*_code` 这类关联字段，但它们只作为查询和业务校验使用，不附带数据库级联约束。  
When a parent-child relationship needs to exist inside one service, fields such as `*_id`, `*_no`, or `*_code` may still be stored for lookup and business validation, but they must not carry database-level cascade constraints.

### 2.2 字段类型约定
*Field Type Conventions*

以下字段类型约定以 `MySQL 8.4.x` 为准：  
The following field-type conventions target `MySQL 8.4.x`:

| 字段类别<br>Field Category | 推荐类型<br>Recommended Type | 说明<br>Description |
| --- | --- | --- |
| 主键<br>Primary key | `BIGINT` | 统一使用雪花风格 64 位 ID，由应用侧生成 |
| 业务唯一编号<br>Business unique number | `VARCHAR(32)` | 适用于 `user_no`、`account_no`、`transfer_no`、`message_no` 等 |
| 请求与链路标识<br>Request and trace identifiers | `VARCHAR(64)` | 适用于 `request_id`、`trace_id`、`jti`、幂等键 |
| 金额<br>Amount | `DECIMAL(19,4)` | 满足当前阶段人民币和常见货币金额精度 |
| 币种<br>Currency | `CHAR(3)` | 使用 ISO 风格三位币种码，如 `CNY` |
| 状态与类型枚举<br>Status and type enums | `TINYINT UNSIGNED` / `SMALLINT UNSIGNED` | 由 Java 枚举维护语义，数据库只存编码 |
| 计数与版本号<br>Counters and version fields | `INT UNSIGNED` | 适用于 `retry_count`、`version`、`max_retry_count` |
| 时间戳<br>Timestamps | `DATETIME(3)` | 保留毫秒级时间，便于排障与排序 |
| 日期<br>Date | `DATE` | 适用于对账日、账期等自然日语义 |
| 快照与可变结构<br>Snapshots and variable payloads | `JSON` | 只用于快照、模板参数、第三方报文，不参与首批索引 |
| 长文本<br>Long text | `VARCHAR(255)` / `VARCHAR(500)` / `TEXT` | 优先短文本，只有模板正文和大报文才使用 `TEXT` |

### 2.3 索引设计约定
*Index Design Conventions*

索引只围绕真实查询路径设计，不因为“字段看起来重要”就盲目建索引。  
Indexes should be created only for real access paths, not just because a field looks important.

第一类索引是业务唯一查找，例如 `user_no`、`account_no`、`transfer_no`、`request_id`、`partner_code` 这类唯一键。  
The first category is business-unique lookup, such as `user_no`, `account_no`, `transfer_no`, `request_id`, and `partner_code`.

第二类索引是时间线查询，例如账户流水、审计日志、通知记录、回调记录这类需要按业务键加时间倒序查看的表。  
The second category is timeline queries, such as balance history, audit logs, notification messages, and callback records that are usually retrieved by business key plus time ordering.

第三类索引是任务扫描，例如重试任务、通知重试、对账结果和状态流转扫描，这类表优先设计成 `(status, next_retry_at)` 或 `(status, updated_at)` 这样的复合索引。  
The third category is task scanning, such as retry tasks, notification retries, reconciliation results, and workflow scans. These tables should prefer composite indexes like `(status, next_retry_at)` or `(status, updated_at)`.

如果一个复合索引已经覆盖了常用前导列，就不要再重复建完全冗余的单列索引。  
If a composite index already covers the commonly used leading column, do not add a fully redundant single-column index.

对于 `JSON` 字段，当前阶段默认只作为快照和审计辅助保存，不在第一版设计中建立函数索引。  
For `JSON` fields, the current phase treats them as snapshots and audit helpers only. No functional indexes should be added in the first version.

## 3. 各服务核心数据对象与表设计
*Core Data Objects and Table Design by Service*

### 3.1 eb-service-auth

认证服务负责用户身份、角色关系、登录失败记录和会话态或令牌撤销态。这里的数据写频率不算极端，但读取路径比较明确，主要集中在 `username`、`user_no`、`role_code` 和有效会话查询。  
The authentication service owns user identity, role assignments, login-attempt records, and session or token-revocation state. The write rate is not extremely high, but the main read paths are clear and center on `username`, `user_no`, `role_code`, and active-session lookups.

#### 3.1.1 eb_user

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键，雪花风格 ID |
| `user_no` | `VARCHAR(32)` | `UK` | 用户业务号，跨服务引用优先使用 |
| `username` | `VARCHAR(64)` | `UK` | 登录名 |
| `password_hash` | `VARCHAR(255)` |  | 密码哈希值 |
| `password_algo` | `VARCHAR(32)` |  | 密码算法标识，如 `bcrypt` |
| `display_name` | `VARCHAR(64)` |  | 展示名称 |
| `status` | `TINYINT UNSIGNED` | `IDX(status)` | 用户状态，如正常、锁定、停用 |
| `failed_login_count` | `INT UNSIGNED` |  | 连续失败次数 |
| `locked_until` | `DATETIME(3)` |  | 锁定截止时间 |
| `last_login_at` | `DATETIME(3)` |  | 最近成功登录时间 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

`eb_user` 的热点查找路径是 `username` 和 `user_no`，因此两个唯一索引都需要保留；`status` 单列索引主要服务于后台筛选和批量状态检查。  
`eb_user` is mainly accessed by `username` and `user_no`, so both unique indexes should be kept. The single-column `status` index mainly supports back-office filtering and batch status checks.

#### 3.1.2 eb_role

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `role_code` | `VARCHAR(32)` | `UK` | 角色编码，如 `USER`、`ADMIN` |
| `role_name` | `VARCHAR(64)` |  | 角色名称 |
| `status` | `TINYINT UNSIGNED` | `IDX(status)` | 角色状态 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

`eb_role` 的核心是 `role_code` 唯一约束，避免权限模型在代码和数据库中出现重复角色编码。  
The key design point of `eb_role` is the unique `role_code`, which prevents duplicate role definitions across code and data.

#### 3.1.3 eb_user_role

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `user_id` | `BIGINT` | `UK(user_id, role_id)` | 关联用户主键，不建外键 |
| `role_id` | `BIGINT` | `UK(user_id, role_id)` / `IDX(role_id)` | 关联角色主键，不建外键 |
| `created_at` | `DATETIME(3)` |  | 绑定时间 |

这里保留 `user_id` 与 `role_id` 作为应用层关联键，但不建立数据库外键；唯一约束负责避免同一用户重复绑定同一角色。  
`user_id` and `role_id` are kept as application-level relation keys, but no foreign key is created. The unique constraint prevents duplicate bindings of the same role to the same user.

#### 3.1.4 eb_login_attempt

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `user_id` | `BIGINT` | `IDX(user_id, attempted_at)` | 关联用户主键，可为空 |
| `username_snapshot` | `VARCHAR(64)` | `IDX(username_snapshot, attempted_at)` | 本次尝试使用的登录名快照 |
| `request_id` | `VARCHAR(64)` | `IDX(request_id)` | 请求标识 |
| `client_ip` | `VARCHAR(45)` | `IDX(client_ip, attempted_at)` | 客户端 IP |
| `result_status` | `TINYINT UNSIGNED` | `IDX(result_status, attempted_at)` | 成功或失败结果 |
| `failure_code` | `VARCHAR(32)` |  | 失败原因编码 |
| `trace_id` | `VARCHAR(64)` | `IDX(trace_id)` | 链路标识 |
| `attempted_at` | `DATETIME(3)` |  | 尝试时间 |

这张表是典型追加写日志表，索引重点放在“按用户 / 用户名 / IP 查看最近失败记录”和按 `request_id`、`trace_id` 回溯单次登录流程。  
This is a typical append-only log table. Its indexes focus on “recent failures by user, username, or IP” and on tracing a single login flow through `request_id` and `trace_id`.

#### 3.1.5 eb_user_session

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `session_no` | `VARCHAR(32)` | `UK` | 会话业务号 |
| `user_id` | `BIGINT` | `IDX(user_id, session_status, expire_at)` | 关联用户主键 |
| `access_jti` | `VARCHAR(64)` | `UK` | Access Token 的唯一标识 |
| `refresh_token_hash` | `CHAR(64)` | `UK` | Refresh Token 哈希，用于续签或撤销 |
| `session_status` | `TINYINT UNSIGNED` | `IDX(session_status, expire_at)` | 会话状态 |
| `issued_at` | `DATETIME(3)` |  | 签发时间 |
| `expire_at` | `DATETIME(3)` | `IDX(expire_at)` | 过期时间 |
| `last_seen_at` | `DATETIME(3)` |  | 最近访问时间 |
| `client_ip` | `VARCHAR(45)` |  | 最近访问 IP |
| `user_agent` | `VARCHAR(255)` |  | 客户端标识 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

`eb_user_session` 主要支持按 `user_id` 查看活跃会话、按 `jti` 或 `refresh_token_hash` 查撤销态，以及按 `expire_at` 清理过期记录。  
`eb_user_session` mainly supports active-session queries by `user_id`, revocation lookup by `jti` or `refresh_token_hash`, and cleanup by `expire_at`.

### 3.2 eb-service-account

账户服务是余额唯一权威写入方，因此表设计要优先服务余额读写效率、并发控制和流水审计。  
The account service is the single authoritative writer for balances, so the table design must prioritize balance read/write efficiency, concurrency control, and history auditing.

#### 3.2.1 eb_account

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `account_no` | `VARCHAR(32)` | `UK` | 账户业务号，账户域核心查询键 |
| `user_no` | `VARCHAR(32)` | `IDX(user_no, status)` | 账户所属用户业务号 |
| `account_type` | `TINYINT UNSIGNED` | `IDX(account_type, status)` | 账户类型 |
| `currency` | `CHAR(3)` | `IDX(currency, status)` | 币种 |
| `status` | `TINYINT UNSIGNED` | `IDX(status)` | 账户状态 |
| `available_balance` | `DECIMAL(19,4)` |  | 可用余额 |
| `frozen_balance` | `DECIMAL(19,4)` |  | 冻结余额 |
| `version` | `INT UNSIGNED` |  | 乐观锁版本号 |
| `opened_at` | `DATETIME(3)` |  | 开户时间 |
| `closed_at` | `DATETIME(3)` |  | 销户时间 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

余额表尽量保持“宽度可控、单行可直接更新”的设计，不把过多非核心字段塞进 `eb_account`。热点查找只保留 `account_no`、`user_no + status` 这类真实访问路径。  
The balance table should stay compact enough for direct single-row updates and should not absorb too many non-core fields. Hot lookups are intentionally limited to real access paths such as `account_no` and `user_no + status`.

#### 3.2.2 eb_account_balance_change

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `change_no` | `VARCHAR(32)` | `UK` | 流水业务号 |
| `account_no` | `VARCHAR(32)` | `IDX(account_no, occurred_at)` | 所属账户号 |
| `change_type` | `TINYINT UNSIGNED` | `IDX(change_type, occurred_at)` | 余额变更类型 |
| `direction` | `TINYINT UNSIGNED` |  | 入账或扣减方向 |
| `amount` | `DECIMAL(19,4)` |  | 本次变动金额 |
| `before_available_balance` | `DECIMAL(19,4)` |  | 变更前可用余额 |
| `after_available_balance` | `DECIMAL(19,4)` |  | 变更后可用余额 |
| `before_frozen_balance` | `DECIMAL(19,4)` |  | 变更前冻结余额 |
| `after_frozen_balance` | `DECIMAL(19,4)` |  | 变更后冻结余额 |
| `biz_no` | `VARCHAR(32)` | `IDX(biz_no)` | 关联业务单号，如转账单号 |
| `request_id` | `VARCHAR(64)` | `IDX(request_id)` | 请求标识 |
| `trace_id` | `VARCHAR(64)` | `IDX(trace_id)` | 链路标识 |
| `occurred_at` | `DATETIME(3)` |  | 变动发生时间 |

账户流水是高写入追加表，索引只围绕“按账户查时间线”和“按业务单回放资金变化”设计，避免过度索引影响写性能。  
Balance history is a high-write append-only table. Its indexes are intentionally limited to “timeline by account” and “fund changes by business number” so that write performance is not overburdened.

### 3.3 eb-service-transfer

转账服务负责订单生命周期和流程编排，因此表设计要能清楚表达状态机、步骤状态和幂等控制。  
The transfer service owns order lifecycle and orchestration, so its tables must clearly express the state machine, step states, and idempotency handling.

#### 3.3.1 eb_transfer_order

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `transfer_no` | `VARCHAR(32)` | `UK` | 转账业务单号 |
| `request_id` | `VARCHAR(64)` | `UK` | 请求标识，支持接口级唯一查找 |
| `transfer_type` | `TINYINT UNSIGNED` | `IDX(transfer_type, status)` | 转账类型，如站内、跨行、平台出款 |
| `source_account_no` | `VARCHAR(32)` | `IDX(source_account_no, created_at)` | 转出账户号 |
| `target_account_no` | `VARCHAR(32)` | `IDX(target_account_no, created_at)` | 转入账户号或目标账户号 |
| `channel_partner_code` | `VARCHAR(32)` | `IDX(channel_partner_code, status)` | 外部渠道编码，可为空 |
| `amount` | `DECIMAL(19,4)` |  | 转账金额 |
| `currency` | `CHAR(3)` |  | 币种 |
| `status` | `TINYINT UNSIGNED` | `IDX(status, updated_at)` | 主订单状态 |
| `current_step_code` | `VARCHAR(32)` |  | 当前流程步骤编码 |
| `risk_status` | `TINYINT UNSIGNED` |  | 风控状态 |
| `channel_status` | `TINYINT UNSIGNED` |  | 渠道状态 |
| `fail_reason_code` | `VARCHAR(32)` |  | 失败原因编码 |
| `fail_reason_message` | `VARCHAR(255)` |  | 失败原因摘要 |
| `trace_id` | `VARCHAR(64)` | `IDX(trace_id)` | 链路标识 |
| `version` | `INT UNSIGNED` |  | 乐观锁版本号 |
| `completed_at` | `DATETIME(3)` |  | 完成时间 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

`eb_transfer_order` 是编排核心表，索引重点是 `transfer_no`、`request_id`、账户维度时间线，以及按 `status + updated_at` 扫描待处理订单。  
`eb_transfer_order` is the orchestration core table. Its key indexes support lookup by `transfer_no`, `request_id`, account-based timelines, and scans of pending orders by `status + updated_at`.

#### 3.3.2 eb_transfer_step

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `transfer_no` | `VARCHAR(32)` | `UK(transfer_no, step_code)` / `IDX(transfer_no, execute_seq)` | 所属转账单号 |
| `step_code` | `VARCHAR(32)` | `UK(transfer_no, step_code)` | 步骤编码，如风控、冻结、出款 |
| `execute_seq` | `SMALLINT UNSIGNED` | `IDX(transfer_no, execute_seq)` | 步骤执行顺序 |
| `step_status` | `TINYINT UNSIGNED` | `IDX(step_status, next_retry_at)` | 步骤状态 |
| `retry_count` | `INT UNSIGNED` |  | 当前重试次数 |
| `max_retry_count` | `INT UNSIGNED` |  | 最大重试次数 |
| `last_error_code` | `VARCHAR(32)` |  | 最近失败编码 |
| `last_error_message` | `VARCHAR(255)` |  | 最近失败摘要 |
| `next_retry_at` | `DATETIME(3)` | `IDX(step_status, next_retry_at)` | 下一次可重试时间 |
| `started_at` | `DATETIME(3)` |  | 步骤开始时间 |
| `finished_at` | `DATETIME(3)` |  | 步骤结束时间 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

步骤表的核心价值是把订单级状态拆成可观察、可重试、可补偿的细粒度流程节点，便于后续 `Saga` 和运维补偿设计。  
The main value of the step table is to break an order-level state into observable, retryable, and compensatable workflow nodes, which later supports `Saga` and operations-side compensation.

#### 3.3.3 eb_transfer_idempotency

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `request_id` | `VARCHAR(64)` | `UK` | 幂等请求标识 |
| `request_hash` | `CHAR(64)` |  | 请求体规范化哈希，防止同键异参 |
| `transfer_no` | `VARCHAR(32)` | `IDX(transfer_no)` | 命中的转账单号 |
| `process_status` | `TINYINT UNSIGNED` | `IDX(process_status, expire_at)` | 幂等处理状态 |
| `response_code` | `VARCHAR(32)` |  | 首次处理响应码 |
| `response_snapshot_json` | `JSON` |  | 首次处理结果快照 |
| `expire_at` | `DATETIME(3)` | `IDX(expire_at)` | 幂等记录过期时间 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

幂等表不追求复杂查询，主要服务于 `request_id` 命中和过期清理，因此只保留唯一键和少量状态扫描索引。  
The idempotency table is not designed for complex querying. It mainly serves `request_id` lookup and expiration cleanup, so only one unique key and minimal status-scan indexes are kept.

### 3.4 eb-service-channel

渠道服务负责外部适配和回调处理，表设计重点是渠道配置、对外请求状态和回调去重。  
The channel service handles external integration and callbacks. Its tables focus on partner configuration, outbound-request status, and callback deduplication.

#### 3.4.1 eb_channel_partner

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `partner_code` | `VARCHAR(32)` | `UK` | 渠道编码 |
| `partner_name` | `VARCHAR(64)` |  | 渠道名称 |
| `partner_type` | `TINYINT UNSIGNED` | `IDX(partner_type, status)` | 渠道类型 |
| `base_url` | `VARCHAR(255)` |  | 渠道请求基础地址 |
| `auth_type` | `TINYINT UNSIGNED` |  | 鉴权方式 |
| `secret_ref` | `VARCHAR(128)` |  | 密钥或证书在 Vault 中的引用路径 |
| `timeout_ms` | `INT UNSIGNED` |  | 默认超时时间 |
| `status` | `TINYINT UNSIGNED` | `IDX(status)` | 渠道状态 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

渠道配置表不直接存放明文密钥，只保存引用路径，便于和 `Vault` 对齐。  
The partner-configuration table does not store plaintext secrets. It stores only secret references so the design stays aligned with `Vault`.

#### 3.4.2 eb_channel_transfer_request

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `channel_request_no` | `VARCHAR(32)` | `UK` | 渠道请求业务号 |
| `transfer_no` | `VARCHAR(32)` | `IDX(transfer_no)` | 关联转账单号 |
| `partner_code` | `VARCHAR(32)` | `IDX(partner_code, request_status)` | 目标渠道编码 |
| `partner_order_no` | `VARCHAR(64)` | `UK(partner_code, partner_order_no)` | 渠道侧订单号，可为空 |
| `request_type` | `TINYINT UNSIGNED` |  | 请求类型 |
| `request_status` | `TINYINT UNSIGNED` | `IDX(request_status, updated_at)` | 请求状态 |
| `retry_count` | `INT UNSIGNED` |  | 请求重试次数 |
| `http_status` | `SMALLINT UNSIGNED` |  | 最近一次 HTTP 状态码 |
| `channel_status_code` | `VARCHAR(32)` |  | 渠道返回状态码 |
| `channel_status_message` | `VARCHAR(255)` |  | 渠道返回摘要 |
| `request_payload_json` | `JSON` |  | 请求报文快照 |
| `response_payload_json` | `JSON` |  | 响应报文快照 |
| `sent_at` | `DATETIME(3)` |  | 首次发送时间 |
| `last_callback_at` | `DATETIME(3)` |  | 最近一次回调时间 |
| `finished_at` | `DATETIME(3)` |  | 请求完成时间 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

这张表承担“内部转账单”和“外部渠道交互”之间的桥接角色，`transfer_no`、`partner_code` 和 `partner_order_no` 是最关键的三类定位键。  
This table bridges the internal transfer order with the external partner interaction. `transfer_no`, `partner_code`, and `partner_order_no` are the three most important lookup keys.

#### 3.4.3 eb_channel_callback_record

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `callback_no` | `VARCHAR(32)` | `UK` | 回调记录业务号 |
| `partner_code` | `VARCHAR(32)` | `UK(partner_code, callback_dedup_key)` / `IDX(partner_code, partner_order_no)` | 渠道编码 |
| `callback_dedup_key` | `VARCHAR(64)` | `UK(partner_code, callback_dedup_key)` | 回调去重键 |
| `partner_order_no` | `VARCHAR(64)` | `IDX(partner_code, partner_order_no)` | 渠道侧订单号 |
| `transfer_no` | `VARCHAR(32)` | `IDX(transfer_no, received_at)` | 关联转账单号 |
| `callback_type` | `TINYINT UNSIGNED` |  | 回调类型 |
| `callback_status` | `TINYINT UNSIGNED` | `IDX(callback_status, received_at)` | 回调处理状态 |
| `signature_status` | `TINYINT UNSIGNED` |  | 签名校验结果 |
| `raw_payload_json` | `JSON` |  | 回调原始报文 |
| `received_at` | `DATETIME(3)` |  | 接收时间 |
| `processed_at` | `DATETIME(3)` |  | 处理完成时间 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |

回调表是标准追加写加状态更新模型，唯一约束放在 `partner_code + callback_dedup_key` 上，保证重复回调不会被重复处理。  
The callback table follows a standard append-plus-status-update model. The unique constraint on `partner_code + callback_dedup_key` ensures duplicate callbacks are not processed twice.

### 3.5 eb-service-risk

风控服务当前只做轻量规则和决策留痕，因此数据设计保持“小而清晰”。  
The risk service currently covers only lightweight rules and decision records, so its data model should stay small and explicit.

#### 3.5.1 eb_risk_rule

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `rule_code` | `VARCHAR(32)` | `UK` | 规则编码 |
| `rule_name` | `VARCHAR(64)` |  | 规则名称 |
| `rule_scene` | `TINYINT UNSIGNED` | `IDX(rule_scene, status, priority)` | 规则场景，如登录、转账 |
| `rule_type` | `TINYINT UNSIGNED` |  | 规则类型 |
| `rule_config_json` | `JSON` |  | 规则参数配置 |
| `action_type` | `TINYINT UNSIGNED` |  | 命中后的动作，如放行、拒绝、人工复核 |
| `priority` | `SMALLINT UNSIGNED` | `IDX(rule_scene, status, priority)` | 规则优先级 |
| `status` | `TINYINT UNSIGNED` | `IDX(status)` | 规则状态 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

`eb_risk_rule` 的核心访问模式是按场景加载启用规则并按优先级排序，因此 `(rule_scene, status, priority)` 复合索引优先级最高。  
The main access path of `eb_risk_rule` is loading active rules by scene and ordering them by priority, so `(rule_scene, status, priority)` is the highest-priority composite index.

#### 3.5.2 eb_risk_decision

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `decision_no` | `VARCHAR(32)` | `UK` | 风控决策业务号 |
| `risk_scene` | `TINYINT UNSIGNED` | `IDX(risk_scene, decision_result, decided_at)` | 风控场景 |
| `biz_no` | `VARCHAR(32)` | `IDX(biz_no)` | 关联业务单号，如转账单号 |
| `request_id` | `VARCHAR(64)` | `IDX(request_id)` | 请求标识 |
| `user_no` | `VARCHAR(32)` | `IDX(user_no, decided_at)` | 用户业务号 |
| `account_no` | `VARCHAR(32)` | `IDX(account_no, decided_at)` | 账户业务号，可为空 |
| `decision_result` | `TINYINT UNSIGNED` | `IDX(risk_scene, decision_result, decided_at)` | 决策结果 |
| `risk_score` | `DECIMAL(8,2)` |  | 风险分值 |
| `reason_code` | `VARCHAR(32)` |  | 结果原因编码 |
| `reason_message` | `VARCHAR(255)` |  | 结果说明 |
| `hit_rule_snapshot_json` | `JSON` |  | 命中规则快照 |
| `trace_id` | `VARCHAR(64)` | `IDX(trace_id)` | 链路标识 |
| `decided_at` | `DATETIME(3)` |  | 决策时间 |

风险决策表要兼顾“按业务单回放决策”与“按用户追查近一段时间命中记录”两类场景，所以 `biz_no` 与 `user_no + decided_at` 都需要保留。  
The risk-decision table must support both “decision replay by business number” and “recent hits by user”, so both `biz_no` and `user_no + decided_at` should be preserved.

### 3.6 eb-service-notification

通知服务主要是异步任务模型，因此表设计重点是模板管理、待投递状态和重试扫描。  
The notification service is mainly an asynchronous task model, so its tables focus on template management, delivery state, and retry scans.

#### 3.6.1 eb_notification_template

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `template_code` | `VARCHAR(32)` | `UK` | 模板编码 |
| `template_name` | `VARCHAR(64)` |  | 模板名称 |
| `channel_type` | `TINYINT UNSIGNED` | `IDX(channel_type, status)` | 渠道类型，如站内信、短信、邮件 |
| `lang_code` | `VARCHAR(16)` |  | 语言标识 |
| `title_template` | `VARCHAR(255)` |  | 标题模板 |
| `body_template` | `TEXT` |  | 正文模板 |
| `status` | `TINYINT UNSIGNED` | `IDX(status)` | 模板状态 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

模板表写入压力很小，主要是按 `template_code` 和 `channel_type + status` 做查找，因此索引保持克制即可。  
The template table has very light write pressure. It is mainly queried by `template_code` and `channel_type + status`, so the indexes should stay minimal.

#### 3.6.2 eb_notification_message

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `message_no` | `VARCHAR(32)` | `UK` | 通知消息业务号 |
| `biz_no` | `VARCHAR(32)` | `IDX(biz_no)` | 关联业务单号 |
| `biz_type` | `TINYINT UNSIGNED` | `IDX(biz_type, created_at)` | 业务类型 |
| `template_code` | `VARCHAR(32)` | `IDX(template_code)` | 使用的模板编码 |
| `recipient_no` | `VARCHAR(64)` | `IDX(recipient_no, created_at)` | 接收对象标识 |
| `channel_type` | `TINYINT UNSIGNED` | `IDX(channel_type, send_status)` | 投递渠道 |
| `send_status` | `TINYINT UNSIGNED` | `IDX(send_status, next_retry_at)` | 发送状态 |
| `retry_count` | `INT UNSIGNED` |  | 当前重试次数 |
| `max_retry_count` | `INT UNSIGNED` |  | 最大重试次数 |
| `payload_json` | `JSON` |  | 模板渲染参数 |
| `fail_reason_code` | `VARCHAR(32)` |  | 失败编码 |
| `fail_reason_message` | `VARCHAR(255)` |  | 失败摘要 |
| `next_retry_at` | `DATETIME(3)` | `IDX(send_status, next_retry_at)` | 下一次重试时间 |
| `sent_at` | `DATETIME(3)` |  | 发送完成时间 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

通知消息表是标准异步任务表，最关键的扫描索引就是 `(send_status, next_retry_at)`，这样重试工作线程可以高效抓取待处理记录。  
The notification-message table is a standard asynchronous task table. Its most important scan index is `(send_status, next_retry_at)` so retry workers can efficiently fetch pending messages.

### 3.7 eb-service-audit

审计服务和普通应用日志不同，它更强调合规留痕和动作可追溯性，因此按对象和操作者的时间线查询最重要。  
The audit service differs from ordinary application logging. It emphasizes compliance traceability and action history, so timeline queries by target object and operator are the most important.

#### 3.7.1 eb_audit_log

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `audit_no` | `VARCHAR(32)` | `UK` | 审计记录业务号 |
| `operator_type` | `TINYINT UNSIGNED` |  | 操作者类型，如用户、系统、任务 |
| `operator_no` | `VARCHAR(32)` | `IDX(operator_no, occurred_at)` | 操作者业务号 |
| `action_code` | `VARCHAR(32)` | `IDX(action_code, occurred_at)` | 操作编码 |
| `target_type` | `VARCHAR(32)` | `IDX(target_type, target_no, occurred_at)` | 操作对象类型 |
| `target_no` | `VARCHAR(32)` | `IDX(target_type, target_no, occurred_at)` | 操作对象业务号 |
| `request_id` | `VARCHAR(64)` | `IDX(request_id)` | 请求标识 |
| `trace_id` | `VARCHAR(64)` | `IDX(trace_id)` | 链路标识 |
| `result_status` | `TINYINT UNSIGNED` | `IDX(result_status, occurred_at)` | 执行结果 |
| `client_ip` | `VARCHAR(45)` |  | 来源 IP |
| `detail_json` | `JSON` |  | 审计详情快照 |
| `occurred_at` | `DATETIME(3)` |  | 发生时间 |

审计表是典型写多读少、但按对象追踪时必须秒级可查的表，因此保留了对象维度、操作者维度和请求链路维度三组核心索引。  
The audit table is write-heavy and read-light, but object tracing must still remain fast. That is why it keeps three core index groups: by target object, by operator, and by request/trace identifiers.

### 3.8 eb-service-ops

运维服务主要承载重试、人工处理和对账任务，因此数据模型要服务于任务扫描、批处理和问题归档。  
The operations service mainly carries retries, manual handling, and reconciliation jobs, so its data model must serve task scanning, batch processing, and issue tracking.

#### 3.8.1 eb_retry_task

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `task_no` | `VARCHAR(32)` | `UK` | 重试任务业务号 |
| `task_type` | `TINYINT UNSIGNED` | `IDX(task_type, task_status)` | 任务类型 |
| `biz_no` | `VARCHAR(32)` | `IDX(biz_no)` | 关联业务单号 |
| `related_step_code` | `VARCHAR(32)` |  | 关联流程步骤编码 |
| `task_status` | `TINYINT UNSIGNED` | `IDX(task_status, next_retry_at)` | 任务状态 |
| `retry_count` | `INT UNSIGNED` |  | 当前重试次数 |
| `max_retry_count` | `INT UNSIGNED` |  | 最大重试次数 |
| `next_retry_at` | `DATETIME(3)` | `IDX(task_status, next_retry_at)` | 下一次调度时间 |
| `last_error_code` | `VARCHAR(32)` |  | 最近错误编码 |
| `last_error_message` | `VARCHAR(255)` |  | 最近错误摘要 |
| `locked_by` | `VARCHAR(64)` | `IDX(locked_by)` | 被哪个调度实例占用 |
| `locked_at` | `DATETIME(3)` |  | 占用时间 |
| `finished_at` | `DATETIME(3)` |  | 完成时间 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

`eb_retry_task` 的核心访问路径是“按状态抓取到期任务”，因此 `(task_status, next_retry_at)` 是整个运维任务子系统里最重要的扫描索引之一。  
The key access path of `eb_retry_task` is “fetch due tasks by status”, so `(task_status, next_retry_at)` is one of the most important scan indexes in the operations subsystem.

#### 3.8.2 eb_retry_report

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `report_no` | `VARCHAR(32)` | `UK` | 人工处理报告业务号 |
| `biz_no` | `VARCHAR(32)` | `IDX(biz_no)` | 关联业务单号 |
| `report_type` | `TINYINT UNSIGNED` | `IDX(report_type, report_status)` | 报告类型 |
| `report_status` | `TINYINT UNSIGNED` | `IDX(report_status, generated_at)` | 报告状态 |
| `summary_text` | `VARCHAR(500)` |  | 摘要说明 |
| `detail_json` | `JSON` |  | 详细分析内容 |
| `assignee` | `VARCHAR(32)` | `IDX(assignee, report_status)` | 指派处理人 |
| `generated_at` | `DATETIME(3)` |  | 生成时间 |
| `closed_at` | `DATETIME(3)` |  | 关闭时间 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

人工处理报告强调“状态流转”和“责任归属”，所以 `report_status` 与 `assignee` 两条索引都需要保留。  
Manual-handling reports emphasize both state transitions and responsibility ownership, so indexes on `report_status` and `assignee` should both be preserved.

#### 3.8.3 eb_reconciliation_job

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `job_no` | `VARCHAR(32)` | `UK` | 对账任务业务号 |
| `reconciliation_date` | `DATE` | `IDX(reconciliation_date, job_type, partner_code)` | 对账日期 |
| `job_type` | `TINYINT UNSIGNED` | `IDX(reconciliation_date, job_type, partner_code)` | 对账类型 |
| `partner_code` | `VARCHAR(32)` | `IDX(reconciliation_date, job_type, partner_code)` | 关联渠道编码，可为空 |
| `job_status` | `TINYINT UNSIGNED` | `IDX(job_status, started_at)` | 任务状态 |
| `total_count` | `INT UNSIGNED` |  | 总记录数 |
| `mismatch_count` | `INT UNSIGNED` |  | 差异记录数 |
| `started_at` | `DATETIME(3)` |  | 开始时间 |
| `finished_at` | `DATETIME(3)` |  | 完成时间 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

对账任务表更像批处理批次头，重点是“按日期 / 类型 / 渠道”定位批次，以及按状态查看正在执行或失败的对账任务。  
The reconciliation-job table acts like a batch header. Its priority is locating batches by date, type, and partner, and listing jobs by execution status.

#### 3.8.4 eb_reconciliation_result

| 字段<br>Field | 类型<br>Type | 约束 / 索引<br>Constraints / Indexes | 用途<br>Purpose |
| --- | --- | --- | --- |
| `id` | `BIGINT` | `PK` | 主键 |
| `result_no` | `VARCHAR(32)` | `UK` | 差异结果业务号 |
| `job_no` | `VARCHAR(32)` | `IDX(job_no, mismatch_type)` | 所属对账任务号 |
| `biz_no` | `VARCHAR(32)` | `IDX(biz_no)` | 关联业务单号 |
| `partner_code` | `VARCHAR(32)` | `IDX(partner_code, repair_status)` | 渠道编码 |
| `mismatch_type` | `TINYINT UNSIGNED` | `IDX(job_no, mismatch_type)` | 差异类型 |
| `internal_amount` | `DECIMAL(19,4)` |  | 内部金额 |
| `channel_amount` | `DECIMAL(19,4)` |  | 渠道金额 |
| `diff_amount` | `DECIMAL(19,4)` |  | 差额 |
| `repair_status` | `TINYINT UNSIGNED` | `IDX(repair_status, found_at)` | 修复状态 |
| `repair_task_no` | `VARCHAR(32)` | `IDX(repair_task_no)` | 对应修复任务号 |
| `detail_json` | `JSON` |  | 差异详情快照 |
| `found_at` | `DATETIME(3)` |  | 发现时间 |
| `repaired_at` | `DATETIME(3)` |  | 修复完成时间 |
| `created_at` | `DATETIME(3)` |  | 创建时间 |
| `updated_at` | `DATETIME(3)` |  | 更新时间 |

对账结果表的典型查询是“按批次看差异明细”和“按修复状态抓待处理结果”，因此 `job_no + mismatch_type` 与 `repair_status + found_at` 两组索引优先级最高。  
Typical queries on the reconciliation-result table are “mismatch details by batch” and “pending repair results by status”, so `job_no + mismatch_type` and `repair_status + found_at` are its highest-priority indexes.

## 4. 跨服务对象关系
*Cross-Service Object Relationships*

用户与账户之间是“用户拥有多个账户”的业务关系，但数据库层面不建立外键，账户服务仅在 `eb_account.user_no` 中冗余保存用户业务号。  
Between users and accounts, the business relationship is “one user owns multiple accounts,” but no foreign key is created at the database level. The account service keeps only the user business number in `eb_account.user_no`.

转账订单通过 `source_account_no`、`target_account_no` 与账户域关联，通过 `request_id` 与幂等表关联，通过 `transfer_no` 与步骤表、渠道请求表、通知消息表、审计记录和运维任务表关联。  
Transfer orders relate to the account domain through `source_account_no` and `target_account_no`, to the idempotency table through `request_id`, and to step records, channel requests, notifications, audit records, and operations tasks through `transfer_no`.

渠道请求与回调记录之间，优先通过 `partner_code + partner_order_no` 或 `callback_dedup_key` 建立应用层关联，而不是依赖数据库级联关系。  
Between channel requests and callback records, the preferred application-level association uses `partner_code + partner_order_no` or `callback_dedup_key` rather than database-level cascading relations.

风控、通知、审计和运维服务都以业务单号、请求标识和链路标识进行松耦合关联，不要求服务间共享数据库事务或共享表。  
Risk, notification, audit, and operations services remain loosely coupled through business numbers, request identifiers, and trace identifiers, without requiring shared database transactions or shared tables.

## 5. 当前阶段的数据库设计结论
*Current Database Design Conclusion*

当前阶段可以按“一个服务一组核心表”的方式推进，不需要一开始就把所有辅助表做全。重点是先把主对象、状态对象、日志对象和任务对象设计清楚。  
At the current stage, it is enough to move forward with “one service, one minimal set of core tables.” There is no need to build every supporting table upfront. The main priority is to clearly define the primary domain objects, stateful workflow objects, log objects, and task objects.

所有主表、流水表、任务表和日志表的主键策略统一采用雪花风格 64 位 ID。外部业务单号、请求号、渠道流水号都应与主键分开设计，不直接替代内部主键。  
The primary-key strategy for all main tables, history tables, task tables, and log tables should consistently use Snowflake-style 64-bit IDs. External business numbers, request IDs, and channel transaction numbers should be designed separately rather than replacing internal primary keys.

所有关联关系当前统一不使用数据库外键。表设计只保留必要的 `*_id`、`*_no`、`*_code` 字段和唯一 / 普通索引，真正的一致性校验由 Java 代码、业务状态机和应用层事务边界负责。  
All relationships consistently avoid database foreign keys in the current phase. Table design keeps only necessary `*_id`, `*_no`, and `*_code` fields together with unique or ordinary indexes, while actual consistency checks are enforced by Java code, business state machines, and application-layer transaction boundaries.

每个拥有数据库的微服务，应在自身项目目录下维护 `db_scripts/` 目录。建库脚本、初始化脚本和后续按 `Flyway` 管理的版本化迁移脚本，都应放在对应服务的 `db_scripts/` 下，而不是集中堆在仓库根目录。  
Each service that owns a database should maintain a `db_scripts/` directory inside its own project. Database creation scripts, initialization scripts, and later versioned migration scripts managed by `Flyway` should all be stored under that service’s `db_scripts/` directory rather than collected at the repository root.

在真正开始写 DDL 和实体类之前，如果某个表的状态机、业务唯一键或查询路径仍不清楚，应先继续补这份文档，而不是带着模糊结构直接进入实现。  
Before writing actual DDL and entity classes, if the state machine, business unique key, or query path of any table is still unclear, this document should be refined first rather than moving into implementation with an ambiguous structure.

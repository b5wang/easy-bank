# 数据结构设计概览
*Data Model Overview*

## 1. 文档目标
*Document Goal*

根据当前协作约定，在进入编码之前必须先明确业务数据对象及其关系。这份文档用于给出本项目第一版数据库结构设计概览，明确每个微服务拥有哪些核心表，以及不同业务对象之间如何关联。  
According to the current collaboration rules, the business data objects and their relationships must be defined before coding begins. This document provides the first-pass database design overview for the project and clarifies which core tables belong to each microservice and how the business objects relate to one another.

这里的设计目标不是追求生产级细节完整度，而是以最小结构表达清楚数据归属、主流程状态和后续系统设计演示所需的关系。  
The goal here is not to capture every production-grade detail. It is to use the smallest useful structure to clearly express data ownership, main-flow state, and the relationships needed for later systems-design demonstrations.

## 2. 数据归属原则
*Data Ownership Principles*

每个微服务有独立数据库，或者至少在逻辑设计上有独立 schema。跨服务引用应尽量通过业务主键或唯一编码完成，而不是直接依赖其他服务数据库的外键。  
Each microservice should have its own database, or at least its own logical schema. Cross-service references should be modeled through business keys or unique identifiers instead of direct foreign-key dependencies on another service’s database.

账户余额只属于账户服务，转账订单只属于转账服务，渠道交互记录只属于渠道服务，风险决策只属于风控服务。这个边界应在数据库设计层面就保持清楚。  
Account balances belong only to the account service, transfer orders belong only to the transfer service, channel interaction records belong only to the channel service, and risk decisions belong only to the risk service. These boundaries should already be clear at the database-design level.

数据库表主键统一使用雪花 ID。实现上建议由应用侧统一生成 64 位整数主键，数据库字段类型优先使用 `BIGINT`，避免在各服务内部混用自增主键和 UUID。  
All database tables should use Snowflake IDs as their primary-key strategy. In practice, the application layer should generate unified 64-bit integer IDs, and database columns should use `BIGINT` wherever possible, avoiding a mix of auto-increment keys and UUIDs across services.

## 3. 各服务核心数据对象
*Core Data Objects by Service*

### 3.1 eb-service-auth

建议的核心表：  
Recommended core tables:

- `eb_user`
- `eb_role`
- `eb_user_role`
- `eb_login_attempt`
- `eb_user_session`

其中 `eb_user` 是用户主对象，`eb_role` 和 `eb_user_role` 用于角色权限关联，`eb_login_attempt` 用于记录登录失败与风控相关上下文，`eb_user_session` 或令牌表用于演示登录态管理。  
Here, `eb_user` is the primary user object, `eb_role` and `eb_user_role` model role assignment, `eb_login_attempt` captures failed-login and risk-related context, and `eb_user_session` or a token table is used to demonstrate login-state management.

### 3.2 eb-service-account

建议的核心表：  
Recommended core tables:

- `eb_account`
- `eb_account_balance_change`

`eb_account` 记录账户主信息，包括账户号、状态、币种、当前余额和版本号。`eb_account_balance_change` 记录每次余额变动的流水，用于审计、查询和对账支撑。  
`eb_account` stores the primary account data, including account number, status, currency, current balance, and version number. `eb_account_balance_change` records each balance change for auditability, query support, and reconciliation.

### 3.3 eb-service-transfer

建议的核心表：  
Recommended core tables:

- `eb_transfer_order`
- `eb_transfer_step`
- `eb_transfer_idempotency`

`eb_transfer_order` 是转账主订单，记录转账类型、来源账户、目标账户、金额、状态和请求标识。`eb_transfer_step` 用于表达复杂流程中的阶段状态，便于后续展示 Saga 或补偿过程。`eb_transfer_idempotency` 用于持久化幂等键与处理结果。  
`eb_transfer_order` is the primary transfer-order table and stores the transfer type, source account, target account, amount, status, and request identifier. `eb_transfer_step` captures stage-level state in more complex workflows, which is useful later when demonstrating Saga or compensation. `eb_transfer_idempotency` persists idempotency keys and processing results.

### 3.4 eb-service-channel

建议的核心表：  
Recommended core tables:

- `eb_channel_partner`
- `eb_channel_transfer_request`
- `eb_channel_callback_record`

`eb_channel_partner` 记录外部渠道或合作平台配置。`eb_channel_transfer_request` 记录对外发起的请求和渠道状态映射。`eb_channel_callback_record` 记录回调内容、回调时间、去重标识和处理结果。  
`eb_channel_partner` stores external-channel or partner-platform configuration. `eb_channel_transfer_request` records outbound requests and the mapping between internal and channel-side states. `eb_channel_callback_record` captures callback payloads, callback timestamps, deduplication identifiers, and processing results.

### 3.5 eb-service-risk

建议的核心表：  
Recommended core tables:

- `eb_risk_rule`
- `eb_risk_decision`

`eb_risk_rule` 用于存放最小化风控规则配置。`eb_risk_decision` 记录每次登录或转账的风险判断结果，便于后续接入 AI 风控解释。  
`eb_risk_rule` stores the minimal rule configuration. `eb_risk_decision` records the outcome of each login or transfer risk evaluation, which later provides a foundation for AI-assisted explanation.

### 3.6 eb-service-notification

建议的核心表：  
Recommended core tables:

- `eb_notification_template`
- `eb_notification_message`

`eb_notification_template` 管理模板定义，`eb_notification_message` 管理实际通知任务、目标用户、渠道类型、投递状态和失败原因。  
`eb_notification_template` manages templates, and `eb_notification_message` stores actual notification tasks, target users, channel types, delivery state, and failure reasons.

### 3.7 eb-service-audit

建议的核心表：  
Recommended core tables:

- `eb_audit_log`

审计服务的核心数据对象可以先保持极简，用一张 `eb_audit_log` 表即可覆盖操作者、对象标识、操作类型、结果、时间和请求标识等字段。  
The audit service can stay minimal at first. A single `eb_audit_log` table is enough to capture the operator, target identifier, action type, result, timestamp, and request identifier.

### 3.8 eb-service-ops

建议的核心表：  
Recommended core tables:

- `eb_retry_task`
- `eb_retry_report`
- `eb_reconciliation_job`
- `eb_reconciliation_result`

`eb_retry_task` 记录待重试对象和当前重试状态，`eb_retry_report` 记录交付给业务人员的人工处理报告，`eb_reconciliation_job` 记录对账任务批次，`eb_reconciliation_result` 记录差异结果和修复状态。  
`eb_retry_task` stores objects waiting to be retried and their current retry state, `eb_retry_report` stores reports delivered for manual handling, `eb_reconciliation_job` tracks reconciliation batches, and `eb_reconciliation_result` stores discrepancies and repair status.

## 4. 跨服务对象关系
*Cross-Service Object Relationships*

用户与账户之间是“用户拥有多个账户”的业务关系，但在数据库层面建议通过用户标识在 `eb_account` 中冗余保存，而不是跨库建立真实外键。  
Between users and accounts, the business relationship is “one user owns multiple accounts,” but at the database level this should be represented by storing the user identifier redundantly in `eb_account` rather than using a real cross-database foreign key.

转账订单与账户之间通过来源账户号和目标账户号关联，转账服务不直接控制账户表。  
Transfer orders relate to accounts through source and target account numbers, but the transfer service does not directly control the account table.

转账订单与渠道请求之间通过内部转账单号关联，渠道服务保存外部请求细节。  
Transfer orders relate to channel requests through the internal transfer-order identifier, while the channel service stores the details of outbound and inbound external interactions.

转账订单与风险决策之间通过请求标识或业务流水号关联。  
Transfer orders relate to risk decisions through the request identifier or another business transaction key.

转账订单与通知消息、审计日志、重试任务和对账结果之间，通常通过业务单号或请求标识进行松耦合关联。  
Transfer orders usually relate to notification messages, audit logs, retry tasks, and reconciliation results through a loosely coupled business order number or request identifier.

## 5. 当前阶段的数据库设计结论
*Current Database Design Conclusion*

当前阶段可以先按“一个服务一组核心表”的方式推进，不需要一开始就把所有辅助表做全。重点是先把主对象、状态对象和关键日志对象设计清楚。  
At the current stage, it is enough to move forward with “one service, one minimal set of core tables.” There is no need to build every supporting table upfront. The main priority is to clearly define the primary domain objects, stateful workflow objects, and key log objects.

所有主表、流水表、任务表和日志表的主键策略统一采用雪花 ID。后续如果有外部业务单号、请求号或渠道流水号，也应和主键分开设计，不要直接拿外部编号替代内部主键。  
The primary-key strategy for all main tables, history tables, task tables, and log tables should consistently use Snowflake IDs. If there are external business order numbers, request IDs, or channel-side transaction IDs later on, they should be designed separately from the primary key rather than replacing the internal ID.

每个拥有数据库的微服务，应在自身项目目录下维护 `db_scripts/` 目录。建库脚本、初始化脚本和后续更新脚本都应放在对应服务的 `db_scripts/` 下，而不是集中堆在仓库根目录。  
Each service that owns a database should maintain a `db_scripts/` directory inside its own project. Database creation scripts, initialization scripts, and later update scripts should all be stored under that service’s `db_scripts/` directory rather than collected in a single root-level location.

在进入具体编码前，如果某个服务的数据库结构仍不够清楚，应优先继续补这份文档或新增更细化的数据结构文档，而不是跳过数据设计直接实现接口。  
Before implementation begins, if the database structure of any service is still unclear, the priority should be to keep refining this document or add a more detailed data-structure document rather than skipping the data-design step and going straight to API implementation.

# 微服务拆分文档 / Microservice Boundary Design

## 1. 文档目标 / Document Goal

这份文档用于根据当前已经确认的功能范围，对整个 `easy-bank` 项目进行微服务拆分，明确每个服务的职责边界、数据归属、主要调用关系，以及哪些能力应作为基础设施处理而不是强行实现为业务微服务。  
This document defines the microservice split for the `easy-bank` project based on the currently confirmed functional scope. It clarifies the responsibility boundaries, data ownership, and key interaction patterns of each service, and it also distinguishes between capabilities that should be handled as infrastructure and those that should be implemented as business microservices.

本项目统一使用 `eb` 作为 `easy-bank` 的简称，因此下面所有模块和服务都采用 `eb` 前缀命名。  
This project uses `eb` as the standard abbreviation for `easy-bank`, so all modules and services below use the `eb` prefix.

## 2. 拆分原则 / Splitting Principles

第一，账户余额这类核心金融数据必须有明确的唯一写入方，避免多个服务同时改余额。  
First, core financial data such as account balances must have a single authoritative writer so that multiple services do not update balances concurrently.

第二，流程编排和资金记账分离。发起转账的服务不应直接持有余额，而应通过明确边界调用账户域。  
Second, workflow orchestration and ledger ownership should be separated. The service that initiates a transfer should not directly own balances, and should instead call the account domain through an explicit boundary.

第三，与外部平台的交互应从转账编排中拆开，以便单独演示适配器模式、回调幂等、渠道状态管理和故障隔离。  
Third, interactions with external platforms should be separated from transfer orchestration so that the project can independently demonstrate the adapter pattern, callback idempotency, channel state handling, and fault isolation.

第四，审计、风控、通知、运维任务这些能力虽然与业务紧密相关，但从系统设计角度看，更适合独立服务化，以展示横切能力的独立演进。  
Fourth, capabilities such as auditing, risk control, notifications, and operational tasks are closely related to the business, but from a systems-design perspective they are better modeled as independent services to demonstrate how cross-cutting capabilities evolve separately.

## 3. 拆分结果 / Service Split Result

建议的项目拆分如下：  
The recommended project split is as follows:

- `eb-common`
- `eb-gateway`
- `eb-service-auth`
- `eb-service-account`
- `eb-service-transfer`
- `eb-service-channel`
- `eb-service-risk`
- `eb-service-notification`
- `eb-service-audit`
- `eb-service-ops`

其中 `eb-common` 是 Java 公共依赖模块，不是独立微服务；`eb-gateway` 是统一入口服务；其余模块为独立业务微服务。  
Among them, `eb-common` is a shared Java dependency module rather than an independent microservice; `eb-gateway` is the unified entry service; and the remaining modules are independent business microservices.

## 4. 各服务职责说明 / Service Responsibilities

### 4.1 eb-common

`eb-common` 用于承载多个微服务之间共享的公共代码，例如统一响应对象、通用异常模型、请求链路标识常量、公共枚举和基础工具类。  
`eb-common` is used to hold code shared across multiple microservices, such as a unified response model, common exception types, request-correlation constants, shared enums, and basic utility classes.

这个模块不应该承载具体业务逻辑，也不应该演变成“大杂烩”。凡是带有明确领域含义的对象，都应该留在各自服务内部。  
This module should not contain domain-specific business logic, and it should not turn into a dumping ground. Anything with clear domain meaning should stay inside its own service.

### 4.2 eb-gateway

`eb-gateway` 是统一 API 网关，负责外部请求接入、基础路由、统一鉴权入口接入、限流挂载点、链路标识透传，以及后续灰度和统一观测的入口控制。  
`eb-gateway` is the unified API gateway. It handles external request entry, basic routing, unified authentication entry points, rate-limiting hook points, trace propagation, and later control points for gray releases and observability.

它不拥有业务数据，不负责具体业务决策，也不直接持久化账户、转账等业务对象。  
It does not own business data, does not make domain decisions, and does not directly persist business objects such as accounts or transfers.

### 4.3 eb-service-auth

`eb-service-auth` 负责用户登录验证和身份相关能力，包括用户登录、令牌签发、退出登录、角色权限基础模型、登录失败控制，以及对外提供统一身份校验能力。  
`eb-service-auth` is responsible for user login and identity-related capabilities, including login, token issuance, logout, the basic role-permission model, login-failure control, and a unified identity-validation capability for other services.

该服务拥有用户身份数据，但不拥有账户余额、转账订单等业务数据。  
This service owns identity-related user data, but it does not own business data such as account balances or transfer orders.

### 4.4 eb-service-account

`eb-service-account` 是账户域服务，负责账户开户、账户查询、账户状态管理、存款、取款，以及账户余额变动流水。  
`eb-service-account` is the account-domain service. It handles account creation, account lookup, account status management, deposits, withdrawals, and balance-change history.

它是账户余额的唯一权威写服务。无论是站内转账还是外部平台转账，只要涉及账户余额最终变动，都应通过它完成。  
It is the single authoritative write service for account balances. Whether the flow is an internal transfer or an external-platform transfer, any final balance movement should go through this service.

### 4.5 eb-service-transfer

`eb-service-transfer` 是转账编排服务，负责统一管理转账申请、转账状态查询、内部转账流程编排、外部转账流程编排入口，以及转账订单生命周期。  
`eb-service-transfer` is the transfer-orchestration service. It manages transfer requests, transfer-status lookup, internal-transfer orchestration, the entry point for external-transfer orchestration, and the lifecycle of transfer orders.

它拥有转账订单，但不直接拥有账户余额，也不直接处理外部平台适配细节。  
It owns transfer orders, but it does not directly own account balances, and it does not directly handle external-platform integration details.

### 4.6 eb-service-channel

`eb-service-channel` 负责与外部银行、购物平台、商户平台、清算平台等外部系统交互。它管理渠道配置、外发请求、回调接收、回调幂等、渠道状态映射，以及平台适配器实现。  
`eb-service-channel` is responsible for interacting with external banks, e-commerce platforms, merchant platforms, clearing platforms, and other third-party systems. It manages channel configuration, outbound requests, callback reception, callback idempotency, channel-status mapping, and platform-adapter implementations.

这个服务的存在是为了把“转账业务”与“外部世界对接”解耦开。这样可以更清楚地展示渠道故障隔离、适配器模式和跨系统一致性问题。  
This service exists to decouple transfer business from integration with the outside world. That makes it much easier to demonstrate channel fault isolation, the adapter pattern, and cross-system consistency challenges.

### 4.7 eb-service-risk

`eb-service-risk` 负责轻量风控决策，包括登录风控、转账额度校验、频率限制、黑名单检查，以及输出风险决策结果。  
`eb-service-risk` is responsible for lightweight risk decisions, including login risk checks, transfer-limit validation, frequency control, blacklist checks, and risk-decision output.

它不应该直接执行转账，而应该作为“先决策、后处理”的独立判断服务存在。  
It should not execute transfers directly. Instead, it should exist as an independent decision service that enforces the pattern of deciding first and processing second.

### 4.8 eb-service-notification

`eb-service-notification` 负责站内通知以及后续可扩展的短信、邮件和消息推送。它管理通知模板、通知任务、投递状态，以及失败后的补偿。  
`eb-service-notification` is responsible for in-app notifications and future extensions such as SMS, email, and push messaging. It manages notification templates, notification tasks, delivery status, and compensation after delivery failure.

它通过异步方式接收业务事件，而不侵入主业务流程。  
It should consume business events asynchronously rather than intruding on the main business flow.

### 4.9 eb-service-audit

`eb-service-audit` 负责统一审计日志记录，包括操作者、操作对象、操作类型、结果、请求标识和时间等留痕数据。  
`eb-service-audit` is responsible for centralized audit logging, including the operator, target object, action type, result, request identifier, timestamp, and other traceability data.

它与普通应用日志不同，重点是合规留痕和敏感行为追踪，而不是故障排查。  
It is different from ordinary application logging. Its focus is compliance-oriented traceability and sensitive-action tracking rather than debugging.

### 4.10 eb-service-ops

`eb-service-ops` 负责运维和批处理相关能力，包括失败转账重试任务、人工处理报告生成、对账任务、差异修复任务，以及后续与运营后台相关的任务型流程。  
`eb-service-ops` is responsible for operations-oriented and batch-processing capabilities, including failed-transfer retry jobs, manual-handling report generation, reconciliation jobs, discrepancy-repair jobs, and later task-driven workflows related to operations tooling.

之所以单独拆出这个服务，是为了把在线交易流和异步治理任务隔离开，便于演示定时任务、补偿流程和运维治理。  
This service is separated so that online transaction flows are isolated from asynchronous governance tasks, making it easier to demonstrate scheduled jobs, compensation workflows, and operational governance.

## 5. 主要调用关系 / Main Interaction Patterns

典型调用链建议如下：  
The recommended interaction patterns are as follows:

- 用户请求先进入 `eb-gateway`
- 网关将身份相关请求路由到 `eb-service-auth`
- 网关将账户请求路由到 `eb-service-account`
- 网关将转账请求路由到 `eb-service-transfer`
- `eb-service-transfer` 在执行前调用 `eb-service-risk`
- 站内转账由 `eb-service-transfer` 调用 `eb-service-account`
- 外部平台转账由 `eb-service-transfer` 调用 `eb-service-channel`
- `eb-service-channel` 收到外部回调后回写 `eb-service-transfer`
- 关键操作异步投递给 `eb-service-audit`
- 业务结果事件异步投递给 `eb-service-notification`
- 失败重试、对账和报告任务由 `eb-service-ops` 发起

- User requests enter through `eb-gateway`
- The gateway routes identity-related requests to `eb-service-auth`
- The gateway routes account-related requests to `eb-service-account`
- The gateway routes transfer-related requests to `eb-service-transfer`
- `eb-service-transfer` calls `eb-service-risk` before execution
- Internal transfers are completed by `eb-service-transfer` calling `eb-service-account`
- External-platform transfers are completed by `eb-service-transfer` calling `eb-service-channel`
- `eb-service-channel` writes callback results back to `eb-service-transfer`
- Key actions are published asynchronously to `eb-service-audit`
- Business-result events are published asynchronously to `eb-service-notification`
- Retry jobs, reconciliation, and operational reports are initiated by `eb-service-ops`

## 6. 不作为业务微服务实现的能力 / Capabilities Not Implemented as Business Microservices

系统日志中心化处理虽然在功能范围内，但不建议在本项目中把它实现成一个 Spring Boot 业务微服务。更合理的做法是把它视为基础设施能力，由 ELK、EFK 或 OpenSearch 这类日志平台承载。  
Although centralized logging is part of the project scope, it should not be implemented as a Spring Boot business microservice in this project. A more appropriate approach is to treat it as an infrastructure capability backed by a logging platform such as ELK, EFK, or OpenSearch.

同样，Redis、Kafka、RocketMQ、MySQL 也属于基础设施依赖，而不是业务微服务。项目中的 Java 服务应基于这些能力进行协作，而不是试图把它们包装成新的业务项目。  
Similarly, Redis, Kafka, RocketMQ, and MySQL are infrastructure dependencies rather than business microservices. The Java services in the project should collaborate through these capabilities instead of wrapping them as new business projects.

## 7. 数据库脚本目录约定 / Database Script Directory Convention

每个拥有独立数据库的微服务，都必须在自身 Java 项目目录下维护 `db_scripts/` 目录，用于存放数据库建库脚本和后续变更脚本。这样做的目的是让数据库结构演进和服务代码保持同目录归属，便于版本管理和服务级交付。  
Each microservice that owns an independent database must maintain a `db_scripts/` directory inside its own Java project. This directory is used for database creation scripts and later schema-change scripts. The purpose is to keep database evolution and service code under the same ownership boundary, making version control and service-level delivery easier.

当前项目中，这一规则适用于：`eb-service-auth`、`eb-service-account`、`eb-service-transfer`、`eb-service-channel`、`eb-service-risk`、`eb-service-notification`、`eb-service-audit`、`eb-service-ops`。  
In the current project, this rule applies to `eb-service-auth`, `eb-service-account`, `eb-service-transfer`, `eb-service-channel`, `eb-service-risk`, `eb-service-notification`, `eb-service-audit`, and `eb-service-ops`.

`eb-gateway` 和 `eb-common` 不拥有独立业务数据库，因此不需要维护 `db_scripts/` 目录。  
`eb-gateway` and `eb-common` do not own independent business databases, so they do not need a `db_scripts/` directory.

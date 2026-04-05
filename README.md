# Easy Bank

一个以金融、银行场景为背景的 Java 微服务示例项目。目标不是完整还原真实银行系统，而是用尽量少的业务逻辑和尽量简化的表结构，演示主流系统设计思路在 Spring Boot + Spring Cloud 体系里的落地方式。  
Easy Bank is a Java microservice sample project built around financial and banking scenarios. Its goal is not to fully reproduce a real banking system, but to demonstrate mainstream system design ideas in the Spring Boot + Spring Cloud ecosystem with minimal business logic and simplified schemas.

## 当前范围
*Current Scope*

- 目前 AI 以大语言模型实现，任何理解都基于语言描述，任何项目变化都需要文档化是第一要务。  
  The current AI collaboration model is based on large language models, so every project change must be documented first because all understanding depends on language descriptions.
- AI 无状态，不同机器协同工作依赖这些文档。  
  AI is stateless, and collaboration across different machines depends on these documents.
- 任何文档都要求中英双语，中文在上，英文在下。  
  Every project document must be bilingual, with Chinese above English.
- 只实现最基础的接口能力。  
  Only the most basic interface capabilities are in scope.
- 对外接口和面向 UI 的接口统一使用标准 REST API。  
  External-facing APIs and UI-facing APIs should consistently use standard REST APIs.
- 当前阶段不做前端 UI。  
  No frontend UI is included at the current stage.
- 以微服务方式拆分功能域。  
  Functional domains are split as microservices.
- 优先体现主流设计思想，而不是业务复杂度。  
  The priority is to demonstrate mainstream design ideas rather than business complexity.
- 数据模型保持精简，够表达设计意图即可。  
  The data model stays minimal as long as it clearly expresses the design intent.

## 命名约定
*Naming Convention*

项目中统一使用 `eb` 作为 `easy-bank` 的简称。后续在模块名、服务名、数据库对象名、代码包名辅助标识、配置前缀等需要缩写命名的地方，可以优先使用 `eb`，避免在 `easy-bank`、`easybank`、`eb` 之间混用。  
The project uses `eb` as the standard abbreviation for `easy-bank`. Going forward, whenever abbreviated naming is needed for module names, service names, database objects, package-related identifiers, or configuration prefixes, `eb` should be preferred to avoid mixing `easy-bank`, `easybank`, and `eb`.

推荐的命名示例包括：模块名使用 `eb-service-account`，数据库表名前缀使用 `eb_`，数据库字段或业务流水标识中需要项目级前缀时也可使用 `eb`。  
Recommended naming examples include module names such as `eb-service-account`, database table prefixes such as `eb_`, and using `eb` as the project-level prefix in database fields or business identifiers when a short prefix is needed.

## 技术基线
*Technology Baseline*

### 当前应用框架
*Current Application Framework*

- Java 25
- Maven 3.9.x
- Spring Boot 4.0.2
- Spring Cloud 2025.1.1
- Spring Cloud Gateway
- Spring Cloud OpenFeign
- Spring Cloud CircuitBreaker
- Spring Security
- Spring Data JPA
- Quartz Scheduler
- Spring Boot Actuator

### 当前数据与存储规划
*Current Data and Storage Plan*

- MySQL 8.4.x（LTS，当前基线 8.4.8）
- 微服务独立数据库或独立 schema。  
  Each microservice uses its own database or at least its own schema.
- 数据库对象统一使用 `eb_` 前缀。  
  Database objects consistently use the `eb_` prefix.
- 数据库表主键统一使用雪花 ID，字段类型优先使用 `BIGINT`。  
  Database table primary keys consistently use Snowflake IDs, and `BIGINT` is preferred for column types.
- 每个拥有独立数据库的微服务，都在自身项目目录下维护 `db_scripts/` 目录，用于存放建库和更新脚本。  
  Each microservice that owns an independent database maintains a `db_scripts/` directory inside its project for schema creation and update scripts.
- 数据库结构变更默认采用 Flyway 管理，迁移脚本统一沉淀在各服务自己的 `db_scripts/` 目录。  
  Database schema changes should be managed by Flyway by default, with migration scripts kept in each service’s own `db_scripts/` directory.

### 当前异步与分布式基础设施规划
*Current Asynchronous and Distributed Infrastructure Plan*

- Redis
- Kafka

### 当前日志与可观测性规划
*Current Logging and Observability Plan*

- OpenSearch + OpenSearch Dashboards + Fluent Bit 体系，用于日志中心化处理。  
  An OpenSearch + OpenSearch Dashboards + Fluent Bit stack is planned for centralized logging.
- Micrometer + Prometheus，用于统一基础指标采集与暴露。  
  Micrometer + Prometheus are planned for baseline metrics collection and exposure.
- OpenTelemetry + OTLP + Jaeger，用于链路追踪。  
  OpenTelemetry + OTLP + Jaeger are planned for distributed tracing.
- 统一链路标识与请求标识透传。  
  Trace IDs and request IDs should be propagated consistently.

### 当前配置中心与服务治理规划
*Current Configuration and Service Governance Plan*

- Nacos，统一承载配置中心与服务注册发现。  
  Nacos is planned as the unified platform for both configuration management and service discovery.
- 网关入口限流采用 Spring Cloud Gateway RequestRateLimiter + Redis。  
  Gateway entry rate limiting uses Spring Cloud Gateway RequestRateLimiter + Redis.
- 内部同步调用故障隔离采用 Spring Cloud CircuitBreaker + Resilience4j。  
  Internal synchronous-call fault isolation uses Spring Cloud CircuitBreaker + Resilience4j.

### 当前调度、密钥与事务路线规划
*Current Scheduling, Secret, and Transaction Plan*

- 运维型重试、补偿与对账任务优先由 `eb-service-ops` 基于 Quartz 承载。  
  Operations-style retry, compensation, and reconciliation jobs are primarily carried by `eb-service-ops` with Quartz.
- 高敏感凭据统一采用 Vault 管理，普通配置继续由 Nacos 管理。  
  Highly sensitive secrets are managed through Vault, while ordinary configuration continues to be managed in Nacos.
- 跨服务一致性当前正式路线采用 Saga + 本地事务 + Kafka 事件 + 幂等与补偿。  
  The formal current route for cross-service consistency is Saga + local transactions + Kafka events + idempotency and compensation.

### 说明
*Notes*

- 当前仓库已经建立 Maven 多模块和各微服务 Spring Boot 项目骨架。  
  The repository already contains the Maven multi-module structure and Spring Boot skeletons for each microservice.
- Redis、Kafka、OpenSearch 日志平台、Nacos、Prometheus、Jaeger、Vault 等基础设施当前已完成选型，但仍将按阶段逐步接入。  
  Redis, Kafka, the OpenSearch logging stack, Nacos, Prometheus, Jaeger, Vault, and related infrastructure have now been selected, but they will still be introduced incrementally by phase.

## 当前文档
*Current Documents*

- [docs/00-codex-collaboration.md](docs/00-codex-collaboration.md)
- [docs/01-functional-scope.md](docs/01-functional-scope.md)
- [docs/02-microservice-boundaries.md](docs/02-microservice-boundaries.md)
- [docs/03-data-model-overview.md](docs/03-data-model-overview.md)
- [docs/04-technology-selection.md](docs/04-technology-selection.md)
- [docs/05-mysql-environment-setup.md](docs/05-mysql-environment-setup.md)

## 当前项目结构
*Current Project Structure*

- `eb-common`  
  Java 公共依赖模块，承载统一响应对象、链路标识常量等公共组件。  
  Shared Java dependency module that carries common components such as unified response objects and trace-identifier constants.
- `eb-gateway`  
  API 网关，负责统一入口和基础路由。  
  API gateway responsible for the unified entry point and basic routing.
- `eb-service-auth`  
  登录验证、令牌签发、角色权限基础能力。  
  Login verification, token issuance, and basic role-permission capabilities.
- `eb-service-account`  
  账户主数据、账户状态、余额写入和余额流水。  
  Account master data, account state, balance writes, and balance-change history.
- `eb-service-transfer`  
  转账订单和转账流程编排。  
  Transfer orders and transfer workflow orchestration.
- `eb-service-channel`  
  外部银行、商户平台、购物平台等渠道接入与回调处理。  
  Integration with external banks, merchant platforms, shopping platforms, and callback handling.
- `eb-service-risk`  
  轻量风控规则与风险决策。  
  Lightweight risk-control rules and risk decisions.
- `eb-service-notification`  
  站内通知和后续可扩展的短信、邮件、推送。  
  In-app notifications and future extensions for SMS, email, and push messaging.
- `eb-service-audit`  
  审计日志留痕。  
  Audit logging and trace retention.
- `eb-service-ops`  
  重试任务、人工处理报告、对账任务等运维型流程。  
  Operations-oriented workflows such as retry tasks, manual-handling reports, and reconciliation jobs.

除了 `eb-gateway` 和 `eb-common`，其余拥有独立数据库的微服务都已经预留 `db_scripts/` 目录，用于放置数据库建库脚本和后续更新脚本。  
Except for `eb-gateway` and `eb-common`, each microservice that owns an independent database now has a reserved `db_scripts/` directory for database creation scripts and future update scripts.

## 当前阶段结论
*Current Stage Conclusion*

当前仓库已经完成微服务拆分文档、数据结构设计概览，以及对应的 Maven 多模块 Java 项目骨架。  
The repository now includes the microservice boundary documentation, the data-model overview, and the corresponding Maven multi-module Java project skeleton.

后续继续开发时，默认按照“先明确需求，遇到不清楚的地方先提问；需求明确后先设计数据库结构和业务数据对象关系；之后再编码”的顺序推进。  
When development continues later, the default workflow is: clarify the requirements first and ask questions whenever something is unclear; once the requirements are clear, design the database structure and business data relationships; only then move on to implementation.

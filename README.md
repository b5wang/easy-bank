# Easy Bank

一个以金融、银行场景为背景的 Java 微服务示例项目。目标不是完整还原真实银行系统，而是用尽量少的业务逻辑和尽量简化的表结构，演示主流系统设计思路在 Spring Boot + Spring Cloud 体系里的落地方式。

## 当前范围

- 只实现最基础的接口能力
- 当前阶段不做前端 UI
- 以微服务方式拆分功能域
- 优先体现主流设计思想，而不是业务复杂度
- 数据模型保持精简，够表达设计意图即可

## 命名约定

项目中统一使用 `eb` 作为 `easy-bank` 的简称。后续在模块名、服务名、数据库对象名、代码包名辅助标识、配置前缀等需要缩写命名的地方，可以优先使用 `eb`，避免在 `easy-bank`、`easybank`、`eb` 之间混用。  
The project uses `eb` as the standard abbreviation for `easy-bank`. Going forward, whenever abbreviated naming is needed for module names, service names, database objects, package-related identifiers, or configuration prefixes, `eb` should be preferred to avoid mixing `easy-bank`, `easybank`, and `eb`.

推荐的命名示例包括：模块名使用 `eb-service-account`，数据库表名前缀使用 `eb_`，数据库字段或业务流水标识中需要项目级前缀时也可使用 `eb`。  
Recommended naming examples include module names such as `eb-service-account`, database table prefixes such as `eb_`, and using `eb` as the project-level prefix in database fields or business identifiers when a short prefix is needed.

## 技术基线

### 当前应用框架

- Java 25
- Maven 3.9.x
- Spring Boot 4.0.2
- Spring Cloud 2025.1.1
- Spring Cloud Gateway
- Spring Cloud OpenFeign
- Spring Security
- Spring Data JPA
- Spring Boot Actuator

### 当前数据与存储规划

- MySQL 8.0.x（LTS）
- 微服务独立数据库或独立 schema
- 数据库对象统一使用 `eb_` 前缀
- 数据库表主键统一使用雪花 ID，字段类型优先使用 `BIGINT`
- 每个拥有独立数据库的微服务，都在自身项目目录下维护 `db_scripts/` 目录，用于存放建库和更新脚本

### 当前异步与分布式基础设施规划

- Redis
- Kafka
- RocketMQ

### 当前日志与可观测性规划

- ELK / EFK / OpenSearch 体系，用于日志中心化处理
- 统一链路标识与请求标识透传

### 说明

- 当前仓库已经建立 Maven 多模块和各微服务 Spring Boot 项目骨架
- Redis、Kafka、RocketMQ、日志中心等基础设施当前属于规划范围，后续按阶段接入

## 当前文档

- [docs/00-codex-collaboration.md](/Users/neow/Documents/Sourcecode/b5wang/easy-bank/docs/00-codex-collaboration.md)
- [docs/01-functional-scope.md](/Users/neow/Documents/Sourcecode/b5wang/easy-bank/docs/01-functional-scope.md)
- [docs/02-microservice-boundaries.md](/Users/neow/Documents/Sourcecode/b5wang/easy-bank/docs/02-microservice-boundaries.md)
- [docs/03-data-model-overview.md](/Users/neow/Documents/Sourcecode/b5wang/easy-bank/docs/03-data-model-overview.md)

## 当前项目结构

- `eb-common`
  - Java 公共依赖模块，承载统一响应对象、链路标识常量等公共组件
- `eb-gateway`
  - API 网关，负责统一入口和基础路由
- `eb-service-auth`
  - 登录验证、令牌签发、角色权限基础能力
- `eb-service-account`
  - 账户主数据、账户状态、余额写入和余额流水
- `eb-service-transfer`
  - 转账订单和转账流程编排
- `eb-service-channel`
  - 外部银行、商户平台、购物平台等渠道接入与回调处理
- `eb-service-risk`
  - 轻量风控规则与风险决策
- `eb-service-notification`
  - 站内通知和后续可扩展的短信、邮件、推送
- `eb-service-audit`
  - 审计日志留痕
- `eb-service-ops`
  - 重试任务、人工处理报告、对账任务等运维型流程

除了 `eb-gateway` 和 `eb-common`，其余拥有独立数据库的微服务都已经预留 `db_scripts/` 目录，用于放置数据库建库脚本和后续更新脚本。  
Except for `eb-gateway` and `eb-common`, each microservice that owns an independent database now has a reserved `db_scripts/` directory for database creation scripts and future update scripts.

## 当前阶段结论

当前仓库已经完成微服务拆分文档、数据结构设计概览，以及对应的 Maven 多模块 Java 项目骨架。  
The repository now includes the microservice boundary documentation, the data-model overview, and the corresponding Maven multi-module Java project skeleton.

后续继续开发时，默认按照“先明确需求，遇到不清楚的地方先提问；需求明确后先设计数据库结构和业务数据对象关系；之后再编码”的顺序推进。  
When development continues later, the default workflow is: clarify the requirements first and ask questions whenever something is unclear; once the requirements are clear, design the database structure and business data relationships; only then move on to implementation.

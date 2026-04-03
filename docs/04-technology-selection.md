# 技术选型文档
*Technology Selection*

## 1. 文档目标
*Document Goal*

这份文档用于沉淀 `easy-bank` 当前阶段已经确认的技术选型结论，明确为什么选、选什么版本，以及这些选择与项目目标之间的关系。它不是为了追求“技术列表越长越好”，而是为了避免后续在实现阶段反复摇摆，或者因为版本口径不一致导致文档与代码脱节。  
This document captures the technology-selection decisions that have already been confirmed for the current stage of `easy-bank`. It explains why a technology is chosen, which version is chosen, and how that choice relates to the project goals. Its purpose is not to build the longest possible technology list, but to avoid repeated shifts during implementation and prevent documentation from drifting away from the code because of inconsistent version baselines.

当前文件先从数据库选型开始，后续可以继续补充缓存、消息队列、日志中心、服务治理、任务调度和 AI 能力接入等技术基线。  
This file starts with database selection first. It can later be extended with the technical baselines for caching, messaging, centralized logging, service governance, job scheduling, and AI integration.

## 2. 选型原则
*Selection Principles*

- 优先选择主流、生产可用、资料充足、在 Java 微服务体系里长期被验证过的技术。  
  Prefer technologies that are mainstream, production-ready, well documented, and proven over time in the Java microservice ecosystem.
- 优先选择能服务于项目学习目标的方案，而不是单纯追求“最新”“最冷门”或“最复杂”。  
  Prefer options that support the learning goals of the project rather than choosing something just because it is the newest, most niche, or most complex.
- 对于版本变化较快的基础设施组件，必须记录确认日期，并区分“最新 GA”与“最新 LTS”这类容易混淆的概念。  
  For infrastructure components whose versions change quickly, the confirmation date must be recorded, and terms such as “latest GA” and “latest LTS” must be distinguished explicitly because they are easy to confuse.
- 一旦文档确认了技术基线，README、模块配置、数据库脚本和后续代码实现都应与该基线保持一致。  
  Once the documentation confirms a technical baseline, the README, module configuration, database scripts, and later code implementation should all stay aligned with that baseline.

## 3. 数据库选型
*Database Selection*

### 3.1 选型结论
*Decision*

当前项目数据库统一使用 MySQL。  
The project standardizes on MySQL as its database.

截至 `2026-04-03`，本项目当前数据库基线选择 `MySQL 8.4.8 LTS`，并默认在 `8.4 LTS` 大版本内跟随最新稳定补丁版本升级。  
As of `2026-04-03`, the current database baseline for this project is `MySQL 8.4.8 LTS`, and the default policy is to stay on the latest stable patch release within the `8.4 LTS` major line.

这里的“稳定版本”按本项目语境，明确指长期支持、功能变化更可控、适合作为学习型示例项目长期基线的版本，而不是单纯指下载页上数字最大的最新发布包。  
In the context of this project, “stable version” explicitly means a long-term support release with more controlled feature changes and a better fit as a long-lived baseline for a learning-oriented sample project, rather than simply the numerically largest package shown on the download page.

### 3.2 版本判断依据
*Version Basis*

根据 MySQL 官方下载页，在 `2026-04-03` 可见的当前版本中，最新可下载的 GA 版本是 `MySQL 9.6.0 Innovation`，同时最新 LTS 版本是 `MySQL 8.4.8 LTS`。  
According to the MySQL official download page, on `2026-04-03` the latest downloadable GA release is `MySQL 9.6.0 Innovation`, while the latest LTS release is `MySQL 8.4.8 LTS`.

根据 MySQL 官方 FAQ，`MySQL 9.6`、`MySQL 8.4` 和 `MySQL 8.0` 都属于可用于生产环境的 GA 系列。  
According to the MySQL official FAQ, `MySQL 9.6`, `MySQL 8.4`, and `MySQL 8.0` are all GA series that are actively supported for production use.

这意味着“目前最新稳定版本”如果不区分 GA 与 LTS，会产生歧义：  
This means that the phrase “current latest stable version” is ambiguous unless GA and LTS are distinguished:

- 如果按“最新 GA 包”理解，当前是 `MySQL 9.6.0 Innovation`。  
  If it means “latest GA package,” the current answer is `MySQL 9.6.0 Innovation`.
- 如果按“更适合作为长期项目基线的稳定版本”理解，当前应选 `MySQL 8.4.8 LTS`。  
  If it means “the more suitable stable version for a long-lived project baseline,” the current choice should be `MySQL 8.4.8 LTS`.

本项目当前采用第二种解释，并将 `MySQL 8.4.8 LTS` 作为正式文档基线。  
This project adopts the second interpretation and uses `MySQL 8.4.8 LTS` as the formal documented baseline.

### 3.3 为什么选择 MySQL
*Why MySQL*

MySQL 对当前项目是合适的，不是因为它“最先进”，而是因为它与项目目标匹配度高。  
MySQL is a good fit for the current project not because it is the most cutting-edge option, but because it aligns well with the project goals.

第一，MySQL 在 Java、Spring Boot、Spring Data JPA 生态中足够主流，配套资料、驱动、运维经验和社区实践都很成熟。  
First, MySQL is mainstream in the Java, Spring Boot, and Spring Data JPA ecosystem, with mature tooling, drivers, operational experience, and community practices.

第二，项目当前重点是账户、转账、审计、流水、幂等等典型 OLTP 场景，MySQL 的事务能力、索引能力、行级锁和 InnoDB 存储引擎都能很好支撑这些学习主题。  
Second, the project currently focuses on typical OLTP scenarios such as accounts, transfers, auditing, transaction history, and idempotency. MySQL’s transaction support, indexing, row-level locking, and InnoDB storage engine fit these learning themes well.

第三，项目目标是演示主流系统设计，而不是专门研究数据库内核差异。对这一目标来说，MySQL 能用足够低的理解成本承载主要业务设计讨论。  
Third, the project aims to demonstrate mainstream system design rather than study database-kernel differences in depth. For that goal, MySQL supports the main business-design discussions with relatively low cognitive overhead.

### 3.4 当前落地约束
*Current Implementation Constraints*

在后续数据库脚本、JPA 映射和本地开发环境中，默认都应以 `MySQL 8.4 LTS` 兼容性为准，不应再继续沿用 `MySQL 8.0.x (LTS)` 这类已经不准确的表述。  
In later database scripts, JPA mappings, and local development environments, the default compatibility target should be `MySQL 8.4 LTS`. Inaccurate wording such as `MySQL 8.0.x (LTS)` should no longer be used.

当前阶段先确认数据库产品和版本基线，字符集、排序规则、时区、事务隔离级别、索引规范、DDL 管理方式和迁移策略，后续可以在更细化的数据库设计文档中继续补充。  
At the current stage, the priority is to confirm the database product and version baseline first. Character sets, collations, time zones, transaction isolation levels, indexing standards, DDL management, and migration strategy can be documented later in a more detailed database-design document.

## 4. 数据库变更管理选型
*Database Change Management Selection*

### 4.1 选型结论
*Decision*

当前项目数据库结构变更管理正式选择 `Flyway`。  
The project formally chooses `Flyway` for database schema change management.

当前阶段保留各微服务项目内已有的 `db_scripts/` 目录约定，并将其作为数据库迁移脚本的权威归属目录。  
At the current stage, the project keeps the existing `db_scripts/` directory convention inside each microservice project and treats it as the authoritative ownership boundary for database migration scripts.

这意味着后续数据库变更不再以“手工维护零散更新 SQL”的方式为默认路径，而是应逐步收敛为基于版本号的迁移脚本管理模式。  
This means future database changes should no longer default to manually maintained ad hoc update SQL files, but should gradually converge on a versioned migration-script model.

### 4.2 为什么选择 Flyway
*Why Flyway*

第一，Flyway 本身就是围绕数据库迁移管理设计的工具，核心模型直接建立在版本化迁移脚本之上，非常适合当前项目这种“每个微服务各自维护数据库脚本目录”的结构。  
First, Flyway is designed specifically for database migration management, and its core model is directly built around versioned migration scripts. That makes it a natural fit for the current project structure where each microservice maintains its own database-script directory.

第二，Flyway 对 SQL-first 的工作方式非常友好。对于这个项目来说，数据库结构本来就希望尽量直观、易读、易审查，直接维护 SQL 脚本比额外引入更重的变更描述 DSL 更符合当前阶段目标。  
Second, Flyway is very friendly to a SQL-first workflow. For this project, the database structure is already expected to stay direct, readable, and easy to review, so maintaining SQL scripts directly fits the current stage better than introducing a heavier schema-change DSL.

第三，Spring Boot 对 Flyway 有成熟的自动配置支持，这意味着后续如果项目进入编码阶段，可以比较自然地把数据库迁移纳入应用启动或部署流程。  
Third, Spring Boot has mature auto-configuration support for Flyway. This means that once the project enters implementation, database migrations can be integrated naturally into the application startup or deployment flow.

第四，Flyway 与当前已经确定的 MySQL 基线兼容路径清晰，能够在不改变已有 `db_scripts/` 目录归属规则的前提下，为每个微服务提供独立、可追踪、可回放的数据库演进历史。  
Fourth, Flyway has a clear compatibility path with the already chosen MySQL baseline, and it can provide each microservice with an independent, traceable, replayable database evolution history without changing the existing `db_scripts/` ownership convention.

### 4.3 为什么当前不选 Liquibase
*Why Liquibase Is Not Selected for Now*

Liquibase 也是成熟的数据库变更管理方案，并且在 changelog 组织和多种声明式格式支持方面很强。  
Liquibase is also a mature database change-management solution and is strong in changelog organization and support for multiple declarative formats.

但对当前项目来说，Liquibase 的优势更多体现在更复杂的变更编排和声明式抽象层，而这会引入额外的学习成本与维护心智。  
But for the current project, many of Liquibase’s strengths are more relevant to more complex change orchestration and a more declarative abstraction layer, which would introduce additional learning and maintenance overhead.

当前项目更强调“先把数据库设计和 SQL 语义讲清楚”，因此与其在这个阶段引入 XML、YAML 或 JSON changelog 体系，不如先采用更直接的 Flyway SQL 迁移模式。  
The current project puts more emphasis on clearly expressing database design and SQL semantics first. So rather than introducing XML, YAML, or JSON changelog systems at this stage, it is better to start with a more direct Flyway SQL migration model.

因此，当前并不是否定 Liquibase，而是明确它不作为本项目此阶段的正式数据库变更管理基线。  
Therefore, this is not a rejection of Liquibase itself; it is a clear decision that Liquibase is not the formal database change-management baseline for this project at the current stage.

### 4.4 为什么不继续只靠纯 SQL 脚本约定
*Why Pure Ad Hoc SQL Scripts Are Not Enough*

仅仅保留 `db_scripts/` 目录而不引入正式迁移管理工具，虽然短期简单，但后续会很快遇到版本顺序、重复执行、环境一致性和升级追踪的问题。  
Keeping only a `db_scripts/` directory without introducing a formal migration-management tool may look simple in the short term, but it quickly runs into problems with version ordering, repeat execution, environment consistency, and upgrade traceability.

对于微服务项目来说，每个服务数据库都需要独立演进历史；如果没有统一迁移机制，测试环境、开发环境和未来部署环境之间就很容易出现“库结构看起来差不多，但实际上不一致”的情况。  
For a microservice project, each service database needs its own independent evolution history. Without a unified migration mechanism, development, testing, and future deployment environments can easily drift into states where schemas look similar but are not actually the same.

因此，当前项目应保留纯 SQL 的可读性，但不再停留在“人工记忆先执行哪个脚本”的阶段，而是进入“工具管理的版本化 SQL 迁移”阶段。  
Therefore, the project should preserve the readability of plain SQL, but it should stop relying on the manual memory of which script to run first and move into a tool-managed, versioned SQL migration model.

### 4.5 当前落地约束
*Current Implementation Constraints*

每个拥有数据库的微服务继续维护自己的 `db_scripts/` 目录，不把数据库迁移脚本集中堆到仓库根目录。  
Each database-owning microservice should continue maintaining its own `db_scripts/` directory, and migration scripts should not be centralized at the repository root.

迁移脚本默认采用 Flyway 版本化命名方式，例如 `V1__init.sql`、`V2__create_account_table.sql` 这类形式。  
Migration scripts should default to Flyway’s versioned naming style, such as `V1__init.sql` and `V2__create_account_table.sql`.

当前阶段优先采用 SQL migration，不急于引入 Java-based migration 或更复杂的 callback 机制。  
At the current stage, SQL-based migrations should be preferred, without rushing to introduce Java-based migrations or more complex callback mechanisms.

如果未来某个服务需要更细的初始化数据、回填逻辑或大规模数据修复任务，应优先通过单独脚本、批任务或运维任务处理，而不是把所有数据修复逻辑都塞进常规 schema migration。  
If a service later needs more detailed seed data, backfill logic, or large-scale data repair tasks, these should preferably be handled through separate scripts, batch jobs, or operational tasks rather than cramming all data-repair logic into ordinary schema migrations.

在真正进入编码和部署阶段前，如需细化 Flyway 扫描路径、执行时机、失败回滚策略和多环境初始化流程，应单独新增数据库迁移设计文档。  
Before the project reaches full implementation and deployment, if Flyway scan paths, execution timing, failure handling strategy, or multi-environment initialization flow need more detail, a dedicated database-migration design document should be added.

## 5. 缓存选型
*Cache Selection*

### 5.1 选型结论
*Decision*

当前项目主缓存统一选择 `Redis`，不再同时引入第二个分布式缓存产品。  
The project standardizes on `Redis` as its primary cache and does not introduce a second distributed caching product at the same time.

截至 `2026-04-03`，当前文档基线采用 `Redis Open Source 8.6.0`。  
As of `2026-04-03`, the documented baseline for this project is `Redis Open Source 8.6.0`.

如果后续出现明确的单机热点读优化需求，可以把 `Caffeine` 作为服务内本地一级缓存的候选方案，但它不是当前正式技术基线的一部分。  
If a clear need for single-node hot-read optimization appears later, `Caffeine` can be considered as an in-process L1 cache candidate, but it is not part of the formal technical baseline at the current stage.

### 5.2 为什么主缓存选择 Redis
*Why Redis Is the Primary Cache*

第一，项目本身是微服务结构，缓存需求天然不只是“单进程对象复用”，而更偏向“跨实例共享、统一过期、统一失效、统一观测”的分布式缓存场景。  
First, the project is built as a microservice system, so its caching needs are not limited to in-process object reuse. They are naturally closer to distributed-cache scenarios such as cross-instance sharing, unified expiration, unified invalidation, and centralized observability.

第二，Redis 官方数据模型不仅适合最基础的 key-value 缓存，也适合计数器、限流、会话态、短期幂等数据、排行榜和延迟过期等场景。  
Second, Redis’s official data model is suitable not only for basic key-value caching, but also for counters, rate limiting, session state, short-lived idempotency data, ranking, and delayed expiration scenarios.

第三，Spring 生态对 Redis 的集成足够成熟。Spring Data Redis 官方直接提供了 `RedisCacheManager`，可以较自然地接入 Spring Cache 抽象，并支持 TTL 配置。  
Third, Redis integration is mature in the Spring ecosystem. Spring Data Redis officially provides `RedisCacheManager`, which integrates naturally with Spring Cache and supports TTL configuration.

第四，Redis 在“纯缓存”之外还保留了可选的持久化与高可用能力，这让它在后续从简单缓存扩展到更关键的中间层状态承载时更灵活。  
Fourth, beyond pure caching, Redis still provides optional persistence and high-availability capabilities, which makes it more flexible later if the project grows from simple caching to carrying more important middle-layer state.

### 5.3 为什么不把其它缓存工具作为当前主方案
*Why Other Cache Tools Are Not the Current Primary Choice*

`Caffeine` 是很优秀的 Java 本地缓存库，官方也明确把它定位为高性能内存缓存，并支持 Spring Cache 集成。  
`Caffeine` is an excellent Java local-cache library, and its official documentation clearly positions it as a high-performance in-memory cache with Spring Cache integration.

但它的边界也很清楚：它主要解决的是单 JVM 进程内的缓存命中率和访问延迟问题，不解决微服务多实例之间的数据共享、一致失效和统一缓存视图问题。  
But its boundary is also clear: it mainly improves cache hit rate and access latency inside a single JVM process, and it does not solve cross-instance data sharing, consistent invalidation, or a unified cache view across microservices.

对于当前 `easy-bank` 这种强调服务拆分、异步解耦和后续高并发治理演示的项目来说，如果一开始就同时引入 `Redis` 和 `Caffeine` 两套缓存层，会增加失效策略、回源策略、排障路径和测试复杂度。  
For a project like `easy-bank`, which emphasizes service boundaries, asynchronous decoupling, and later high-concurrency governance, introducing both `Redis` and `Caffeine` as cache layers from the beginning would increase invalidation strategy complexity, fallback-path complexity, troubleshooting complexity, and testing complexity.

因此，当前最合适的决策不是“Redis 还是其它缓存工具二选一之后全部并行保留”，而是先把 `Redis` 定为唯一正式缓存基线，把其它缓存工具降级为未来可选优化项。  
Therefore, the most appropriate decision for now is not to keep `Redis` and other cache tools in parallel after choosing between them, but to make `Redis` the only formal cache baseline and demote other cache tools to future optional optimizations.

### 5.4 当前落地约束
*Current Implementation Constraints*

当前阶段缓存能力优先服务于查询加速、短期热点数据、令牌相关临时状态、频率控制和轻量幂等辅助，不把 Redis 提前扩展成新的“主业务数据库”。  
At the current stage, caching should primarily serve query acceleration, short-lived hot data, token-related temporary state, frequency control, and lightweight idempotency support. Redis should not be expanded prematurely into a new “primary business database.”

在没有明确性能瓶颈之前，不默认引入本地二级缓存，不做 `Redis + Caffeine` 双层缓存设计。  
Before there is a clear performance bottleneck, do not introduce a local secondary cache by default and do not design a `Redis + Caffeine` two-layer cache architecture.

如果未来确实出现高频热点只读场景，再单独补充“本地 L1 + Redis L2”方案文档，并明确一致性策略、TTL 策略和失效策略。  
If a true high-frequency hot-read scenario appears later, then add a separate document for an “L1 local cache + L2 Redis” design and explicitly define the consistency strategy, TTL strategy, and invalidation strategy.

## 6. 消息队列选型
*Message Queue Selection*

### 6.1 选型结论
*Decision*

当前项目消息队列统一选择 `Kafka`，不同时引入 `RocketMQ`。  
The project standardizes on `Kafka` as its message queue and does not introduce `RocketMQ` at the same time.

截至 `2026-04-03`，当前文档基线采用 `Apache Kafka 4.2.0`。  
As of `2026-04-03`, the documented baseline for this project is `Apache Kafka 4.2.0`.

当前阶段默认使用 `KRaft` 模式，不再围绕 ZooKeeper 方案设计新的 Kafka 部署或测试基线。  
At the current stage, `KRaft` mode is the default, and no new Kafka deployment or test baseline should be designed around ZooKeeper.

### 6.2 为什么选择 Kafka
*Why Kafka*

第一，Kafka 官方将自身定义为分布式事件流平台，而不是只强调“传统消息队列”。这个定位更贴合 `easy-bank` 后续要演示的领域事件、异步解耦、通知投递、审计扩展、失败补偿和对账事件流。  
First, Kafka officially defines itself as a distributed event streaming platform rather than focusing only on traditional queue semantics. This positioning fits the future `easy-bank` scenarios better, including domain events, asynchronous decoupling, notification delivery, audit expansion, failure compensation, and reconciliation event flows.

第二，Kafka 官方强调高吞吐、可扩展、持久化存储、高可用和 exactly-once processing。这些能力与项目想演示的高并发、高可用和异步治理主题高度一致。  
Second, Kafka officially emphasizes high throughput, scalability, durable storage, high availability, and exactly-once processing. These capabilities align closely with the project’s goals around high concurrency, high availability, and asynchronous governance.

第三，Spring 生态对 Kafka 的支持足够成熟。Spring for Apache Kafka 提供了发送、消费、重试、事务、监控、测试和 exactly-once 相关支持，适合当前 Spring Boot 技术栈。  
Third, Spring ecosystem support for Kafka is mature. Spring for Apache Kafka provides support for sending, consuming, retries, transactions, monitoring, testing, and exactly-once-related integration, which fits the current Spring Boot stack well.

第四，Kafka 作为统一事件总线，更适合让项目后续在“账户变更事件、转账结果事件、通知事件、审计事件、补偿任务触发事件”这些主题上维持同一种事件模型，而不是把 MQ 选型本身变成新的复杂度来源。  
Fourth, Kafka is a better fit as a unified event bus, allowing the project to keep one consistent event model for account-change events, transfer-result events, notification events, audit events, and compensation-trigger events, instead of turning MQ choice itself into a new source of complexity.

### 6.3 为什么当前不选 RocketMQ
*Why RocketMQ Is Not Selected for Now*

RocketMQ 并不是不合适。它在事务消息和顺序消息这类传统业务消息场景上表达非常直接，也很强。  
RocketMQ is not a bad choice. It is strong and very direct in traditional business-message scenarios such as transactional messages and ordered messages.

但对当前项目来说，问题不在于 RocketMQ 能不能用，而在于“是否值得同时维护两套 MQ 认知模型和运维模型”。  
But for the current project, the core question is not whether RocketMQ can be used. It is whether it is worth maintaining two different MQ mental models and operational models at the same time.

如果当前阶段同时保留 `Kafka + RocketMQ`，会把主题规划、消费模型、重试语义、排障链路、测试环境、监控口径和文档复杂度都翻倍，而这些额外复杂度对学习收益不成比例。  
If the project keeps `Kafka + RocketMQ` in parallel at the current stage, it doubles the complexity of topic planning, consumption models, retry semantics, troubleshooting paths, test environments, monitoring conventions, and documentation, while offering limited learning return for the added complexity.

因此，本项目当前的决策不是“Kafka 和 RocketMQ 都保留，后续按场景混用”，而是先选 `Kafka` 作为唯一正式消息中间件基线，把 RocketMQ 留作未来可替代方案。  
Therefore, the current project decision is not “keep both Kafka and RocketMQ and mix them by scenario later,” but to choose `Kafka` as the only formal messaging baseline for now and keep RocketMQ only as a future alternative.

### 6.4 当前落地约束
*Current Implementation Constraints*

当前阶段 Kafka 主要用于业务事件发布与消费，不把 Kafka Streams、Kafka Connect、跨集群复制和复杂流式处理一开始就全部拉进项目。  
At the current stage, Kafka should mainly be used for publishing and consuming business events. Kafka Streams, Kafka Connect, cross-cluster replication, and more complex stream-processing features should not all be pulled into the project from the start.

本项目当前默认采用主题事件模型，不把 Kafka 当成同步 RPC 的替代品，也不把所有跨服务调用都改造成异步消息。  
The project should default to a topic-based event model. Kafka is not a substitute for synchronous RPC, and not every cross-service call should be converted into asynchronous messaging.

本地开发和测试阶段可以使用简化的 Kafka 拓扑，但文档层面的正式基线统一按 `KRaft` 口径描述。  
Local development and testing can use a simplified Kafka topology, but the formal documented baseline should consistently be described in `KRaft` terms.

在真正进入按 topic 的详细设计阶段时，如需进一步补充分 topic 的字段定义、保留策略和流量估算，再新增更细化的消息设计文档。  
When the project reaches detailed per-topic design, if field definitions, retention policies, and traffic estimates need more detail, add a dedicated messaging-design document for those finer details.

## 7. Kafka 事件契约选型
*Kafka Event Contract Selection*

### 7.1 选型结论
*Decision*

当前项目的 Kafka 事件契约统一采用“标准事件信封 + JSON 业务载荷”的模式。  
The Kafka event contract for this project adopts a unified model of a “standard event envelope + JSON business payload”.

事件主题命名统一采用 `eb.<domain>.<event>.v1` 形式，例如 `eb.transfer.created.v1`、`eb.account.balance-reserved.v1`、`eb.notification.dispatch-requested.v1`。  
Topic names follow the form `eb.<domain>.<event>.v1`, for example `eb.transfer.created.v1`, `eb.account.balance-reserved.v1`, and `eb.notification.dispatch-requested.v1`.

事件信封至少包含 `eventId`、`eventType`、`eventVersion`、`occurredAt`、`traceId`、`producer`、`businessKey` 和 `payload`。  
The event envelope should contain at least `eventId`, `eventType`, `eventVersion`, `occurredAt`, `traceId`, `producer`, `businessKey`, and `payload`.

消费者幂等默认基于 `eventId` 或业务唯一键实现，项目当前以 `at-least-once` 交付语义为正式基线，不把“端到端 exactly-once”作为业务正确性的前提。  
Consumer idempotency should by default be implemented through `eventId` or a business-unique key. The formal baseline is `at-least-once` delivery, and end-to-end exactly-once should not be treated as a prerequisite for business correctness.

### 7.2 事件模型与命名约定
*Event Model and Naming Rules*

事件类型应表达“已经发生的业务事实”，而不是命令式调用。例如优先使用 `transfer-created`、`transfer-completed`、`risk-review-required`，而不是 `do-transfer` 或 `call-risk-service`。  
Event types should express “business facts that already happened” rather than imperative commands. Prefer names such as `transfer-created`, `transfer-completed`, and `risk-review-required` instead of `do-transfer` or `call-risk-service`.

`eventType` 与 topic 名应保持语义一致，但不要求完全相同；topic 用来承载流量分组，`eventType` 用来表达事件身份。  
`eventType` and the topic name should stay semantically aligned, but they do not need to be identical; topics group traffic, while `eventType` expresses event identity.

所有事件都必须带 `traceId`，如有上游请求标识，还应带 `requestId` 或 `idempotencyKey`，以便把外部请求、同步调用和异步事件串到同一条排障链路上。  
All events must carry `traceId`. If there is an upstream request identifier, they should also carry `requestId` or `idempotencyKey`, so that external requests, synchronous calls, and asynchronous events can be tied into the same troubleshooting chain.

事件版本优先体现在 topic 名和 `eventVersion` 字段里；对于破坏兼容性的消息变更，按新版本 topic 演进，而不是无约束地原地修改旧载荷。  
Event versioning should primarily be reflected in both the topic name and the `eventVersion` field. Breaking message changes should evolve through a new topic version rather than unconstrained in-place mutation of the old payload.

### 7.3 分区键与顺序约束
*Partition Keys and Ordering Rules*

Kafka 只保证分区内顺序，不保证跨分区全局顺序，因此顺序要求必须显式绑定到分区键设计上。  
Kafka guarantees ordering only within a partition, not globally across partitions, so ordering requirements must be explicitly tied to partition-key design.

转账主流程相关事件默认以 `transferNo` 作为消息 key；账户余额相关事件默认以 `accountNo` 作为消息 key；需要保证“同一业务实体内顺序”的事件，必须稳定使用同一 key。  
Transfer-flow events should by default use `transferNo` as the message key, while account-balance events should by default use `accountNo` as the key. Events that require ordering within the same business entity must consistently use the same key.

如果某类事件没有明确的实体顺序要求，可以按业务主键或路由键做稳定散列，但不能让生产端随机选 key。  
If a class of events has no explicit entity-level ordering requirement, it may use a stable hash of a business key or routing key, but producers should not choose keys randomly.

顺序敏感 topic 不应直接依赖“非阻塞重试 topic 链”来处理所有异常，因为 Spring for Apache Kafka 官方文档明确说明这类重试机制不保证顺序。  
Order-sensitive topics should not rely blindly on non-blocking retry-topic chains for all failures, because the official Spring for Apache Kafka documentation makes it clear that this retry mechanism does not guarantee ordering.

### 7.4 重试、死信与幂等策略
*Retry, Dead-Letter, and Idempotency Strategy*

系统性临时故障与业务性拒绝必须分开处理。  
Transient system failures and business rejections must be handled separately.

对通知、审计这类顺序要求较弱的 topic，可以使用 Spring Kafka 的 retry topic / DLT 模式做有限次数的异步重试。  
For topics with weaker ordering requirements, such as notifications and audit events, Spring Kafka retry topics and DLT can be used for a limited number of asynchronous retries.

对转账状态推进、账户余额变更等顺序要求较强的 topic，优先采用“短暂阻塞重试 + 失败后转人工或补偿队列”的策略，而不是无限制地把消息送入跨 topic 的重试链。  
For topics with stronger ordering requirements, such as transfer state progression and account-balance changes, the preferred strategy is “short blocking retries + transfer to manual handling or compensation queue after failure”, rather than unbounded cross-topic retry chains.

消费者必须把重复消费视为常态，默认按 `eventId`、`businessKey` 或“业务状态机是否已推进”做去重，不能把“消费者只会收到一次”当作前提。  
Consumers must treat duplicate consumption as normal. Deduplication should default to `eventId`, `businessKey`, or a business-state-machine check, and never assume a consumer will receive a record only once.

### 7.5 为什么当前不选 Avro / Protobuf + Schema Registry
*Why Avro / Protobuf with Schema Registry Is Not Selected for Now*

`Avro`、`Protobuf` 和 `Schema Registry` 都是成熟方案，也非常适合更复杂、更高规模的事件契约治理。  
`Avro`, `Protobuf`, and `Schema Registry` are all mature choices and fit more complex, larger-scale event-contract governance very well.

但对当前项目来说，第一阶段更重要的是先把事件边界、topic 语义、分区键、幂等和重试规则说清楚，而不是一开始就再引入一套额外的 schema 基础设施。  
But for the current project, the first priority is to make event boundaries, topic semantics, partition keys, idempotency, and retry rules clear before introducing an additional schema-governance infrastructure from day one.

当前项目的对外与内部接口主基线都已经围绕 `JSON` 展开，因此 Kafka 事件载荷也先统一使用 JSON，更利于调试、日志对照和学习。  
The project’s main external and internal interface baselines already revolve around `JSON`, so Kafka payloads should also use JSON first, which is better for debugging, log comparison, and learning.

如果未来 topic 数量、跨团队协作和兼容性治理复杂度明显上升，再单独评估 `Avro/Protobuf + Schema Registry`。  
If the number of topics, cross-team collaboration, and compatibility-governance complexity increase materially later, `Avro/Protobuf + Schema Registry` can then be evaluated separately.

### 7.6 当前落地约束
*Current Implementation Constraints*

事件信封结构应在 `eb-common` 中统一，不允许各服务各自发明完全不同的事件外壳。  
The event-envelope structure should be unified in `eb-common`, and services should not invent completely different wrappers independently.

topic 设计应优先围绕业务边界而不是消费者列表展开，不以“一个消费者一个 topic”为默认建模方式。  
Topic design should be centered on business boundaries rather than consumer lists, and “one consumer, one topic” should not be the default modeling rule.

事件发布方要明确区分“事务内本地状态更新成功”与“事件已经可靠对外可见”两个阶段，后续如需落地可靠事件发布机制，可再补充 Outbox 或等价方案设计。  
Event publishers should clearly distinguish “local state update committed” from “event reliably visible externally”. If reliable event publication needs to be implemented later, an Outbox or equivalent design can be added separately.

## 8. 日志与可观测性选型
*Logging and Observability Selection*

### 8.1 选型结论
*Decision*

当前项目日志中心化方案统一选择 `OpenSearch + OpenSearch Dashboards + Fluent Bit`。  
The project standardizes on `OpenSearch + OpenSearch Dashboards + Fluent Bit` for centralized logging.

截至 `2026-04-03`，当前文档基线采用 `OpenSearch 3.5.0`、`OpenSearch Dashboards 3.5.0`，以及 `Fluent Bit 5.0.2`。  
As of `2026-04-03`, the documented baseline is `OpenSearch 3.5.0`, `OpenSearch Dashboards 3.5.0`, and `Fluent Bit 5.0.2`.

当前阶段的重点是先把日志统一采集、统一索引、统一检索和基础可视化建立起来，不同时把全套 metrics、traces、APM 和 SIEM 能力全部拉进项目。  
At the current stage, the priority is to establish unified collection, indexing, search, and basic visualization for logs first, without pulling the full metrics, traces, APM, and SIEM stack into the project all at once.

### 8.2 为什么选择 OpenSearch 体系
*Why the OpenSearch Stack*

第一，OpenSearch 本身就把可观测性作为官方能力之一来建设，适合当前项目围绕日志检索、错误定位、链路上下文和后续 AI 日志分析做演示。  
First, OpenSearch itself treats observability as an official capability, which fits the current project’s goals around log search, error diagnosis, trace context, and later AI-assisted log analysis.

第二，OpenSearch Dashboards 可以直接承接日志查询、可视化和基础看板需求，对学习型示例项目来说足够直接，也避免过早引入太重的运维组件拼装复杂度。  
Second, OpenSearch Dashboards directly supports log querying, visualization, and basic dashboard needs. For a learning-oriented sample project, this is direct enough and avoids introducing excessive operational complexity too early.

第三，Fluent Bit 官方定位就是轻量、高性能的 telemetry agent，适合做日志采集和转发层，比一开始就引入更重的日志处理链路更符合当前项目“先最小闭环”的原则。  
Third, Fluent Bit is officially positioned as a lightweight, high-performance telemetry agent. It is a good fit for the log collection and forwarding layer and better matches the project’s “smallest useful closed loop first” principle than introducing a heavier log-processing pipeline from the beginning.

第四，和当前项目已经定下来的 `Spring Boot + Kafka + Redis + MySQL` 技术路线相比，这套方案足够主流，也足够开源友好，不会因为产品授权和版本策略差异带来额外讨论成本。  
Fourth, compared with the already chosen `Spring Boot + Kafka + Redis + MySQL` technical route, this stack is mainstream enough and open-source-friendly enough, without adding unnecessary discussion overhead around product licensing and version-policy differences.

### 8.3 为什么当前不选 ELK / EFK 作为正式基线
*Why ELK / EFK Is Not the Formal Baseline for Now*

`ELK` 和 `EFK` 都是非常经典的日志中心化方案，也足够主流。  
`ELK` and `EFK` are both classic and mainstream centralized-logging solutions.

但对当前项目来说，问题不是这些方案“能不能用”，而是“是否有必要同时把多套同类技术体系都保留在正式基线里”。  
But for the current project, the core question is not whether these options can be used. It is whether multiple similar stacks need to remain in the formal baseline at the same time.

如果文档长期写成 `ELK / EFK / OpenSearch` 并列，一方面会导致后续部署文档、容器编排、索引模板、可视化截图和排障口径都不稳定，另一方面也会让“项目到底标准化在哪一套方案上”一直悬而未决。  
If the documentation keeps `ELK / EFK / OpenSearch` in parallel for too long, deployment docs, container orchestration, index templates, dashboard screenshots, and troubleshooting conventions all remain unstable, and the question of which stack the project is actually standardizing on stays unresolved.

因此，当前应先明确一个正式基线。对 `easy-bank` 来说，`OpenSearch + Dashboards + Fluent Bit` 比“同时保留多个日志方案”更符合当前阶段的目标。  
Therefore, the project should define one formal baseline first. For `easy-bank`, `OpenSearch + Dashboards + Fluent Bit` is more aligned with the current stage than keeping multiple logging stacks in parallel.

### 8.4 当前落地约束
*Current Implementation Constraints*

当前阶段日志中心化只要求覆盖网关日志、应用日志、异常日志和请求链路标识透传，不要求一开始就把完整 tracing 和 metrics 体系一次性做完。  
At the current stage, centralized logging only needs to cover gateway logs, application logs, exception logs, and propagated request trace identifiers. Full tracing and metrics do not need to be completed all at once from the start.

日志采集层优先保持轻量，默认由 `Fluent Bit` 负责采集与转发；复杂日志加工、规则分析和更重的 pipeline 编排，不作为当前首批目标。  
The log collection layer should stay lightweight, with `Fluent Bit` as the default collector and forwarder. Complex log processing, rule analysis, and heavier pipeline orchestration are not part of the first batch of goals.

如果未来要补充指标与链路追踪，建议在这套日志基线之上再单独讨论 `OpenTelemetry` 接入，而不是现在把问题混在同一轮选型里。  
If metrics and distributed tracing are added later, the recommended path is to discuss `OpenTelemetry` on top of this logging baseline as a separate decision, rather than mixing those questions into the current selection round.

## 9. 对外与 UI 接口风格选型
*External and UI API Style Selection*

### 9.1 选型结论
*Decision*

当前项目对外接口和面向 UI 的接口统一采用标准 `REST API` 风格，基于 `HTTP + JSON` 暴露能力。  
The project standardizes on a `REST API` style for external-facing and UI-facing interfaces, exposing capabilities through `HTTP + JSON`.

截至 `2026-04-03`，当前文档基线同时采用 `HTTP Semantics (RFC 9110)` 作为语义参考，采用 `OpenAPI 3.1.1` 作为接口契约描述标准。  
As of `2026-04-03`, the documented baseline also uses `HTTP Semantics (RFC 9110)` as the semantic reference and `OpenAPI 3.1.1` as the API contract description standard.

这条规则当前明确约束两类接口：第一类是最终暴露给外部系统的开放接口；第二类是未来提供给前端 UI 或运营后台的接口。  
This rule explicitly constrains two kinds of interfaces at the current stage: first, open APIs exposed to external systems; second, APIs that will later be provided to frontend UI or operations consoles.

### 9.2 为什么选择标准 REST API
*Why Standard REST APIs*

第一，REST API 仍然是面向浏览器、管理后台、移动端和第三方平台集成时最通用、最容易理解的接口形态。  
First, REST APIs are still the most common and easiest-to-understand interface style for browsers, admin consoles, mobile clients, and third-party platform integrations.

第二，当前项目技术栈已经以 `Spring Boot + Spring Cloud Gateway + OpenFeign` 为核心，REST 风格与现有栈天然兼容，不需要为了接口形态再引入额外技术复杂度。  
Second, the current project stack is already centered around `Spring Boot + Spring Cloud Gateway + OpenFeign`, and the REST style fits that stack naturally without introducing extra technical complexity just for the interface style.

第三，项目现在强调“最小可演示闭环”和“优先体现主流设计思想”，REST API 更适合在这个阶段把资源建模、HTTP 语义、鉴权、幂等、错误码和文档化这些主题讲清楚。  
Third, the project currently emphasizes the “smallest demonstrable closed loop” and “mainstream design ideas first.” REST APIs are better suited at this stage for explaining resource modeling, HTTP semantics, authentication, idempotency, error handling, and documentation clearly.

第四，标准 REST API 也更利于后续自动化测试、接口 Mock、OpenAPI 文档生成，以及基于契约的前后端协作。  
Fourth, standard REST APIs also make automated testing, interface mocking, OpenAPI documentation generation, and contract-based frontend-backend collaboration easier later on.

### 9.3 为什么当前不选 GraphQL / gRPC 作为对外与 UI 基线
*Why GraphQL / gRPC Is Not the Baseline for External and UI APIs*

`GraphQL` 和 `gRPC` 都有明确价值，但对当前项目来说，它们不适合作为对外与 UI 接口的第一基线。  
`GraphQL` and `gRPC` both have clear value, but for the current project they are not the best first baseline for external-facing and UI-facing APIs.

`GraphQL` 更适合复杂聚合查询和前端字段自选场景，但它会把接口安全、缓存策略、查询复杂度控制和监控口径带入新的讨论维度。  
`GraphQL` is more suitable for complex aggregate queries and client-driven field selection, but it introduces additional dimensions of discussion around interface security, caching strategy, query-complexity control, and monitoring conventions.

`gRPC` 很适合高性能内部 RPC 和强类型服务调用，但它不是浏览器、开放平台和普通第三方集成的默认友好接口形态。  
`gRPC` is well suited for high-performance internal RPC and strongly typed service-to-service calls, but it is not the default friendly interface style for browsers, open platforms, and ordinary third-party integrations.

因此，当前项目不是完全排斥这些技术，而是明确它们不进入“对外接口和面向 UI 接口”的正式基线。  
Therefore, the current project does not reject these technologies entirely, but it explicitly keeps them out of the formal baseline for external-facing and UI-facing interfaces.

### 9.4 当前接口设计约束
*Current API Design Constraints*

对外和 UI 接口默认使用资源化路径设计，例如 `/api/accounts`、`/api/transfers/{transferId}` 这类形式，不使用自定义 RPC 风格路径作为默认约定。  
External-facing and UI-facing APIs should default to resource-oriented paths such as `/api/accounts` and `/api/transfers/{transferId}`, rather than using custom RPC-style paths as the default convention.

接口语义默认遵循标准 HTTP 方法：查询优先使用 `GET`，创建优先使用 `POST`，整体更新优先使用 `PUT`，局部更新优先使用 `PATCH`，删除优先使用 `DELETE`。  
API semantics should follow standard HTTP methods by default: use `GET` for reads, `POST` for creation, `PUT` for full replacement, `PATCH` for partial updates, and `DELETE` for deletion.

请求体和响应体默认采用 `application/json`，除非后续出现明确的文件上传、文件下载或流式传输需求。  
Request and response bodies should default to `application/json` unless a clear future need arises for file upload, file download, or streaming transport.

接口返回必须显式使用 HTTP 状态码表达结果，不把所有成功和失败都包装在 `200 OK` 之下。  
API responses must use HTTP status codes explicitly to express outcomes, rather than wrapping every success and failure under `200 OK`.

错误响应建议统一采用兼容 `application/problem+json` 的结构，并结合项目自己的错误码体系，避免每个服务各自发明错误格式。  
Error responses should use a structure compatible with `application/problem+json`, combined with the project’s own error-code system, so that each service does not invent its own error format.

接口文档默认使用 `OpenAPI 3.1.1` 描述，后续如需开放给第三方或前端联调，应优先维护契约文件，而不是只依赖聊天说明。  
API documentation should default to `OpenAPI 3.1.1`. If interfaces are later exposed to third parties or used for frontend integration, the contract file should be maintained first rather than relying only on chat explanations.

对转账申请、入账、扣款这类高可靠写接口，应继续保留 `requestId` 或等价幂等键设计，不因为采用 REST 风格就忽略幂等要求。  
For high-reliability write APIs such as transfer submission, credit, and debit, a `requestId` or equivalent idempotency key should still be retained. Adopting a REST style does not remove the need for idempotency.

### 9.5 边界说明
*Boundary Clarification*

这条规则主要约束项目的 north-south 接口，即面向外部系统和未来 UI 的入口接口。  
This rule mainly constrains the project’s north-south interfaces, meaning the entry APIs exposed to external systems and future UI clients.

服务之间的同步调用当前可以继续沿用 `HTTP/JSON` 方式以保持简单，但这不等于要求项目内部所有通信都必须严格按“对外 REST API”规格建模。  
Synchronous service-to-service calls can continue using `HTTP/JSON` for simplicity, but that does not mean every internal communication path must be modeled according to the full “external REST API” style.

异步场景仍然优先走 Kafka 事件模型，不把 REST API 误用成异步事件分发机制。  
Asynchronous scenarios should still prefer the Kafka event model; REST APIs should not be misused as an asynchronous event-distribution mechanism.

## 10. 接口安全与鉴权基线选型
*API Security and Authentication Baseline*

### 10.1 选型结论
*Decision*

当前项目对外接口和面向 UI 的接口，统一采用 `Bearer Access Token` 作为访问令牌模型，并默认通过 `Authorization: Bearer <token>` 请求头传递。  
The project standardizes on `Bearer Access Token` as the access-token model for external-facing and UI-facing APIs, and by default transmits tokens through the `Authorization: Bearer <token>` request header.

截至 `2026-04-03`，当前文档基线采用 `JWT` 作为访问令牌格式，采用 `RFC 6750` 作为 Bearer Token 传输规范参考，采用 `RFC 7519` 作为 JWT 语义参考，并以 `Spring Security OAuth2 Resource Server` 作为资源侧验证实现基线。  
As of `2026-04-03`, the documented baseline uses `JWT` as the access-token format, `RFC 6750` as the Bearer Token transport reference, `RFC 7519` as the JWT semantic reference, and `Spring Security OAuth2 Resource Server` as the resource-side validation baseline.

当前阶段默认优先采用“项目内签发的 JWT 访问令牌 + 资源服务本地验签”的模式，而不是一开始就强制引入完整的外部 OAuth 2.1 / OpenID Connect 身份平台。  
At the current stage, the default preference is a “project-issued JWT access token + local signature verification by resource servers” model, rather than forcing the introduction of a full external OAuth 2.1 / OpenID Connect identity platform from the beginning.

### 10.2 为什么选择 JWT Bearer Token
*Why JWT Bearer Tokens*

第一，当前项目是微服务结构，资源服务本地验签比“每次请求都回源做令牌校验”更符合简化后的微服务演示目标。  
First, the project is a microservice system, and local token signature verification by each resource server fits the simplified microservice demonstration goal better than making every request call back to a central token-introspection endpoint.

第二，Spring Security 官方对 Bearer Token 和 JWT 资源服务支持非常成熟，和当前 `Spring Boot + Spring Security` 技术路线高度匹配。  
Second, Spring Security’s official support for Bearer Tokens and JWT-based resource servers is mature and highly compatible with the current `Spring Boot + Spring Security` stack.

第三，JWT 天然适合承载最基础的身份与授权上下文，例如 `iss`、`sub`、`aud`、`exp`、`nbf`、角色或 scope 等字段，足够支撑当前项目的最小闭环。  
Third, JWT is naturally suited to carrying basic identity and authorization context such as `iss`, `sub`, `aud`, `exp`, `nbf`, roles, or scopes, which is enough to support the project’s minimal end-to-end flow.

第四，`RFC 6750` 明确了 Bearer Token 的 HTTP 传输方式，`RFC 7519` 明确了 JWT 的 claims 结构，这样项目后续在网关、鉴权过滤器、审计和错误返回方面都能有统一语义。  
Fourth, `RFC 6750` clearly defines the HTTP transport model for Bearer Tokens, and `RFC 7519` clearly defines the claims structure for JWTs. This gives the project a consistent semantic base for gateway handling, authorization filters, auditing, and error responses.

### 10.3 为什么当前不强制上完整 OAuth 2.1 / OIDC 平台
*Why a Full OAuth 2.1 / OIDC Platform Is Not Mandatory Yet*

完整的 OAuth 2.1 或 OpenID Connect 体系并不是不值得做。Spring Authorization Server 官方本身就提供了 OAuth 2.1 和 OIDC 1.0 的实现基础。  
A full OAuth 2.1 or OpenID Connect stack is not a bad idea. Spring Authorization Server itself officially provides a foundation for implementing OAuth 2.1 and OIDC 1.0.

但对当前项目阶段来说，如果一开始就把授权服务器、客户端注册、授权码流程、回调地址管理、OIDC 用户信息端点和更完整的身份平台能力全部拉进来，复杂度会明显高于当前需求。  
But at the current stage of the project, pulling in authorization-server setup, client registration, authorization-code flows, redirect URI management, OIDC UserInfo endpoints, and a fuller identity-platform model from the beginning would raise complexity far beyond the current needs.

当前项目已经明确“先最小闭环、再逐步扩展”，因此更合适的路径是先把 Bearer JWT 访问控制做清楚，再在真正需要对接浏览器登录流、第三方开放平台或标准化授权服务器时，单独升级到更完整的 OAuth 体系。  
The project has already committed to a “smallest closed loop first, then expand gradually” path. So the more appropriate route is to get Bearer JWT access control clear first, and only later upgrade to a fuller OAuth stack when there is a real need for browser login flows, third-party open-platform integration, or a standardized authorization server.

### 10.4 当前落地约束
*Current Implementation Constraints*

访问令牌默认采用签名 JWT，而不是 opaque token。资源服务应重点校验签名、发行者、过期时间、生效时间和目标受众等核心字段。  
Access tokens should default to signed JWTs rather than opaque tokens. Resource servers should focus on validating the signature, issuer, expiration time, not-before time, audience, and other core claims.

Bearer Token 只允许通过 `Authorization` 请求头传递，不把 access token 放到 URL 查询参数里。  
Bearer Tokens should only be transmitted through the `Authorization` request header and should not place access tokens in URL query parameters.

对外与 UI 接口必须建立在 `HTTPS` 之上，不把 Bearer Token 暴露给明文传输链路。  
External-facing and UI-facing APIs must be built on `HTTPS` and must not expose Bearer Tokens over plaintext transport.

资源服务侧默认按无状态鉴权设计，不依赖共享 Session 作为主认证机制。  
Resource servers should default to stateless authentication and should not rely on shared server-side sessions as the primary authentication mechanism.

如需在 JWT 中表达权限，优先使用角色或 scope 这类简单授权信息，不在当前阶段把复杂授权图谱全部塞进令牌。  
If authorization data needs to be expressed inside JWTs, prefer simple role or scope style information instead of pushing a full complex authorization graph into the token at the current stage.

未来如果真正出现浏览器前端登录、第三方开放授权或单点登录需求，再单独引入更完整的 OAuth 2.1 / OIDC 设计，并优先参考 `RFC 9700` 中更新后的 OAuth 2.0 安全最佳实践。  
If browser-based frontend login, third-party delegated authorization, or single sign-on becomes a real need later, introduce a fuller OAuth 2.1 / OIDC design separately and prioritize the updated OAuth 2.0 security best practices described in `RFC 9700`.

### 10.5 边界说明
*Boundary Clarification*

这部分基线主要约束 north-south 接口的访问控制，也就是网关对外暴露的 API 和未来 UI 访问的 API。  
This baseline mainly constrains access control for north-south interfaces, meaning APIs exposed externally through the gateway and APIs accessed later by UI clients.

服务之间的同步调用如果继续沿用 `HTTP/JSON`，可以在内部网络边界上逐步补充服务身份校验，但不要求第一阶段就把所有 east-west 流量都改造成完整 OAuth 资源服务器模式。  
If synchronous service-to-service calls continue to use `HTTP/JSON`, service identity validation can be added gradually at the internal network boundary, but phase one does not require every east-west flow to be converted into a full OAuth resource-server model.

登录接口本身仍由 `eb-service-auth` 负责，令牌签发属于认证域职责；业务服务负责消费和校验令牌，而不是各自独立发令牌。  
The login API itself remains the responsibility of `eb-service-auth`, and token issuance belongs to the authentication domain. Business services consume and validate tokens instead of each one minting its own tokens independently.

## 11. 内部微服务同步通信选型
*Internal Synchronous Service-to-Service Communication*

### 11.1 选型结论
*Decision*

当前项目各内部微服务的同步通信，统一采用 `HTTP/JSON`，并按内部 REST 风格接口进行服务间调用。  
The project standardizes on `HTTP/JSON` for synchronous communication between internal microservices, using internal REST-style APIs for service-to-service calls.

截至 `2026-04-03`，当前文档基线在客户端实现层采用 `Spring Cloud OpenFeign`。  
As of `2026-04-03`, the documented baseline uses `Spring Cloud OpenFeign` on the client implementation side.

这意味着：  
This means:

- 内部同步调用首选 `REST API + JSON`。  
  The preferred model for internal synchronous calls is `REST API + JSON`.
- 当前客户端代理实现首选 `OpenFeign`。  
  The preferred current client-proxy implementation is `OpenFeign`.
- 异步场景仍然优先使用 `Kafka`，不把同步 RPC 和事件驱动混成同一种机制。  
  Asynchronous scenarios should still prefer `Kafka`, without mixing synchronous RPC and event-driven messaging into one mechanism.

### 11.2 为什么当前选 HTTP/JSON + OpenFeign
*Why HTTP/JSON + OpenFeign Is the Current Choice*

第一，当前项目对外接口和面向 UI 的接口已经统一采用标准 REST API，因此内部同步通信继续使用 `HTTP/JSON`，可以让网关入口、服务接口和调试方式保持同一套心智模型。  
First, the project has already standardized on REST APIs for external-facing and UI-facing interfaces. Continuing to use `HTTP/JSON` for internal synchronous communication keeps the gateway entry, service APIs, and debugging workflow under one consistent mental model.

第二，当前技术栈和代码骨架已经显式引入了 `Spring Cloud OpenFeign`。在这种前提下，继续以 OpenFeign 作为当前内部同步调用基线，比在文档阶段再切换到另一套客户端抽象更稳定。  
Second, the current stack and code skeleton already explicitly include `Spring Cloud OpenFeign`. Under that condition, keeping OpenFeign as the current baseline for internal synchronous calls is more stable than switching to another client abstraction while the project is still in the documentation stage.

第三，Spring Cloud OpenFeign 官方本身就把自己定义为 declarative REST client，并且已经和 Spring Cloud LoadBalancer、CircuitBreaker、Micrometer 等 Spring 生态能力打通，足够承载当前项目需要的服务间调用示例。  
Third, Spring Cloud OpenFeign officially positions itself as a declarative REST client, and it is already integrated with Spring Cloud LoadBalancer, CircuitBreaker, Micrometer, and the surrounding Spring ecosystem. That is sufficient for the service-to-service call scenarios this project needs right now.

第四，当前项目重点是边界清晰、数据归属清晰、主流程正确，而不是优先追求极致 RPC 性能。对这个目标来说，`HTTP/JSON + OpenFeign` 的可理解性和落地成本更合适。  
Fourth, the current project prioritizes clear boundaries, clear data ownership, and correctness of the main workflow rather than pushing for maximum RPC performance first. For that goal, `HTTP/JSON + OpenFeign` offers a more appropriate balance of understandability and implementation cost.

### 11.3 为什么当前不选 Dubbo
*Why Dubbo Is Not Selected for Now*

Dubbo 本身并不是不成熟。Apache Dubbo 官方能力覆盖服务发现、负载均衡、流量治理、可观测性、鉴权和多协议支持，是一套完整的服务治理体系。  
Dubbo itself is not immature. Apache Dubbo officially covers service discovery, load balancing, traffic governance, observability, authentication, authorization, and multiple communication protocols, making it a full service-governance system.

但对当前项目来说，Dubbo 的问题不在于“能不能做”，而在于“是否值得为了内部同步调用再引入一整套额外微服务通信体系”。  
But for the current project, the question around Dubbo is not whether it can do the job. It is whether introducing an additional full microservice communication system is worth it just for internal synchronous calls.

如果当前阶段改用 Dubbo，项目会新增接口暴露模型、注册与发现口径、协议配置、治理模型和排障路径，而这些额外复杂度并不能明显提升当前阶段的学习收益。  
If the project switches to Dubbo at the current stage, it would add a new interface exposure model, service registration and discovery conventions, protocol configuration, governance model, and troubleshooting paths, and that added complexity would not materially improve the current learning return.

因此，对 `easy-bank` 当前阶段来说，Dubbo 不作为正式内部同步通信基线。  
Therefore, for the current stage of `easy-bank`, Dubbo is not the formal baseline for internal synchronous communication.

### 11.4 为什么当前不选 gRPC 作为默认同步通信基线
*Why gRPC Is Not the Default Synchronous Baseline for Now*

gRPC 官方基于明确的服务定义与强类型接口，默认使用 Protocol Buffers，并且支持流式通信，这在高性能内部 RPC 场景下很有价值。  
gRPC officially uses explicit service definitions and strongly typed interfaces, defaults to Protocol Buffers, and supports streaming communication, which is valuable in high-performance internal RPC scenarios.

但对当前项目来说，如果把内部同步通信统一切到 gRPC，就意味着还要同时引入 `.proto` 契约、序列化模型、网关适配、浏览器兼容性讨论和新的调试工具链。  
But for the current project, moving all internal synchronous communication to gRPC would also require introducing `.proto` contracts, a new serialization model, gateway adaptation, browser compatibility discussions, and a new debugging toolchain.

这些成本对于当前“先跑通主流设计闭环”的目标来说偏高，因此 gRPC 目前更适合作为未来在特定高吞吐、强类型内部调用场景下再评估的技术，而不是现在的统一基线。  
Those costs are relatively high for the current goal of getting the mainstream design loop working first. So gRPC is better treated as a future option to evaluate for specific high-throughput, strongly typed internal call scenarios rather than as the unified baseline right now.

### 11.5 关于 Spring HTTP Service Client 的说明
*Note on Spring HTTP Service Clients*

需要说明的是，Spring Cloud OpenFeign 官方已经明确把项目视为 feature-complete，并建议迁移到 Spring HTTP Service Clients。  
One important note is that Spring Cloud OpenFeign officially states that the project is now feature-complete and suggests migrating to Spring HTTP Service Clients.

但结合当前仓库现状，项目已经在多个服务模块中引入 OpenFeign 依赖，并启用了 `@EnableFeignClients`。因此当前最稳妥的文档结论不是立刻切换基线，而是先继续以 OpenFeign 作为现有实现基线。  
However, given the current repository state, multiple service modules already include OpenFeign and enable `@EnableFeignClients`. Therefore, the most stable documented conclusion right now is not to switch the baseline immediately, but to continue using OpenFeign as the current implementation baseline.

后续如果项目进入正式编码阶段并准备做一次服务客户端抽象收敛，可以再单独评估是否把 OpenFeign 迁移为 Spring Framework 的 HTTP Service Client。  
Later, once the project enters formal implementation and is ready to consolidate service-client abstractions, it can evaluate separately whether to migrate from OpenFeign to the Spring Framework HTTP Service Client.

### 11.6 当前落地约束
*Current Implementation Constraints*

内部同步调用只用于真正需要即时响应的服务间查询或流程编排，不把所有跨服务交互都做成同步调用。  
Internal synchronous calls should be used only for service-to-service queries or workflow steps that truly require immediate responses, rather than turning every cross-service interaction into a synchronous call.

涉及最终一致性、通知、审计、补偿和异步解耦的场景，仍然优先走 Kafka 事件流。  
Scenarios involving eventual consistency, notifications, auditing, compensation, and asynchronous decoupling should still prefer Kafka event flows.

内部 REST API 默认仍应遵守统一的错误格式、幂等键语义、超时控制和可观测性要求，不能因为是内部接口就随意放宽规范。  
Internal REST APIs should still follow the unified error format, idempotency-key semantics, timeout controls, and observability requirements by default. Internal APIs should not become less disciplined simply because they are not exposed publicly.

在真正进入接口设计阶段时，如需补充服务发现策略、客户端超时、重试、熔断、限流和负载均衡等更细规则，应单独新增“内部通信设计文档”而不是把细节全部堆在本文件里。  
When the project reaches detailed API design, if service-discovery strategy, client timeouts, retries, circuit breaking, rate limiting, and load balancing need more detail, a dedicated “internal communication design document” should be added instead of overloading this file with all implementation details.

## 12. 配置中心选型
*Configuration Center Selection*

### 12.1 选型结论
*Decision*

当前项目统一配置中心正式选择 `Nacos`。  
The project formally chooses `Nacos` as its unified configuration center.

截至 `2026-04-03`，当前文档基线采用 `Nacos 3.1.1`，并配套采用 `Spring Cloud Alibaba 2025.1.x` 体系接入配置能力。  
As of `2026-04-03`, the documented baseline uses `Nacos 3.1.1`, together with the `Spring Cloud Alibaba 2025.1.x` stack for configuration integration.

当前阶段优先把 Nacos 用作统一配置中心；后续如果项目进入更完整的服务治理阶段，可以在同一平台上继续评估是否同时承载服务发现。  
At the current stage, Nacos should first be used as the unified configuration center. If the project later enters a fuller service-governance phase, it can evaluate on the same platform whether to also carry service discovery.

### 12.2 为什么选择 Nacos
*Why Nacos*

第一，Nacos 官方核心能力本身就覆盖动态配置服务，强调配置的集中化、外部化和动态管理，这与当前“所有微服务配置参数在统一地方管理”的目标高度一致。  
First, Nacos officially includes dynamic configuration as a core capability and emphasizes centralized, externalized, and dynamic configuration management, which aligns closely with the current goal of managing microservice configuration parameters in one unified place.

第二，Nacos 不只提供配置中心，还天然带有服务发现能力。即使当前阶段先只用配置中心，这个选型也为后续服务治理保留了统一平台的可能性。  
Second, Nacos does not only provide a configuration center; it also naturally includes service discovery capabilities. Even if the project only uses it as a configuration center at this stage, the choice keeps open the possibility of using one unified platform later for service governance.

第三，Spring Cloud Alibaba 官方 `2025.1.x` 版本已经对应当前代际的 Spring Boot 4.0.x 与 Spring Cloud 2025.1.x，因此在版本兼容层面，Nacos 已经能和当前项目技术基线对齐。  
Third, the official Spring Cloud Alibaba `2025.1.x` line already aligns with the current generation of Spring Boot 4.0.x and Spring Cloud 2025.1.x. From a version-compatibility perspective, Nacos can now match the project’s current technical baseline.

第四，相比单独再搭一套专门的配置服务器，Nacos 对当前项目更符合“少组件、清边界、后续可扩展”的目标。  
Fourth, compared with introducing a separate dedicated configuration server, Nacos better fits the current project’s goals of fewer components, clear boundaries, and future extensibility.

### 12.3 为什么当前不选 Spring Cloud Config 作为正式基线
*Why Spring Cloud Config Is Not the Formal Baseline for Now*

`Spring Cloud Config` 是很成熟的方案，而且它与 Spring 生态天然一致，也非常适合基于 Git 的集中配置管理。  
`Spring Cloud Config` is a mature solution, and it fits naturally into the Spring ecosystem. It is also very suitable for Git-based centralized configuration management.

但对当前项目来说，如果选择 Spring Cloud Config，通常还需要单独维护 Config Server 及其后端存储模式；而一旦后续需要统一服务发现，又往往要再引入另一套注册发现工具。  
But for the current project, choosing Spring Cloud Config usually means separately maintaining a Config Server and its backend storage model; and once unified service discovery is needed later, another registry/discovery tool often still has to be introduced.

相比之下，Nacos 更适合当前项目把“配置中心”与“未来可能的服务发现平台”放在同一条技术路线下考虑。  
By contrast, Nacos is better suited for the current project to keep “configuration center” and “future potential service-discovery platform” on the same technology path.

因此，当前并不是否定 Spring Cloud Config，而是明确它不作为本项目此阶段的正式配置中心基线。  
Therefore, this is not a rejection of Spring Cloud Config itself. It is a clear decision that Spring Cloud Config is not the formal configuration-center baseline for this project at the current stage.

### 12.4 为什么当前不选 Apollo
*Why Apollo Is Not Selected for Now*

Apollo 也是成熟的配置中心方案，并且在配置发布管理方面有明确优势。  
Apollo is also a mature configuration-center solution and has clear strengths in configuration release management.

但对当前项目来说，Apollo 并不能明显降低整体基础设施数量，也不能像 Nacos 一样自然衔接后续可能的服务发现需求。  
But for the current project, Apollo does not materially reduce the overall number of infrastructure components, nor does it connect as naturally as Nacos to future service-discovery needs.

在当前强调“先形成最小但清晰的统一技术路线”的前提下，Apollo 暂不作为正式基线。  
Under the current principle of forming the smallest but clearest unified technical route first, Apollo is not selected as the formal baseline for now.

### 12.5 当前落地约束
*Current Implementation Constraints*

当前阶段 Nacos 首先用于统一管理应用配置、环境差异配置和共享配置，不要求第一阶段就把服务注册发现、流量治理和更复杂的治理能力全部接入。  
At the current stage, Nacos is first used to centrally manage application configuration, environment-specific configuration, and shared configuration. Phase one does not require bringing in service registration, traffic governance, or more advanced governance capabilities all at once.

按照 Spring Cloud Alibaba 官方 `2025.1.x` 用户指南，当前不再通过 `bootstrap.yml` 引入 Nacos，而是通过 `spring.config.import=nacos:` 的方式接入配置。  
According to the official Spring Cloud Alibaba `2025.1.x` guide, Nacos is no longer introduced through `bootstrap.yml`; instead, configuration should be integrated through `spring.config.import=nacos:`.

如果未来要把 Nacos 同时作为服务发现中心，应单独补充服务注册、命名空间、分组、健康检查和本地开发拓扑设计文档，而不是现在直接默认全部启用。  
If Nacos is later also used as the service-discovery center, a separate design document should be added for service registration, namespaces, groups, health checks, and local development topology, instead of assuming all of that is enabled immediately.

配置中心主要承载普通配置项和环境参数。对于更高敏感度的密钥、证书和长期凭据，后续如有必要，应单独讨论是否引入专门的 Secret 管理方案。  
The configuration center should primarily carry ordinary configuration items and environment parameters. For more sensitive keys, certificates, and long-lived credentials, a separate secret-management decision should be discussed later if needed.

## 13. 服务注册与发现选型
*Service Registration and Discovery Selection*

### 13.1 选型结论
*Decision*

当前项目服务注册与发现正式选择 `Nacos`，与配置中心共用同一平台。  
The project formally chooses `Nacos` for service registration and discovery, using the same platform as the configuration center.

内部服务调用默认通过 `Spring Cloud Alibaba Nacos Discovery + Spring Cloud LoadBalancer` 完成服务发现与实例选择。  
Internal service calls should by default use `Spring Cloud Alibaba Nacos Discovery + Spring Cloud LoadBalancer` for service discovery and instance selection.

这意味着当前项目不再额外引入独立的 `Eureka` 或 `Consul` 作为第二套注册发现平台。  
This means the project does not introduce a separate `Eureka` or `Consul` platform as a second registry/discovery stack.

### 13.2 为什么选择 Nacos 同时承载服务发现
*Why Nacos Also Carries Service Discovery*

第一，Nacos 官方概念模型本身就覆盖服务注册、服务发现、实例、分组、命名空间和健康检查等核心元素，因此从能力边界上它完全能承接当前项目的服务发现需求。  
First, the official Nacos concept model already covers core elements such as service registration, service discovery, instances, groups, namespaces, and health checks, so it is fully capable of carrying the current project’s service-discovery needs.

第二，项目已经把 `Nacos` 定为统一配置中心。如果服务发现继续沿同一平台推进，可以减少基础设施数量，也能避免“配置一套、注册另一套”的治理割裂。  
Second, the project has already chosen `Nacos` as the unified configuration center. Continuing service discovery on the same platform reduces infrastructure count and avoids splitting governance between one platform for configuration and another for registration.

第三，当前内部同步通信已经采用 `OpenFeign` 作为实现基线，而 Spring Cloud 体系本身就能把服务发现与客户端负载均衡自然衔接起来。  
Third, the current internal synchronous-communication baseline already uses `OpenFeign`, and the Spring Cloud stack can naturally connect service discovery with client-side load balancing.

第四，这个项目更需要一条“清晰、统一、容易讲清楚”的技术路线，而不是为了展示更多组件去堆叠多个注册中心。  
Fourth, this project needs a technical route that is clear, unified, and easy to explain, rather than stacking multiple registries simply to show more components.

### 13.3 为什么当前不另选 Eureka / Consul
*Why Eureka / Consul Are Not Selected for Now*

`Eureka` 和 `Consul` 都是成熟方案，但对当前项目来说，它们的主要问题不是能力不足，而是会把现有技术路线拆成两条平台路线。  
`Eureka` and `Consul` are both mature solutions, but for the current project the main issue is not lack of capability. It is that they would split the current technical route into two platform tracks.

如果当前已经把配置中心定为 `Nacos`，再单独引入 `Eureka` 或 `Consul` 做服务发现，后续在命名空间、环境隔离、运维入口、权限边界和本地开发拓扑上都会多出一层协调成本。  
If the configuration center is already fixed as `Nacos`, bringing in `Eureka` or `Consul` separately for service discovery adds coordination cost around namespaces, environment isolation, operational entry points, permission boundaries, and local development topology.

因此，本项目当前阶段不是否定这些工具，而是明确它们不进入正式基线。  
Therefore, the project is not rejecting these tools entirely, but it is explicitly keeping them out of the formal baseline for the current stage.

### 13.4 当前落地约束
*Current Implementation Constraints*

`spring.application.name` 应作为服务注册名称的唯一来源，不允许文档名、模块名和注册名长期分裂。  
`spring.application.name` should be the single source for the registered service name. Document names, module names, and registry names should not diverge long term.

环境隔离优先通过 `namespace + group` 组合处理，至少区分 `local / dev / test / prod` 这类环境边界。  
Environment isolation should primarily use a `namespace + group` combination, at minimum distinguishing boundaries such as `local / dev / test / prod`.

服务发现只用于内部 east-west 通信，不对外暴露注册中心能力，也不把它作为 north-south API 治理入口。  
Service discovery is only for internal east-west communication. It should not expose registry capabilities externally or serve as the governance entry point for north-south APIs.

本地开发可以使用单节点 Nacos 简化拓扑，但文档层面的正式设计仍按多实例服务发现语义描述。  
Local development may use a single-node Nacos topology for simplicity, but the formal documented design should still be described in terms of multi-instance service discovery.

## 14. 全局雪花 ID 生成方案选型
*Global Snowflake ID Generation Strategy*

### 14.1 选型结论
*Decision*

当前项目全局主键正式采用项目内统一的 `Snowflake-like 64-bit ID` 方案，并在 `eb-common` 中集中提供生成能力。  
The project formally adopts a unified in-project `Snowflake-like 64-bit ID` strategy for global primary keys, with generation implemented centrally in `eb-common`.

推荐的位段划分为：`41-bit timestamp + 5-bit serviceId + 5-bit nodeId + 12-bit sequence`。  
The recommended bit layout is `41-bit timestamp + 5-bit serviceId + 5-bit nodeId + 12-bit sequence`.

ID 在各服务本地生成，不额外引入远程发号服务作为核心链路依赖。  
IDs should be generated locally inside each service, without introducing a remote ID service as a core dependency in the hot path.

### 14.2 为什么这样设计
*Why This Design*

第一，项目已经把主键统一为 `BIGINT` 作为硬约束，因此继续采用 64 位整数型雪花 ID，和现有数据模型规则最一致。  
First, the project already treats `BIGINT` as a hard primary-key convention, so continuing with a 64-bit integer Snowflake-style ID is the most consistent choice with the existing data-model rules.

第二，本地生成 ID 可以在写库前就拿到业务主键，便于在转账编排、事件发布、审计日志和补偿任务之间统一传递同一个标识。  
Second, local ID generation makes the business key available before persistence, which is convenient for carrying the same identifier consistently across transfer orchestration, event publication, audit logs, and compensation tasks.

第三，把 `serviceId` 显式编码进位段，比经典的“机房位 + 机器位”更贴合当前项目的微服务骨架，也更便于后续把发号责任与服务边界对应起来。  
Third, explicitly encoding `serviceId` in the bit layout fits the current microservice skeleton better than the classic “datacenter bits + worker bits” model, and it makes it easier to align ID-generation responsibility with service boundaries.

第四，保留独立的 `nodeId` 和 `sequence`，既能覆盖单服务多实例部署，也能在不引入额外中心组件的前提下支撑正常并发写入。  
Fourth, retaining separate `nodeId` and `sequence` fields supports multi-instance deployment of one service and normal concurrent writes without introducing an additional central component.

### 14.3 为什么当前不选数据库自增 / UUID / 远程发号服务
*Why Database Auto-Increment, UUID, and a Remote ID Service Are Not Selected for Now*

数据库自增主键不适合作为跨服务统一主键策略，因为它天然绑定单库写入点，也不利于在事件、审计和异步补偿里提前拿到稳定业务标识。  
Database auto-increment keys are not suitable as a unified cross-service key strategy because they are naturally tied to one database write point and do not help when a stable business identifier is needed before insert for events, audit, and asynchronous compensation.

`UUID` 当然能解决全局唯一性问题，但当前项目已经明确优先 `BIGINT`，因此默认不把字符串型 UUID 作为主键基线。  
`UUID` can of course solve global uniqueness, but the project has already clearly prioritized `BIGINT`, so string-based UUIDs are not the primary-key baseline.

远程发号服务虽然可以统一分配 ID，但它会新增一个高频依赖点，并把所有服务写路径都压到新的基础设施热点上。  
A remote ID service can centralize allocation, but it adds a new high-frequency dependency and turns all service write paths into traffic on another infrastructure hot spot.

因此，当前阶段更合适的方案是统一算法、本地发号、集中约束，而不是再引入一个新的中心服务。  
Therefore, the more suitable choice at this stage is a unified algorithm, local generation, and centralized constraints rather than introducing another central service.

### 14.4 当前落地约束
*Current Implementation Constraints*

`serviceId` 应由项目统一维护固定映射表，不允许各服务在代码里随意挑选。  
`serviceId` should be maintained through one fixed mapping table for the project, and services should not choose it arbitrarily in code.

`nodeId` 应通过环境变量、Nacos 配置或部署参数显式注入，同一服务的多个实例不能复用同一个 `nodeId`。  
`nodeId` should be injected explicitly through environment variables, Nacos configuration, or deployment parameters. Multiple instances of the same service must not reuse the same `nodeId`.

本地开发如只启动单实例，可给每个服务分配固定低位 `nodeId`；如需多实例联调，必须手动改开不同 `nodeId`。  
For local development, if only one instance is started, each service can use a fixed low-value `nodeId`; if multi-instance local testing is needed, different `nodeId` values must be configured manually.

出现时钟回拨时，生成器默认应优先 fail fast 或短暂等待，而不是静默继续发号。  
When clock rollback occurs, the generator should fail fast or pause briefly by default rather than silently continuing to issue IDs.

## 15. 流量治理与故障隔离选型
*Traffic Governance and Fault-Isolation Selection*

### 15.1 选型结论
*Decision*

网关入口限流正式采用 `Spring Cloud Gateway RequestRateLimiter + Redis`。  
Gateway entry rate limiting formally adopts `Spring Cloud Gateway RequestRateLimiter + Redis`.

内部同步调用的故障隔离正式采用 `Spring Cloud CircuitBreaker + Resilience4j`。  
Fault isolation for internal synchronous calls formally adopts `Spring Cloud CircuitBreaker + Resilience4j`.

当前治理基线默认包含 `timeout + circuit breaker + bulkhead`，而不是只做熔断。  
The current governance baseline includes `timeout + circuit breaker + bulkhead` by default, rather than circuit breaking alone.

自动重试不作为写操作默认基线；只有在接口具备明确幂等语义且业务上允许重试时，才按接口逐项开启。  
Automatic retry is not the default baseline for write operations. It should only be enabled case by case when an interface has explicit idempotent semantics and the business flow truly permits retries.

### 15.2 为什么这样组合
*Why This Combination*

第一，当前项目已经把 `eb-gateway` 作为统一入口，而 `Spring Cloud Gateway` 官方提供 `RequestRateLimiter` 过滤器；其 Redis 实现基于令牌桶算法，这与当前项目已经选定 `Redis` 的基础设施路线一致。  
First, the project already positions `eb-gateway` as the unified entry point, and `Spring Cloud Gateway` officially provides the `RequestRateLimiter` filter. Its Redis implementation is based on a token-bucket algorithm, which fits the project’s already selected Redis infrastructure route.

第二，`Spring Cloud CircuitBreaker` 官方已经提供对 `Resilience4j` 的集成，能够在 Spring 体系下统一承载 `CircuitBreaker`、`TimeLimiter` 和 `Bulkhead` 等能力，比较符合当前“少引入额外体系、优先沿现有 Spring 技术路线推进”的原则。  
Second, `Spring Cloud CircuitBreaker` officially integrates with `Resilience4j`, allowing the Spring stack to consistently carry capabilities such as `CircuitBreaker`, `TimeLimiter`, and `Bulkhead`. This matches the current principle of introducing as few extra systems as possible and continuing along the existing Spring-based route.

第三，金融写操作更需要“明确失败、阻止扩散、进入补偿或人工处理”，而不是依赖模糊的自动降级成功。因此，把超时、隔离和熔断作为核心，把自动重试和默认 fallback 放在更谨慎的位置，更符合转账场景。  
Third, financial write operations need “explicit failure, fault containment, and transition into compensation or manual handling” more than ambiguous automatic degradation to success. Therefore, making timeouts, isolation, and circuit breaking the core while treating automatic retries and default fallbacks cautiously is a better fit for transfer scenarios.

### 15.3 为什么当前不选更重的治理方案
*Why Heavier Governance Options Are Not Selected for Now*

当前阶段不把 `Sentinel` 作为正式基线，也不引入 Service Mesh 一类更重的流量治理平台。  
At the current stage, `Sentinel` is not chosen as the formal baseline, and heavier traffic-governance platforms such as a Service Mesh are not introduced.

原因不是这些方案本身不好，而是当前项目首先需要的是一套能与 `Spring Cloud Gateway`、`OpenFeign`、`Redis` 和现有 Spring 技术栈自然衔接的最小闭环。  
The reason is not that these solutions are poor. The project first needs a minimal closed loop that integrates naturally with `Spring Cloud Gateway`, `OpenFeign`, `Redis`, and the existing Spring stack.

在项目仍处于文档驱动和骨架阶段时，先把“入口限流 + 服务超时 + 熔断 + 隔离”这条基础治理链路做清楚，收益明显高于一次性引入更大的治理体系。  
While the project is still in a documentation-driven and skeleton stage, clarifying the baseline governance chain of “entry rate limiting + service timeout + circuit breaking + isolation” brings more value than introducing a larger governance system all at once.

### 15.4 当前落地约束
*Current Implementation Constraints*

网关限流默认按“用户标识 / 账户标识 / 客户端标识 / IP / 渠道来源”组合建模，不使用只按 URL 路径做的粗粒度限流作为长期方案。  
Gateway rate limiting should by default model combinations such as “user identity / account identity / client identity / IP / channel source”, rather than relying on URL-path-only coarse-grained limiting as a long-term solution.

登录、令牌刷新、验证码申请、转账发起、外部平台转账提交和外部回调接收，属于第一批必须加限流或频控的接口。  
Login, token refresh, verification-code requests, transfer initiation, external-platform transfer submission, and external callback intake belong to the first batch of interfaces that must receive rate limiting or frequency control.

`transfer -> account`、`transfer -> risk`、`transfer -> channel` 等关键同步调用必须显式配置超时和故障隔离，不能依赖默认无限等待。  
Critical synchronous calls such as `transfer -> account`, `transfer -> risk`, and `transfer -> channel` must explicitly configure timeouts and fault isolation, rather than relying on implicit indefinite waiting.

涉及余额扣减、状态推进、外部出款等写路径时，默认不做通用自动重试；如果后续确需开启，必须先补齐幂等键、去重语义和补偿规则。  
For write paths involving balance deduction, state transitions, or external payout, generic automatic retries should be disabled by default. If retries are later required, idempotency keys, deduplication semantics, and compensation rules must be defined first.

熔断的目标是防止故障扩散，而不是伪造业务成功结果；对关键金融写接口，失败后应返回明确失败或进入补偿 / 人工处理，而不是静默 fallback。  
The goal of circuit breaking is to prevent fault amplification, not to fabricate successful business outcomes. For critical financial write interfaces, failure should return an explicit failure or enter compensation / manual handling, rather than silently falling back.

## 16. 任务调度与 Job 框架选型
*Task Scheduling and Job Framework Selection*

### 16.1 选型结论
*Decision*

当前项目统一任务调度框架正式选择 `Quartz`。  
The project formally chooses `Quartz` as its unified task-scheduling framework.

关键定时任务、补偿任务、对账任务和批处理任务优先集中在 `eb-service-ops` 中调度，并使用持久化 `JobStore`。  
Critical scheduled tasks, compensation tasks, reconciliation tasks, and batch jobs should be scheduled primarily inside `eb-service-ops` and use a persistent `JobStore`.

`@Scheduled` 只适合作为极轻量、本地单实例的辅助手段，不作为项目正式分布式调度基线。  
`@Scheduled` is suitable only as a very lightweight auxiliary mechanism for local single-instance use and is not the project’s formal distributed-scheduling baseline.

### 16.2 为什么选择 Quartz
*Why Quartz*

第一，Quartz 是成熟的 Java 调度框架，支持 Cron、持久化作业、失败恢复和集群部署，能力边界和当前项目的运维类任务比较匹配。  
First, Quartz is a mature Java scheduling framework that supports Cron scheduling, persistent jobs, failure recovery, and clustered deployment, which aligns well with the operations-style tasks in this project.

第二，Quartz 可以直接配合 JDBC JobStore 落到当前已经选定的 MySQL 基线上，不必为了调度单独再引入新的核心中间件。  
Second, Quartz can work directly with JDBC JobStore on top of the already selected MySQL baseline, without introducing another core middleware just for scheduling.

第三，当前项目已经把失败重试、人工处理报告、补偿和对账主要放在 `eb-service-ops` 这个专门服务里，因此“一个明确的调度中心服务 + 一个成熟调度框架”比把所有服务都各自挂一批定时任务更清晰。  
Third, the project already places failure retries, manual-handling reports, compensation, and reconciliation mainly inside the dedicated `eb-service-ops` service. Therefore, “one clear scheduling service + one mature scheduling framework” is cleaner than letting every service carry its own set of timers.

### 16.3 为什么当前不只用 @Scheduled，也不选 XXL-JOB
*Why the Project Uses Neither Only @Scheduled nor XXL-JOB as the Baseline*

单纯使用 `@Scheduled` 的问题在于，它更适合简单本地定时任务，缺少持久化作业、集中调度状态和跨实例协同语义。  
The problem with using only `@Scheduled` is that it is better suited to simple local timers and lacks persistent jobs, centralized scheduling state, and cross-instance coordination semantics.

`XXL-JOB` 本身是成熟的分布式任务调度平台，也有很完整的管理能力。  
`XXL-JOB` itself is a mature distributed task-scheduling platform and provides rich management capabilities.

但对当前项目来说，`XXL-JOB` 会额外引入独立调度中心组件；同时其官方仓库当前采用 `GPL-3.0` 许可，作为本项目默认依赖基线并不够稳妥。  
But for the current project, `XXL-JOB` introduces an extra standalone scheduling-center component; meanwhile, its official repository currently uses the `GPL-3.0` license, which is not conservative enough for this project’s default dependency baseline.

因此，当前阶段先选 `Quartz`，把调度闭环做小做清楚；后续如果确实需要更强的可视化编排平台，再单独评估是否升级。  
Therefore, the project should first choose `Quartz` to keep the scheduling loop small and clear. If stronger visual orchestration is truly needed later, that can be evaluated as a separate upgrade.

### 16.4 当前落地约束
*Current Implementation Constraints*

业务微服务默认不各自维护大量独立调度任务；需要跨服务重试、补偿或对账的任务优先汇总到 `eb-service-ops`。  
Business microservices should not each maintain a large number of independent scheduled jobs by default. Tasks involving cross-service retries, compensation, or reconciliation should first be consolidated in `eb-service-ops`.

调度任务必须具备幂等性，避免因为节点重启、重复触发或人工补跑导致业务状态被重复推进。  
Scheduled jobs must be idempotent to avoid pushing business state forward repeatedly because of restarts, duplicate triggers, or manual re-runs.

长耗时批处理任务应做分批、分页或分片设计，不把单次 Quartz Job 设计成无限执行的大事务。  
Long-running batch jobs should be designed in batches, pages, or shards rather than turning a single Quartz job into an unbounded large transaction.

## 17. 指标与链路追踪选型
*Metrics and Distributed Tracing Selection*

### 17.1 选型结论
*Decision*

当前项目指标体系正式选择 `Micrometer + Prometheus`。  
The project formally chooses `Micrometer + Prometheus` for metrics.

当前项目链路追踪正式选择 `OpenTelemetry + OTLP + Jaeger`。  
The project formally chooses `OpenTelemetry + OTLP + Jaeger` for distributed tracing.

日志、指标和链路的关联基线统一依赖 `traceId / spanId` 贯通。  
The correlation baseline across logs, metrics, and traces relies on consistent propagation of `traceId / spanId`.

### 17.2 为什么这样组合
*Why This Combination*

第一，Micrometer 是 Spring Boot 应用观测能力的标准抽象层，和当前项目的 Spring 技术栈天然匹配。  
First, Micrometer is the standard abstraction layer for observability in Spring Boot applications and fits naturally with the current Spring stack.

第二，Prometheus 官方以 pull 模式抓取指标，特别适合微服务场景下按实例暴露 `/actuator/prometheus` 一类指标端点。  
Second, Prometheus officially uses a pull model for collecting metrics, which is well suited to microservices exposing per-instance metric endpoints such as `/actuator/prometheus`.

第三，OpenTelemetry 已经成为跨语言、跨框架的主流可观测性标准，适合把链路采集、上下文透传和后续 exporter 演进统一到同一套语义下。  
Third, OpenTelemetry has become the mainstream cross-language, cross-framework observability standard, making it suitable for unifying tracing, context propagation, and future exporter evolution under one semantic model.

第四，Jaeger 作为专门的 trace 后端，比纯日志检索更适合直接观察一次请求或一次转账链路经过了哪些服务和环节。  
Fourth, Jaeger as a dedicated trace backend is better than plain log search for directly observing which services and steps one request or one transfer passed through.

### 17.3 为什么不只依赖日志体系
*Why Logging Alone Is Not Enough*

日志适合做细节排障，但它并不擅长替代基础指标和完整链路视图。  
Logs are good for detailed troubleshooting, but they are not a good substitute for baseline metrics and full request-path views.

如果只依赖日志检索，很难低成本稳定回答“某接口 95 分位延迟是多少”“某消费者 lag 是否持续升高”“一次转账跨了哪些服务”这类问题。  
If the project relies only on log search, it becomes difficult to answer questions like “what is the p95 latency of this API,” “is consumer lag continuously increasing,” or “which services did one transfer cross” in a stable and low-cost way.

因此，当前文档里的日志中心化方案和这一节的指标 / tracing 方案是互补关系，不是二选一关系。  
Therefore, the centralized logging solution already documented and the metrics/tracing strategy in this section are complementary, not mutually exclusive.

### 17.4 当前落地约束
*Current Implementation Constraints*

所有服务都应统一输出基础 JVM、HTTP、数据库连接池、Kafka 生产 / 消费和自定义业务指标。  
All services should expose a unified baseline of JVM, HTTP, database-pool, Kafka producer/consumer, and custom business metrics.

关键业务路径至少应覆盖：登录、账户查询、转账创建、余额变更、风控判定、渠道调用和通知分发。  
At minimum, the critical business paths that should be traced include login, account lookup, transfer creation, balance changes, risk decisions, channel calls, and notification dispatch.

日志必须带 `traceId`，否则日志中心、指标告警和 trace 查询之间无法稳定串联。  
Logs must carry `traceId`; otherwise, the log center, metric alerts, and trace queries cannot be correlated reliably.

当前阶段可以先不引入独立的 OpenTelemetry Collector；如果后续 telemetry 类型和路由复杂度上升，再评估是否补上 Collector。  
At the current stage, the project may postpone introducing a standalone OpenTelemetry Collector. If telemetry types and routing complexity increase later, a Collector can then be evaluated.

## 18. Secret 管理选型
*Secret Management Selection*

### 18.1 选型结论
*Decision*

当前项目正式 Secret 管理方案选择 `HashiCorp Vault + Spring Vault`。  
The project formally chooses `HashiCorp Vault + Spring Vault` as its secret-management solution.

普通配置继续由 `Nacos` 管理，但高敏感凭据不与普通配置混放。  
Ordinary configuration continues to be managed by `Nacos`, but highly sensitive credentials should not be mixed with ordinary configuration.

本地开发阶段允许使用环境变量或未纳入版本控制的本地配置文件作为临时替代。  
For local development, environment variables or untracked local configuration files are allowed as temporary substitutes.

### 18.2 为什么选择 Vault
*Why Vault*

第一，Vault 官方定位就是集中化 Secret 管理、访问控制、审计和密钥生命周期管理，这与当前项目对数据库密码、JWT 密钥、渠道密钥和证书管理的需求高度一致。  
First, Vault is officially positioned for centralized secret management, access control, auditing, and key-lifecycle management, which aligns closely with this project’s needs around database passwords, JWT keys, channel secrets, and certificates.

第二，Spring Vault 已经提供了成熟的 Spring 集成路径，适合当前项目继续沿 Spring 技术栈推进。  
Second, Spring Vault already provides a mature Spring integration path, which suits the project’s continued use of the Spring stack.

第三，把普通配置和高敏感 Secret 分层管理，比把所有内容都塞进同一套配置中心更符合金融类系统的最小安全边界。  
Third, layering ordinary configuration and highly sensitive secrets into separate management paths is a better minimal security boundary for a finance-style system than placing everything in one configuration center.

### 18.3 为什么当前不直接依赖 Nacos 或纯环境变量
*Why the Project Does Not Rely Only on Nacos or Plain Environment Variables*

`Nacos` 更适合作为普通配置中心，而不是 Secret 生命周期管理平台。  
`Nacos` is better suited as an ordinary configuration center than as a secret-lifecycle management platform.

纯环境变量虽然简单，但它更适合作为本地开发或极简部署阶段的替代手段，不适合作为长期统一治理方案。  
Plain environment variables are simple, but they are better as a local-development or ultra-simple deployment fallback than as the long-term unified governance solution.

如果项目未来运行环境切到 Kubernetes，也仍然可以在 `Vault` 之上再对接 Kubernetes Secret 或工作负载身份，而不需要重写整体 Secret 策略。  
If the runtime environment later moves to Kubernetes, the project can still integrate Kubernetes Secrets or workload identity on top of `Vault` without rewriting the overall secret strategy.

### 18.4 当前落地约束
*Current Implementation Constraints*

数据库密码、JWT 签名密钥、第三方渠道 API Key、回调验签密钥和证书类材料，默认都应进入 Secret 管理范围。  
Database passwords, JWT signing keys, third-party channel API keys, callback signature keys, and certificate materials should all fall into the default secret-management scope.

任何 Secret 都不应提交到 Git 仓库，也不应出现在 README、示例配置或长期保存的调试日志里。  
No secret should ever be committed to Git, and no secret should appear in README files, sample configuration, or long-lived debug logs.

应用启动阶段如需读取 Secret，应优先通过 Spring 集成方式装配，而不是在业务代码中散落写死读取逻辑。  
If an application needs to read secrets during startup, it should prefer Spring-based integration rather than scattering hard-coded retrieval logic throughout business code.

## 19. 分布式事务技术路线选型
*Distributed Transaction Approach Selection*

### 19.1 选型结论
*Decision*

当前项目跨服务一致性的正式技术路线选择“应用层 `Saga` 编排 + 本地事务 + Kafka 事件 + 幂等与补偿”。  
The project formally chooses “application-layer `Saga` orchestration + local transactions + Kafka events + idempotency and compensation” as its cross-service consistency approach.

`eb-service-transfer` 负责主流程编排，`eb-service-ops` 负责失败重试、补偿推进和人工处理入口。  
`eb-service-transfer` is responsible for main-flow orchestration, while `eb-service-ops` handles retry progression, compensation, and the manual-handling entry point.

项目不采用跨服务共享数据库事务，也不把全局 2PC/XA 作为默认基线。  
The project does not use a shared cross-service database transaction and does not treat global 2PC/XA as the default baseline.

### 19.2 为什么选择 Saga + 本地事务
*Why Saga with Local Transactions Is Chosen*

第一，项目已经明确采用“每个服务独立数据库或独立 schema、跨服务不建外键”的数据归属原则，因此用应用层编排和补偿表达跨服务一致性，比引入隐式全局事务更符合边界设计。  
First, the project has already adopted the data-ownership rule of “one database or schema per service, with no cross-service foreign keys”, so expressing cross-service consistency through application-layer orchestration and compensation is more aligned with the boundary design than introducing implicit global transactions.

第二，转账场景天然存在“受理中、风控中、冻结成功、渠道处理中、成功、失败、待人工处理”这类业务状态，因此 Saga 方式更容易把过程显式建模出来。  
Second, transfer scenarios naturally contain business states such as “accepted, under risk review, reserve succeeded, channel processing, success, failure, and pending manual handling”, so a Saga-style approach is better for modeling the process explicitly.

第三，`Saga + 幂等 + 补偿` 更容易和当前已经确定的 Kafka 事件模型、审计要求和运维补偿职责拼成同一套闭环。  
Third, `Saga + idempotency + compensation` is easier to combine into one closed loop with the Kafka event model, audit requirements, and operations-side compensation responsibilities that the project has already chosen.

### 19.3 为什么当前不选 Seata AT / TCC 作为正式基线
*Why Seata AT / TCC Are Not the Formal Baseline for Now*

`Seata` 是成熟的分布式事务产品，也支持 `AT`、`TCC`、`Saga` 等多种模式。  
`Seata` is a mature distributed-transaction product and supports multiple modes such as `AT`, `TCC`, and `Saga`.

但对当前项目来说，`AT` 模式更偏向通过数据源代理在底层兜住一致性，这和项目当前强调“边界显式、业务状态显式”的设计取向不完全一致。  
But for the current project, `AT` mode leans more toward achieving consistency through data-source proxies underneath the business layer, which does not fully match the project’s current design preference for explicit boundaries and explicit business states.

`TCC` 模式虽然强，但它要求每个参与方都实现 `Try / Confirm / Cancel` 三段式接口，侵入性和实现成本都很高，不适合作为当前第一版基线。  
`TCC` mode is powerful, but it requires every participant to implement `Try / Confirm / Cancel` triplet interfaces. Its intrusiveness and implementation cost are high, so it is not a good first-version baseline.

因此，当前阶段更合适的路线是先把应用层 Saga 闭环做清楚，而不是一开始就把事务框架复杂度拉满。  
Therefore, the more suitable route at this stage is to make the application-layer Saga loop clear first rather than maximizing transaction-framework complexity from the beginning.

### 19.4 当前落地约束
*Current Implementation Constraints*

任何跨服务业务流程都不能依赖一个全局数据库事务一次性提交完成。  
No cross-service business flow may rely on one global database transaction to commit everything in a single step.

每个关键步骤都应有明确的业务状态记录、补偿状态记录和人工处理入口。  
Each critical step should have explicit business-state records, compensation-state records, and a manual-handling entry point.

所有参与 Saga 的写接口都必须具备幂等能力，并能通过 `requestId`、`transferNo` 或等价业务键做去重。  
All write APIs participating in a Saga must be idempotent and be able to deduplicate through `requestId`, `transferNo`, or an equivalent business key.

如果后续要补充可靠事件发布机制，应优先考虑 Outbox 或等价方案与本地事务配合，而不是把业务正确性完全押在消息中间件的“只投一次”假设上。  
If reliable event publication is added later, the preferred route is an Outbox or equivalent mechanism coordinated with local transactions rather than assuming the message middleware will “deliver only once” as the basis of business correctness.

## 20. 参考来源
*References*

- [MySQL Community Server Downloads](https://dev.mysql.com/downloads/mysql/)
- [MySQL 8.4 FAQ: Which version of MySQL is production-ready (GA)?](https://dev.mysql.com/doc/refman/8.4/en/faqs-general.html)
- [MySQL Reference Manual: Downgrading MySQL](https://dev.mysql.com/doc/refman/9.6/en/downgrading.html)
- [Redis data types](https://redis.io/docs/latest/develop/data-types/)
- [Redis persistence](https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/)
- [Spring Data Redis Cache](https://docs.spring.io/spring-data/redis/reference/redis/redis-cache.html)
- [Redis Open Source 8.6 release notes](https://redis.io/docs/latest/operate/oss_and_stack/stack-with-enterprise/release-notes/redisce/redisos-8.6-release-notes/)
- [Caffeine GitHub README](https://github.com/ben-manes/caffeine)
- [Apache Kafka homepage](https://kafka.apache.org/)
- [Apache Kafka Introduction](https://kafka.apache.org/intro/)
- [Apache Kafka releases](https://kafka.apache.org/documentation/)
- [Spring for Apache Kafka What’s New](https://docs.spring.io/spring-kafka/reference/whats-new.html)
- [Spring for Apache Kafka Retry Topic Configuration](https://docs.spring.io/spring-kafka/reference/retrytopic/retry-config.html)
- [RocketMQ transaction message](https://rocketmq.apache.org/docs/featureBehavior/04transactionmessage/)
- [OpenSearch downloads](https://opensearch.org/downloads/)
- [OpenSearch release schedule and maintenance policy](https://opensearch.org/releases/)
- [OpenSearch documentation](https://docs.opensearch.org/)
- [OpenSearch observability](https://docs.opensearch.org/latest/observing-your-data/observability/index/)
- [Fluent Bit official docs](https://docs.fluentbit.io/)
- [Fluent Bit v5.0.2 release notes](https://fluentbit.io/announcements/v5.0.2)
- [HTTP Semantics (RFC 9110)](https://www.rfc-editor.org/rfc/rfc9110)
- [Problem Details for HTTP APIs (RFC 9457)](https://www.rfc-editor.org/rfc/rfc9457.html)
- [OpenAPI Specification v3.1.1](https://spec.openapis.org/oas/v3.1.1.html)
- [RFC 6750: Bearer Token Usage](https://www.rfc-editor.org/rfc/rfc6750)
- [RFC 7519: JSON Web Token (JWT)](https://www.rfc-editor.org/rfc/rfc7519)
- [RFC 9700: Best Current Practice for OAuth 2.0 Security](https://www.rfc-editor.org/rfc/rfc9700)
- [Spring Security OAuth2 Resource Server](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/index.html)
- [Spring Security OAuth2 Resource Server JWT](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/jwt.html)
- [Spring Authorization Server Overview](https://docs.spring.io/spring-authorization-server/reference/overview.html)
- [Spring Cloud OpenFeign Reference](https://docs.spring.io/spring-cloud-openfeign/reference/index.html)
- [Spring Framework REST Clients](https://docs.spring.io/spring-framework/reference/web/webmvc-client.html)
- [Apache Dubbo Core Features](https://dubbo.apache.org/en/overview/what/core-features/)
- [gRPC Core Concepts](https://grpc.io/docs/what-is-grpc/core-concepts/)
- [Nacos official website](https://nacos.io/en/)
- [Nacos Concepts](https://nacos.io/en/docs/v2.3/concepts/)
- [Spring Cloud Alibaba 2025.x Nacos Guide](https://sca.aliyun.com/docs/2025.x/user-guide/nacos/quick-start/)
- [Spring Cloud Alibaba 2025.x Nacos Advanced Guide](https://sca.aliyun.com/docs/2025.x/user-guide/nacos/advanced-guide/)
- [Spring Cloud Alibaba Version Mapping](https://github.com/alibaba/spring-cloud-alibaba)
- [Spring Cloud Config Reference](https://docs.spring.io/spring-cloud-config/reference/)
- [Redgate Flyway Documentation](https://documentation.red-gate.com/fd)
- [Flyway Supported Databases](https://documentation.red-gate.com/fd/supported-databases-and-versions-143754067.html)
- [Spring Boot Database Initialization and Flyway](https://docs.spring.io/spring-boot/how-to/data-initialization.html)
- [Liquibase Documentation](https://docs.liquibase.com/)
- [Spring Cloud Gateway RequestRateLimiter GatewayFilter Factory](https://docs.spring.io/spring-cloud-gateway/reference/spring-cloud-gateway-server-webflux/gatewayfilter-factories/requestratelimiter-factory.html)
- [Spring Cloud CircuitBreaker Resilience4j Reference](https://docs.spring.io/spring-cloud-circuitbreaker/docs/current/reference/html/spring-cloud-circuitbreaker-resilience4j.html)
- [Resilience4j Getting Started](https://resilience4j.readme.io/docs/getting-started-3)
- [Quartz Documentation](https://www.quartz-scheduler.org/documentation/quartz-2.5.x/)
- [Spring Framework Scheduling Reference](https://docs.spring.io/spring-framework/reference/integration/scheduling.html)
- [XXL-JOB GitHub Repository](https://github.com/xuxueli/xxl-job)
- [Micrometer Documentation](https://docs.micrometer.io/micrometer/reference/)
- [Prometheus Overview](https://prometheus.io/docs/)
- [OpenTelemetry Spring Boot Starter](https://opentelemetry.io/docs/zero-code/java/spring-boot-starter/)
- [Jaeger Architecture](https://www.jaegertracing.io/docs/next-release-v2/architecture/)
- [Why Use Vault?](https://developer.hashicorp.com/vault/docs/vs)
- [Spring Vault Reference](https://docs.spring.io/spring-vault/reference/vault/vault.html)
- [Apache Seata Domain Model Overview](https://seata.apache.org/docs/next/dev/domain/overviewDomainModel/)
- [Apache Seata TCC Mode Analysis](https://seata.apache.org/blog/seata-tcc/)

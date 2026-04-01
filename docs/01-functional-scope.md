# 功能范围文档 / Functional Scope

## 1. 文档目标 / Document Goal

这个项目的目标，不是完整实现一家银行的全部业务，而是选择一组足够小、但足够典型的业务功能，来承载高性能、高并发、高可用、高安全要求下的系统设计与实现方式。  
The goal of this project is not to fully implement everything a real bank does. Instead, it is to choose a set of business capabilities that is small enough to stay teachable, yet representative enough to demonstrate system design and implementation patterns for high performance, high concurrency, high availability, and strong security.

因此，功能设计遵循两个原则：第一，业务逻辑尽量简单，避免业务复杂度掩盖技术重点；第二，每个功能都必须能对应至少一个清晰的系统设计学习点。  
For that reason, the functional design follows two principles: first, the business logic should stay simple so it does not overshadow the technical focus; second, each function must map to at least one clear system design concept that is worth learning.

## 2. 功能设计原则 / Functional Design Principles

业务功能只保留“最小可演示闭环”。一个功能是否值得进入项目，不看它像不像真实银行，而看它能不能帮助演示服务拆分、数据归属、幂等、并发控制、一致性、安全控制或可观测性。 
Business functions should be limited to the smallest complete demonstrable workflow. A function belongs in the project not because it makes the system look more like a real bank, but because it helps demonstrate service boundaries, data ownership, idempotency, concurrency control, consistency, security, or observability.

将业务功能点按照微服务设计的原则划分为不同的微服务，每个微服务有独立的数据库。微服务之间通过微服务之间主流的通信手段进行交互。  
Every business function should have a clear service owner. This is especially important for core data such as account balances, transaction states, risk decisions, and audit logs. You should always be able to answer who writes the data, who reads it, and who is only allowed to call into the owner.

功能规划优先考虑主流架构实践，而不是追求冷门方案。这个项目的设计默认优先使用当前主流的 Java 微服务技术栈，以及业界常见的设计模式和治理手段。  
The functional roadmap should prioritize mainstream architectural practice rather than niche ideas. By default, this project should favor the current mainstream Java microservice stack and the design patterns and governance techniques that are widely used in real systems.

## 3. 建议纳入项目的业务功能 / Recommended Business Functions

### 3.1 核心业务功能 / Core Business Functions

#### 3.1.1 用户登录验证 / User Login and Verification

用户登录验证建议被放入核心业务功能，而不是只作为一个纯技术组件来理解。原因是它直接决定了“谁可以进入系统、以什么身份进入、进入后能看到什么业务数据”，这对银行类系统来说本身就是业务入口。最小可演示能力建议包含用户名密码登录、登录失败处理、令牌签发、退出登录，以及可选的二次验证。  
User login and verification should be treated as a core business function rather than just a technical utility. The reason is simple: it directly defines who is allowed into the system, under what identity they enter, and what business data they can access afterward. In a banking-style system, that is a business entry point in its own right. The smallest useful version should include username-and-password login, failed-login handling, token issuance, logout, and optional second-factor verification.

这一功能域主要用于演示用户身份生命周期、会话或令牌管理、登录风控、账户锁定，以及用户视角下的安全控制。这里的重点不是把身份体系做复杂，而是让后续所有业务接口都建立在一个明确的用户身份基础上。  
This domain is mainly used to demonstrate user identity lifecycle management, session or token handling, login-time risk checks, account lockout, and security controls from the user’s point of view. The goal is not to build a complex identity platform, but to make sure that every business API later on is anchored to a clear user identity.

#### 3.1.2 账户管理 / Account Management

账户管理是整个项目的基础功能域，建议包含开户、账户查询、存款、取款、账户状态控制这几项最基础能力。这里不需要复杂的客户资料模型，也不需要完整的银行账户生命周期，只需要一套最小账户对象来承载余额、币种和状态。  
Account management should be the foundational business domain of the project. It should include the most basic capabilities: account creation, account lookup, deposit, withdrawal, and account status control. There is no need for a complex customer profile model or a full banking account lifecycle. A minimal account object that carries balance, currency, and status is enough.

这一功能域主要用于演示账户数据归属、余额并发更新、乐观锁或悲观锁策略、账户冻结，以及账户服务作为核心写服务的边界。  
This domain is mainly used to demonstrate data ownership, concurrent balance updates, optimistic or pessimistic locking strategies, account freezing, and the boundary of the account service as the authoritative write service.

#### 3.1.3 行内转账 / Internal Transfer

行内转账是最值得优先实现的交易功能。建议支持同币种账户之间的基础转账申请、转账查询、重复请求幂等处理，以及基础的成功与失败状态管理。  
Internal transfer is the most valuable transaction feature to implement first. It should support basic transfer requests between same-currency accounts, transfer lookup, idempotent handling of duplicate requests, and simple success and failure state management.

这一功能域可以很好地承载幂等、事务边界、流程编排、服务间调用、失败补偿和最终一致性等主题，是整个项目最核心的演示场景之一。  
This domain is an excellent vehicle for demonstrating idempotency, transaction boundaries, workflow orchestration, inter-service calls, failure compensation, and eventual consistency. It should be treated as one of the core demonstration scenarios in the entire project.

#### 3.1.4 外部平台转账 / External Platform Transfer

除了站内转账，还建议纳入“与外部平台发生资金交互”的业务能力。这里的外部平台包括其他银行，也包括购物平台、商户平台或清算平台。最小可演示能力可以先只支持转出申请、转账状态查询、渠道回调处理和失败重试。  
In addition to internal transfers, the project should also include a business capability for fund movements involving external platforms. These external platforms may include other banks, e-commerce platforms, merchant platforms, or clearing platforms. The smallest useful version only needs to support outbound transfer requests, transfer status lookup, channel callback handling, and retry on failure.

这个功能和站内转账的最大区别，在于资金处理不再完全受本系统控制。系统必须开始面对渠道接入、异步通知、第三方状态不一致、渠道超时、重复回调、对账修复等问题。  
What makes this different from internal transfer is that the full fund flow is no longer under this system’s control. The system now has to deal with channel integration, asynchronous notifications, third-party state mismatches, channel timeouts, duplicate callbacks, and reconciliation-based recovery.

它非常适合用来演示开放平台集成、适配器模式、状态机设计、最终一致性、出站请求幂等、入站回调幂等、渠道降级和补偿任务。对于“银行系统如何与外部世界交互”这个主题，它是必须纳入的核心业务之一。  
It is an excellent scenario for demonstrating open-platform integration, the adapter pattern, state-machine design, eventual consistency, outbound idempotency, inbound callback idempotency, channel degradation, and compensation jobs. If you want to show how a banking system interacts with external parties, this needs to be treated as one of the core business capabilities.

建议把它细分为两个子场景：第一类是跨行转账，重点体现银行到银行的资金流转；第二类是平台支付或平台出款，重点体现银行系统与购物平台、商户平台之间的交互。这样后续在服务设计上更容易抽象出统一的“外部渠道转账”模型。  
I would recommend splitting it into two sub-scenarios. The first is cross-bank transfer, which focuses on fund movement between banks. The second is platform payment or platform payout, which focuses on interactions between the banking system and e-commerce or merchant platforms. This makes it much easier to abstract a unified “external-channel transfer” model later in the service design.

#### 3.1.5 交易流水与账务记录 / Transaction History and Ledger Record

建议保留一层简化版交易流水，而不是一开始就做复杂总账。最小设计可以只是账户变动流水和转账单记录，用来表达“谁在什么时间做了什么变动”。  
You should keep a simplified transaction history layer instead of building a full general ledger at the beginning. The smallest useful design is usually an account activity history plus transfer orders, which is enough to show who changed what and when.

它的主要作用不是模拟真实金融会计系统，而是帮助演示查询分离、审计追踪、异步事件扩展和后续对账能力。  
Its purpose is not to simulate a real financial accounting system. Its main value is to support read/write separation, auditability, asynchronous event expansion, and future reconciliation scenarios.

#### 3.1.6 通知 / Notification

通知在这个项目里建议被提升到核心业务功能，而不是简单视为外围附属能力。原因是转账成功、转账失败、登录异常、风控拦截、人工处理结果等信息，本身就是用户和业务人员必须感知的业务输出。  
In this project, notifications should be elevated to a core business function rather than treated as a peripheral add-on. The reason is that events such as transfer success, transfer failure, abnormal login attempts, risk-control blocks, and manual handling results are themselves business outputs that users and operational staff need to receive.

最小可演示能力建议包含站内通知，后续可以扩展到短信、邮件或消息推送。它的主要学习价值在于展示主流程与通知流程的解耦、异步投递、模板化消息，以及消息失败后的重试与补偿。  
The smallest useful version should start with in-app notifications, with later extensions to SMS, email, or push messaging. Its main learning value lies in showing the decoupling of the main workflow from the notification workflow, asynchronous delivery, templated messaging, and retry or compensation when delivery fails.

### 3.2 横切业务能力 / Cross-Cutting Business Capabilities

#### 3.2.1 幂等控制 / Idempotency Control

对于账户入账、扣款、转账申请等接口，幂等控制应该被视为业务功能的一部分，而不是单纯的技术细节。建议把 `requestId` 或业务唯一流水号作为显式字段纳入接口设计。  
For operations such as credit, debit, and transfer submission, idempotency should be treated as part of the business design rather than a purely technical concern. A `requestId` or another business-level unique transaction identifier should be an explicit part of the API contract.

这一能力对高并发和高可靠接口至关重要，也是最适合通过示例项目讲清楚“重复请求不等于重复处理”的主题。  
This capability is essential for high-concurrency, high-reliability APIs, and it is one of the clearest ways to teach the principle that duplicate requests must not lead to duplicate processing.

#### 3.2.2 转账功能使用分布式事务 / Distributed Transactions for Transfer Workflows

对于只发生在单一账户服务内部的站内记账，优先使用本地事务即可；但对于跨服务、跨库、跨渠道的转账流程，项目中至少应设计一个“使用分布式事务模式”的示例场景。这里的重点不是强行把所有流程都做成分布式事务，而是要明确什么时候需要它、什么时候不需要它。  
For internal booking flows that stay entirely within a single account service, local transactions should remain the default choice. But for transfer workflows that span multiple services, databases, or external channels, the project should include at least one scenario that uses a distributed transaction pattern. The point is not to force every flow into a distributed transaction, but to make clear when one is needed and when it is not.

这一能力建议结合主流方案来演示，例如 Saga、TCC 或基于事务消息的最终一致性模式。学习重点包括事务边界识别、状态回滚或补偿、超时处理、异常恢复，以及“业务一致性”和“技术一致性”之间的取舍。  
This capability should be demonstrated using mainstream approaches such as Saga, TCC, or an eventual-consistency pattern built on transactional messaging. The learning focus should include identifying transaction boundaries, rollback or compensation, timeout handling, failure recovery, and the tradeoff between business consistency and technical consistency.

#### 3.2.3 转账失败重试与人工处理报告 / Retry and Operational Reporting for Failed Transfers

转账流程失败后，系统不能只把状态停留在失败。建议加入定时任务，对可重试的失败状态进行自动重试，并对多次重试仍失败的记录生成报告，交给业务人员或运营人员处理。  
When a transfer workflow fails, the system should not simply leave it in a failed state forever. A scheduled job should retry failures that are safe to retry, and for records that still fail after multiple attempts, it should generate a report for business or operations staff to handle manually.

这一能力非常适合演示失败分级、重试策略、死信思路、补偿任务、人工兜底流程，以及“系统自动化边界在哪里”这一现实问题。它也能很好地承接外部平台转账中的超时、渠道异常和状态不一致场景。  
This capability is a strong way to demonstrate failure classification, retry strategy, dead-letter thinking, compensation jobs, manual fallback processes, and the very practical question of where the boundary of automation should be. It also fits naturally with external-platform transfer scenarios involving timeouts, channel errors, and inconsistent states.

#### 3.2.4 审计日志 / Audit Logging

建议尽早纳入审计日志，至少记录关键操作的操作者、请求标识、对象标识、操作类型、时间和结果。这里不需要一开始就做复杂报表，但必须把留痕思想提前纳入系统设计。  
Audit logging should be introduced early. At a minimum, it should record the operator, request identifier, target object, action type, timestamp, and result for critical operations. There is no need for sophisticated reporting at the start, but the idea of traceability should be built into the design from the beginning.

这一能力主要用于演示安全要求、问题追溯、敏感操作记录，以及后续合规功能的扩展。  
This capability is mainly there to demonstrate security requirements, incident traceability, sensitive-operation tracking, and a foundation for later compliance-oriented features.

#### 3.2.5 认证与鉴权 / Authentication and Authorization

项目虽然以接口为主，但认证和鉴权不能后置得太晚。这里的重点不再是“用户怎么登录”，而是系统如何统一校验访问令牌、区分角色权限、保护内部接口，并为服务间调用建立可信身份。  
Even though the project is API-first, authentication and authorization should not be postponed too far. The focus here is no longer how a user logs in, but how the system consistently validates access tokens, differentiates roles and permissions, protects internal APIs, and establishes trusted identities for service-to-service calls.

这一功能域主要用于演示零信任边界、内部接口保护、敏感接口限制，以及后续审计和安全设计的基础。  
This domain is mainly used to demonstrate zero-trust boundaries, protection of internal APIs, restrictions on sensitive operations, and the security foundation required for auditing and other controls.

#### 3.2.6 风控校验 / Risk Control Check

建议做一个轻量版风控服务，不追求真实复杂策略，只保留例如单笔限额、黑名单账户、频率限制等基础规则。  
A lightweight risk-control service is worth adding. It does not need realistic or highly sophisticated policies. Basic rules such as per-transaction limits, blocked accounts, and frequency limits are enough.

它的意义在于把“业务处理前先做决策”这个模式体现出来，并为后续接入 AI 风控辅助创造清晰接口。  
Its value lies in demonstrating the pattern of making a decision before executing a business action, while also creating a clean interface for future AI-assisted risk review.

#### 3.2.7 系统日志中心化处理 / Centralized Logging

系统日志中心化处理建议作为横切能力纳入，而不是留到运维阶段再补。目标是让开发人员能够在统一入口查询网关日志、应用日志、异常日志和链路相关日志，而不是登录每台实例逐个排查。  
Centralized logging should be included as a cross-cutting capability rather than postponed until an operations phase. The goal is to let developers query gateway logs, application logs, exception logs, and trace-related logs from a single entry point instead of logging into individual instances one by one.

这一能力适合结合主流方案来演示，例如 ELK、EFK 或 OpenSearch 体系。学习重点包括统一日志格式、请求链路标识、日志采集、索引检索、错误聚合，以及如何让故障排查和 AI 辅助诊断建立在统一日志基础之上。  
This capability is well suited to demonstration through mainstream solutions such as ELK, EFK, or an OpenSearch-based stack. The learning focus should include standardized log formats, request correlation IDs, log collection, indexed search, error aggregation, and how both troubleshooting and AI-assisted diagnosis can be built on top of a unified log foundation.

### 3.3 扩展业务功能 / Extended Business Functions

#### 3.3.1 对账 / Reconciliation

对账非常适合用来演示最终一致性和异步修复，但不建议作为第一阶段核心功能。等转账、流水和事件机制稳定后，再加入日终对账或任务式对账，会更合理。  
Reconciliation is a great way to demonstrate eventual consistency and asynchronous correction, but it should not be a phase-one core feature. It makes more sense to add it after transfers, transaction history, and the event mechanism are already stable.

这一功能域适合展示批处理任务、差异发现、补偿机制和运维可观测性。  
This domain is well suited for demonstrating batch processing, discrepancy detection, compensation workflows, and operational observability.

#### 3.3.2 授信与贷款 / Credit and Loan

授信和贷款是很好的金融业务题材，但对当前项目来说过重。除非后续明确要学习审批流、计息、分期和复杂风控，否则不建议过早纳入。  
Credit and lending are strong financial use cases, but they are too heavy for the current scope. Unless you explicitly want to learn approval workflows, interest calculation, installment handling, and more complex risk logic later on, they should not be introduced too early.




## 4. AI 相关功能建议 / AI-Related Functional Suggestions

随着用户登录验证、通知、分布式事务、失败重试报告和日志中心化这些功能被纳入范围，AI 的定位也需要重新明确。这里的 AI 不应该是一个孤立的聊天能力，而应该围绕“风险决策、测试生成、故障诊断、人工处理辅助”这几类高价值场景落地。  
Now that user login and verification, notifications, distributed transactions, failed-transfer retry reports, and centralized logging are all in scope, the role of AI needs to be reframed as well. AI should not exist here as a standalone chat feature. It should be applied to high-value scenarios such as risk decision support, test generation, incident diagnosis, and manual-operations assistance.

### 4.1 AI 风控辅助与解释 / AI-Assisted Risk Review and Explanation

最适合最先落地的 AI 能力，仍然是风控辅助，但它的覆盖面不应只限于转账。现在它应该同时覆盖登录异常识别、行内转账风险、外部平台转账风险，以及命中规则后的解释输出。系统可以先由规则引擎给出初步结论，再由 AI 输出“为什么被拦截、还有哪些风险信号、是否建议人工复核”。  
The best AI capability to introduce first is still risk assistance, but it should no longer be limited to transfers alone. It should now cover abnormal login detection, internal-transfer risk, external-platform transfer risk, and explainable output when a rule is triggered. The system can let a rules engine make the initial decision, and then have AI explain why the request was blocked, what additional risk signals are present, and whether manual review is recommended.

这一能力的学习价值在于，它把“规则决策”和“智能解释”拆成两层。规则层保证系统可控，AI 层提升可读性、分析深度和人工处理效率。对金融系统来说，这比单纯让 AI 直接做最终决策更合理，也更符合演示项目的可验证目标。  
The learning value of this capability is that it separates rule-based decision making from intelligent explanation. The rules layer keeps the system controlled and predictable, while the AI layer improves readability, analytical depth, and manual-handling efficiency. For a financial system, this is much more reasonable than letting AI make the final decision on its own, and it also better fits the verifiable nature of a learning project.

### 4.2 AI 测试生成与异常场景补全 / AI Test Generation and Failure-Scenario Expansion

在当前功能范围下，AI 生成测试的价值比过去更高，因为测试点已经明显增加了。除了常规接口测试，AI 还可以重点生成登录失败、权限不足、重复请求、外部渠道超时、重复回调、分布式事务补偿、失败重试任务、通知投递失败等场景的测试样例。  
Given the current scope, AI-driven test generation is even more valuable than before because the number of important scenarios has grown significantly. Beyond standard API tests, AI can now generate targeted cases for failed login, insufficient permissions, duplicate requests, external-channel timeouts, duplicate callbacks, distributed-transaction compensation, failed-transfer retry jobs, and notification delivery failures.

这一能力特别适合放在接口文档和需求文档已经比较稳定之后使用。它的目标不是替代人工思考测试设计，而是帮助你快速覆盖大量边界条件和回归路径，尤其适合这种以系统设计演示为主的项目。  
This capability works best once the API contracts and requirements documents have stabilized. Its purpose is not to replace human thinking in test design, but to help you rapidly cover a large number of edge cases and regression paths, which is especially useful in a project that is meant to demonstrate system design ideas.

### 4.3 AI 故障排查与日志分析 / AI Incident Diagnosis and Log Analysis

既然系统日志中心化处理已经进入范围，AI 辅助故障排查就变得更加自然。建议让 AI 消费统一的日志、错误码、链路标识、失败重试记录和渠道响应信息，先输出初步诊断，再由开发人员确认。  
Now that centralized logging is part of the scope, AI-assisted incident diagnosis becomes much more natural. AI should be allowed to consume unified logs, error codes, trace identifiers, retry records, and channel responses, then produce an initial diagnosis for developers to verify.

这一能力非常适合演示“AI 建立在可观测性基础设施之上”的思路。没有统一日志和统一上下文，AI 的诊断容易变成猜测；有了集中化日志、链路标识和标准化错误信息，AI 才更可能给出高质量的初步定位建议。  
This is a strong example of the idea that AI should be built on top of observability infrastructure. Without unified logs and shared context, AI diagnosis easily turns into guessing. With centralized logging, trace identifiers, and standardized error information, AI is much more likely to produce useful first-pass diagnostics.

### 4.4 AI 人工处理辅助 / AI Support for Manual Operations

新增的“失败重试与人工处理报告”也很适合引入 AI。对于重试多次仍失败的转账记录，AI 可以帮助归类失败原因、总结共同特征、生成处理建议，甚至根据规则模板为业务人员整理优先级。  
The new “retry and manual-handling report” capability is also a strong fit for AI. For transfer records that still fail after multiple retries, AI can help classify failure reasons, summarize common patterns, generate suggested actions, and even organize priorities for operations staff based on predefined rules.

这一能力的意义在于，AI 不仅参与研发效率提升，也参与业务处理效率提升。这样它就不是一个纯开发辅助工具，而是能与银行运营流程直接结合的系统能力。  
The significance of this capability is that AI is not only improving engineering productivity, but also helping operational workflows. That makes it more than a developer tool. It becomes a system capability that can directly support banking-style operational processes.

## 5. 推荐的功能优先级 / Recommended Functional Priority

基于现在的功能范围，项目的阶段划分应该更强调“先打通核心闭环，再接入外部世界，最后做治理和 AI 增强”。如果一开始就把外部平台转账、分布式事务、集中日志和 AI 同时拉进来，项目会迅速失去学习节奏。  
Given the current scope, the project should be staged around a simple principle: first build the core closed-loop flow, then connect to the outside world, and only after that add governance and AI enhancement. If external-platform transfers, distributed transactions, centralized logging, and AI are all introduced at once, the project will lose its learning rhythm very quickly.

第一阶段建议完成用户登录验证、账户管理、行内转账、交易流水、幂等控制和统一异常处理。这个阶段的目标不是“做完整银行系统”，而是先把系统入口、账户写模型、基础交易流和高并发下最关键的正确性问题跑通。  
Phase one should cover user login and verification, account management, internal transfers, transaction history, idempotency control, and unified exception handling. The goal at this stage is not to build a complete banking system, but to get the system entry flow, the account write model, the foundational transaction flow, and the most important correctness concerns under concurrency working first.

第二阶段建议加入统一认证鉴权、审计日志、轻量风控、通知，以及外部平台转账的最小闭环。这个阶段的目标是让系统开始面对真实金融系统常见的约束条件，也就是身份控制、行为留痕、风险决策、用户触达，以及外部渠道依赖。  
Phase two should add unified authentication and authorization, audit logging, lightweight risk control, notifications, and the smallest complete external-platform transfer flow. The goal here is to make the system face the kinds of constraints real financial systems commonly deal with: identity control, traceability, risk decision making, user-facing communication, and dependency on external channels.

第三阶段建议加入 Redis、消息队列、分布式事务示例、失败重试任务与人工处理报告、对账，以及系统日志中心化处理。这个阶段不再只是补功能，而是开始系统化展示高可用、高并发和运维治理能力。  
Phase three should add Redis, a message queue, a distributed-transaction example, failed-transfer retry jobs with manual-handling reports, reconciliation, and centralized logging. At this stage, the focus is no longer just adding features. It becomes a structured demonstration of high availability, high concurrency, and operational governance.

第四阶段再逐步引入 AI 风控辅助、AI 测试生成、AI 故障排查和 AI 人工处理辅助。这样做的好处是，AI 建立在已经存在的风控规则、测试文档、日志中心和人工处理流程之上，既更自然，也更容易验证效果。  
Only in phase four should you gradually introduce AI-assisted risk review, AI-generated tests, AI-supported incident diagnosis, and AI support for manual operations. The advantage of this sequence is that AI is built on top of already existing risk rules, test documentation, centralized logs, and manual-handling workflows, which makes it both more natural and easier to validate.

## 6. 当前建议的功能清单 / Current Recommended Function List

基于当前项目目标，建议正式纳入的核心业务功能包括：用户登录验证、账户管理、账户状态控制、行内转账、外部平台转账、交易流水与账务记录、转账状态查询，以及通知。  
Given the current goals of the project, the recommended core business functions are user login and verification, account management, account status control, internal transfers, external-platform transfers, transaction history and ledger records, transfer status lookup, and notifications.

建议正式纳入的横切业务能力包括：幂等控制、分布式事务示例、失败重试与人工处理报告、统一异常处理、认证鉴权、审计日志、轻量风控、系统日志中心化处理，以及后续为高并发和异步解耦准备的 Redis、消息队列和对账机制。  
The recommended cross-cutting business capabilities are idempotency control, a distributed-transaction example, failed-transfer retries with manual-handling reports, unified exception handling, authentication and authorization, audit logging, lightweight risk control, centralized logging, and later-stage Redis, messaging, and reconciliation mechanisms for high concurrency and asynchronous decoupling.

建议正式纳入的 AI 相关能力包括：AI 风控辅助与解释、AI 测试生成与异常场景补全、AI 故障排查与日志分析，以及 AI 人工处理辅助。这样 AI 的作用能够同时覆盖业务决策、工程质量、运维诊断和运营支持。  
The recommended AI-related capabilities are AI-assisted risk review and explanation, AI test generation and failure-scenario expansion, AI incident diagnosis and log analysis, and AI support for manual operations. This lets AI contribute across business decision support, engineering quality, operational diagnosis, and support workflows.

明确不建议在早期纳入的功能包括：复杂客户画像、跨境支付、计息规则引擎、贷款审批流、信用评分体系和完整总账系统。它们都很有价值，但对当前阶段的学习性价比不高，而且会明显拉高项目复杂度。  
The following should stay out of scope in the early stages: complex customer profiling, cross-border payments, interest calculation engines, loan approval workflows, credit scoring systems, and a full general ledger. All of them are valuable topics, but they do not offer a strong learning return at the current stage and would raise the project’s complexity significantly.

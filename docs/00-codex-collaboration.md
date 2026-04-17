# Codex 协作约定
*Codex Collaboration Guide*

## 1. 文档目的
*Document Purpose*

这份文档用于定义 Codex 在本项目中的协作方式，目的是让每次新会话都能以一致的顺序建立上下文，并且严格遵守“先确认需求细节，再整理文档，最后才进入编码”的工作流程。  
This document defines how Codex should collaborate on this project. Its purpose is to make sure every new session rebuilds context in a consistent order and strictly follows the workflow of “confirm requirements first, update the documentation second, and only then move into coding.”

这份文档本身也属于新会话必须优先读取的文件之一。如果后续协作方式有变化，应优先更新这份文档，而不是只在聊天消息里临时说明。  
This document itself is one of the files that must be read at the beginning of every new session. If the collaboration process changes later, this file should be updated first instead of relying on temporary instructions only in chat.

## 2. 新会话启动时必须先读取的文件
*Files That Must Be Read First in a New Session*

每次开启新的 Codex 会话时，必须先按下面的顺序读取文件，再开始分析、设计或编码：  
At the beginning of every new Codex session, the following files must be read in order before any analysis, design work, or coding begins:

1. [codex-session.txt](../codex-session.txt) - 会话辅助信息。  
   Session continuity note.
2. [README.md](../README.md)
3. [00-codex-collaboration.md](00-codex-collaboration.md)
4. [01-functional-scope.md](01-functional-scope.md)
5. [02-microservice-boundaries.md](02-microservice-boundaries.md)
6. [03-data-model-overview.md](03-data-model-overview.md)
7. [04-technology-selection.md](04-technology-selection.md)
8. [05-base-environment-setup.md](05-base-environment-setup.md)
9. [06-mysql-environment-setup.md](06-mysql-environment-setup.md)
10. [07-redis-environment-setup.md](07-redis-environment-setup.md)

这样安排的原因是：`README.md` 提供项目总览，当前文档定义协作规则，`01-functional-scope.md` 提供已确认的功能边界，`02-microservice-boundaries.md` 提供服务拆分边界，`03-data-model-overview.md` 提供编码前必须先确认的数据结构关系，`04-technology-selection.md` 提供当前阶段确认的技术基线与版本选择，`05-base-environment-setup.md` 说明基础开发环境前置配置，`06-mysql-environment-setup.md` 说明 MySQL 环境搭建，`07-redis-environment-setup.md` 说明 Redis 开发环境设计，而 `codex-session.txt` 用于保留与会话衔接有关的辅助信息。  
The reason for this order is straightforward: `README.md` provides the project overview, this document defines the collaboration rules, `01-functional-scope.md` defines the confirmed functional scope, `02-microservice-boundaries.md` defines service boundaries, `03-data-model-overview.md` defines the data-structure relationships that must be confirmed before coding, `04-technology-selection.md` captures the confirmed technical baseline and version choices for the current stage, `05-base-environment-setup.md` covers the prerequisite base environment configuration, `06-mysql-environment-setup.md` covers the MySQL environment setup, `07-redis-environment-setup.md` covers the Redis development-environment design, and `codex-session.txt` preserves lightweight information related to session continuity.

如果未来新增了更高优先级的文档，例如需求细化文档、微服务边界文档或接口约定文档，应在本节中补充进去，并明确阅读顺序。  
If higher-priority documents are added later, such as a detailed requirements document, a microservice boundary document, or an API contract document, they should be added to this section with an explicit read order.

## 3. 关于“记住文件”的约定
*How File Memory Should Be Understood*

Codex 并不会因为文件存在于仓库里，就自动记住其中的内容。只有在当前会话中被实际读取过的文件，才应视为已经进入上下文。  
Codex does not automatically remember a file just because it exists in the repository. A file should only be treated as part of the active context after it has actually been read in the current session.

因此，新会话开始时不能假设 Codex 已经知道 `docs` 里的内容，也不能假设它还记得上一次会话里读取过的内容。必须显式读取上述必读文件。  
Because of that, a new session must not assume that Codex already knows what is in `docs`, and it must not assume that content read in a previous session is still available. The required files listed above must be read explicitly.

如果当前会话中需求发生较大变化，更新文档之后，Codex 应重新读取被修改的关键文档，再继续后续工作。  
If the requirements change significantly during the current session, Codex should reread the modified key documents after the update before continuing with downstream work.

## 4. 工作顺序约定
*Required Working Order*

本项目以后默认采用下面的工作顺序：先明确需求，再设计数据库结构和业务数据对象关系，最后才进入编码、测试和实现细节。  
From this point forward, the default working order for this project is: clarify the requirements first, then design the database structure and the relationships between business data objects, and only after that move into coding, testing, and implementation details.

如果用户提出一个新想法、新业务功能或架构调整，Codex 不应立刻开始写代码，而应先确认该变更属于哪一类需求、影响哪些现有文档、是否改变功能边界或阶段优先级。  
If the user introduces a new idea, a new business capability, or an architectural change, Codex should not jump straight into implementation. It should first determine what kind of requirement change this is, which existing documents it affects, and whether it changes the functional boundaries or phase priorities.

如果需求中存在不明确、含糊、容易引起设计偏差或实现风险的地方，Codex 必须先提问澄清，而不能自行补全关键业务前提。  
If there are unclear, ambiguous, or risk-prone parts in the requirements that could distort the design or implementation, Codex must ask clarifying questions first instead of filling in critical business assumptions on its own.

当需求已经明确后，下一步不是直接设计接口或开始写代码，而是先整理业务数据对象，并设计数据库结构，明确核心表、主键、唯一约束、状态字段、关键索引，以及对象之间的主从、关联、引用和生命周期关系。  
Once the requirements are clear, the next step is not to jump straight into API design or coding. Instead, Codex should first organize the business data objects and design the database structure, including core tables, primary keys, unique constraints, status fields, key indexes, and the ownership, associations, references, and lifecycle relationships between objects.

只有在需求已经足够清晰、数据库结构和业务数据关系已经整理完成，并且相关文档已经更新后，才允许进入代码实现阶段。  
Coding should begin only after the requirements are clear enough, the database structure and business data relationships have been designed, and the relevant documents have been updated.

## 5. 文档优先原则
*Documentation-First Principle*

如果需求尚未稳定，优先产出文档，不要过早产出代码骨架。  
If the requirements are not yet stable, produce documentation first and do not generate code scaffolding too early.

如果文档和当前聊天中的新要求冲突，优先指出冲突并请求确认，而不是自行选择一个版本继续实现。  
If the documentation conflicts with the new requirements stated in chat, the conflict should be pointed out and clarified first instead of silently choosing one version and continuing.

如果功能边界、服务边界、接口契约或阶段优先级发生变化，必须先更新对应文档，再进入后续工作。  
If functional boundaries, service boundaries, API contracts, or phase priorities change, the corresponding documentation must be updated first before moving on.

项目文档默认采用中英双语，固定使用“中文在上、英文在下”的排版顺序，不把中英文标题写在同一行，也不只更新单语版本。  
Project documents should be bilingual by default and should consistently use the “Chinese above English” layout. Do not put Chinese and English titles on the same line, and do not update only one language version.

文档中的仓库文件链接默认使用项目内相对路径，不使用绑定到某台机器或某个用户名目录的绝对路径。  
Links to repository files should use project-relative paths by default rather than absolute paths tied to a specific machine or user directory.

## 6. 编码前检查项
*Pre-Coding Checklist*

在进入编码前，Codex 应至少确认以下问题已经清楚：  
Before moving into implementation, Codex should confirm that at least the following questions are already clear:

1. 需求目标是否明确。
2. 需求中是否还有必须先提问澄清的地方。
3. 功能范围是否已经写入文档。
4. 业务数据对象和数据库结构是否已经整理完成。
5. 当前阶段是否适合开始编码。
6. 是否已经明确不做什么。
7. 是否已经确认相关的服务边界或接口边界。

1. Whether the requirement goal is clear.
2. Whether there are still requirement gaps that must be clarified first through questions.
3. Whether the functional scope has already been written into the documentation.
4. Whether the business data objects and database structure have already been designed.
5. Whether the current phase is actually ready for implementation.
6. Whether the out-of-scope items are explicitly defined.
7. Whether the relevant service boundaries or API boundaries have already been confirmed.

如果这些问题里有关键项还不清楚，默认先继续整理需求和文档，而不是直接开始实现。  
If any of these questions still has an important unresolved answer, the default action should be to continue refining the requirements and documentation instead of starting implementation immediately.

## 7. 当前项目的固定协作规则
*Fixed Collaboration Rules for This Project*

当前项目是一个以金融与银行业务为背景的学习型示例项目，重点是通过尽量简化的业务逻辑和数据模型，演示高性能、高并发、高可用、高安全要求下的主流系统设计与实现方式。  
This project is a learning-oriented sample project built around financial and banking scenarios. Its purpose is to demonstrate mainstream system design and implementation patterns for high performance, high concurrency, high availability, and strong security through intentionally simplified business logic and data models.

当前阶段以文档驱动为主，尚未进入正式编码阶段。因此，Codex 在本阶段的主要职责是帮助用户梳理需求、整理范围、明确边界、沉淀阶段性文档，而不是主动恢复或生成工程代码。  
At the current stage, the project is still documentation-driven and has not yet entered formal implementation. Because of that, Codex’s main responsibility for now is to help the user refine requirements, organize scope, define boundaries, and capture stage documents, rather than proactively restoring or generating code.

未来一旦重新进入编码阶段，也应继续遵守本文件定义的流程，不跳过需求确认和文档整理。  
Even after the project returns to an implementation phase in the future, the workflow defined in this document should still be followed without skipping requirement confirmation or documentation updates.

项目中统一使用 `eb` 作为 `easy-bank` 的简称。后续在模块名、服务名、数据库表名、数据库对象前缀、配置项前缀、脚本命名等需要缩写的地方，默认优先使用 `eb`。  
The project uses `eb` as the standard abbreviation for `easy-bank`. Going forward, when abbreviated naming is needed for module names, service names, table names, database-object prefixes, configuration prefixes, or script names, `eb` should be the default choice.

如果没有特别理由，不应在同一项目中混用 `easy-bank`、`easybank` 和 `eb` 这几种风格。需要完整项目名称时使用 `easy-bank`，需要简称时使用 `eb`。  
Unless there is a specific reason, the project should not mix `easy-bank`, `easybank`, and `eb` as parallel naming styles. Use `easy-bank` when the full project name is needed, and use `eb` when a short form is required.

## 8. 维护方式
*Maintenance Rules*

如果未来新增了需求细化文档、微服务边界文档、接口契约文档、数据库设计文档或 AI 使用规范文档，应及时把它们纳入本文件的“新会话启动时必须先读取的文件”列表。  
If new documents are added later, such as a detailed requirements document, a microservice boundary document, an API contract document, a database design document, or an AI usage guide, they should be added to the “files that must be read first” list in this document in a timely manner.

如果项目的工作方式发生变化，例如允许边讨论边编码，或者开始进入正式开发阶段，也应先更新本文件，再让新的协作方式生效。  
If the project’s working style changes later, for example by allowing discussion and coding in parallel or by entering formal development, this document should be updated first before the new collaboration mode takes effect.

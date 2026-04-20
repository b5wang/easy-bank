# Redis 环境搭建
*Redis Environment Setup*

## 1. 文档目标
*Document Goal*

这份文档用于定义 `easy-bank` 项目的 Redis 环境搭建方案。当前阶段重点是开发环境，也就是在已经完成 [05-base-environment-setup.md](05-base-environment-setup.md) 的前提下，为项目设计一套运行在 `minikube` 内的 Redis 开发环境，满足三实例运行、主从切换模拟、数据持久化、低资源高性能配置、集群内固定访问方式，以及容器外可访问等要求。  
This document defines the Redis environment setup for the `easy-bank` project. At the current stage, the focus is the development environment. Based on a completed [05-base-environment-setup.md](05-base-environment-setup.md), the goal is to design a Redis development environment running inside `minikube` that satisfies three-instance deployment, master-replica failover simulation, persistence, low-resource high-performance tuning, fixed in-cluster access, and access from outside the containers.

当前文档现在同时记录 Redis 开发环境的设计约束、脚本目录、Kubernetes 清单和执行步骤。后续如果脚本或参数发生变化，应优先更新本文件。  
This document now records the Redis development-environment design constraints, script directories, Kubernetes manifests, and execution steps together. If the scripts or parameters change later, this document should be updated first.

## 2. 环境分层
*Environment Layers*

### 2.1 开发环境
*Development Environment*

开发环境中的 Redis 运行在 `minikube` 内部，采用 `Redis Sentinel` 模式，提供集群内固定访问方式和本机开发访问方式。  
In the development environment, Redis runs inside `minikube`, uses `Redis Sentinel` mode, and provides both a fixed in-cluster access method and a local developer access method.

### 2.2 测试环境
*Testing Environment*

本节后续讨论。  
This section will be discussed later.

### 2.3 生产环境
*Production Environment*

本节后续讨论。  
This section will be discussed later.

## 3. 开发环境
*Development Environment*

### 3.1 设计目标与边界
*Design Goals and Boundaries*

当前开发环境 Redis 设计遵循以下目标和边界：  
The current Redis development-environment design follows the following goals and boundaries:

- 必须运行 `3` 个 Redis 数据实例。  
  It must run `3` Redis data instances.
- 必须具备主从切换模拟能力。  
  It must be able to simulate master-replica failover.
- 必须保留数据持久化能力。  
  It must preserve data-persistence capability.
- 必须提供集群内固定访问方式。  
  It must provide a fixed in-cluster access method.
- 必须提供容器外本地开发访问方式。  
  It must provide a local development access method from outside the containers.
- Redis 不仅承担纯缓存，也承担幂等键、分布式锁、短期状态记录等不应被随意淘汰的数据。  
  Redis is not only used for pure caching, but also for idempotency keys, distributed locks, and short-lived state records that should not be evicted casually.
- 当前开发环境的目标是模拟 Redis 角色高可用，而不是模拟真正的多机器基础设施高可用。  
  The current development environment is intended to simulate Redis role-level high availability, not true multi-machine infrastructure high availability.

最后这一点需要特别说明：`minikube` 开发环境通常仍然是单节点 Kubernetes，因此这里模拟的是“Redis master/replica + Sentinel 的逻辑切换能力”，而不是生产意义上的节点级高可用。  
The final point needs special clarification: the `minikube` development environment is still typically a single-node Kubernetes cluster, so what is being simulated here is the logical switching capability of “Redis master/replica + Sentinel,” not production-grade node-level high availability.

### 3.2 架构选型结论
*Architecture Decision*

开发环境 Redis 正式采用 `Redis Sentinel` 模式，不采用 `Redis Cluster` 模式。  
The development Redis environment formally adopts `Redis Sentinel` mode and does not use `Redis Cluster` mode.

这样选择的原因如下：  
The reasons for this decision are as follows:

- 你已经明确要求“只使用 `3` 个 Redis 实例”，而 `Redis Cluster` 若要合理演示高可用，通常至少需要 `3 master + 3 replica` 共 `6` 个节点。  
  You have explicitly required “only `3` Redis instances,” while `Redis Cluster` generally needs at least `3 masters + 3 replicas`, a total of `6` nodes, to demonstrate high availability properly.
- `Redis Sentinel` 更适合当前这种 `1 master + 2 replica` 的三实例开发环境。  
  `Redis Sentinel` is more suitable for the current three-instance development environment of `1 master + 2 replicas`.
- 当前内部访问方式已经明确采用“`Sentinel service + master name`”的方式，这与 Sentinel 模式天然匹配。  
  The internal access method has already been decided as “`Sentinel service + master name`,” which naturally matches Sentinel mode.

因此，当前开发环境的正式拓扑是：`3` 个 Redis 数据实例 + `3` 个 Sentinel 进程，其中 Sentinel 进程跟随各自 Redis Pod 共同部署。  
Therefore, the formal topology of the current development environment is: `3` Redis data instances + `3` Sentinel processes, where each Sentinel process is deployed together with its corresponding Redis Pod.

### 3.3 目标拓扑与固定约束
*Target Topology and Fixed Constraints*

开发环境 Redis 固定采用以下拓扑与约束：  
The Redis development environment uses the following fixed topology and constraints:

- Redis 版本基线采用 [04-technology-selection.md](04-technology-selection.md) 已确认的 `Redis Open Source 8.6.0`。  
  The Redis version baseline uses `Redis Open Source 8.6.0`, as already confirmed in [04-technology-selection.md](04-technology-selection.md).
- Kubernetes namespace 固定为 `easy-bank-dev`。  
  The Kubernetes namespace is fixed as `easy-bank-dev`.
- Redis 数据实例使用 `StatefulSet`，名称固定为 `eb-redis`。  
  Redis data instances use a `StatefulSet`, fixed as `eb-redis`.
- 初始 Pod 名称固定为 `eb-redis-0`、`eb-redis-1`、`eb-redis-2`。  
  The initial Pod names are fixed as `eb-redis-0`, `eb-redis-1`, and `eb-redis-2`.
- 初始角色固定为：`eb-redis-0` 为 master，`eb-redis-1` 和 `eb-redis-2` 为 replica。  
  The initial roles are fixed as: `eb-redis-0` is the master, while `eb-redis-1` and `eb-redis-2` are replicas.
- Sentinel 逻辑主节点名称固定为 `ebmaster`。  
  The Sentinel logical master name is fixed as `ebmaster`.
- 每个 Redis Pod 内包含两个容器：一个 `redis` 容器，一个 `sentinel` 容器。  
  Each Redis Pod contains two containers: one `redis` container and one `sentinel` container.

当前阶段约定的固定服务名和端口如下：  
The current fixed service names and ports are defined as follows:

- `eb-redis-headless.easy-bank-dev.svc.cluster.local:6379`  
  Headless Service，用于 StatefulSet Pod 稳定 DNS、主从复制和运维排查。  
  Headless Service for stable StatefulSet Pod DNS, replication, and operational troubleshooting.
- `eb-redis-sentinel.easy-bank-dev.svc.cluster.local:26379`  
  ClusterIP Service，用于项目内部微服务通过 Sentinel 访问当前 master。  
  ClusterIP Service used by internal project microservices to access the current master through Sentinel.

这里明确不再设计一个“永远固定指向当前 master 的普通 Redis Service”。  
It is explicitly decided not to design an ordinary Redis Service that always points to the current master.

原因是当前项目已经确认内部访问方式采用 `Sentinel service + master name`，因此真正稳定的固定入口应当是 Sentinel，而不是假装固定不变的 master 直连地址。  
The reason is that the project has already confirmed that internal access should use `Sentinel service + master name`, so the truly stable fixed entry point should be Sentinel rather than a pretend-fixed direct master address.

由于 Redis 副本和 Sentinel 在启动阶段就要解析 `eb-redis-0.eb-redis-headless...` 这类 Pod DNS，Headless Service 必须开启 `publishNotReadyAddresses: true`。否则在 Pod Ready 之前 DNS 记录可能尚未发布，导致 Redis 复制或 Sentinel 监控在启动阶段失败。  
Because Redis replicas and Sentinel need to resolve Pod DNS names such as `eb-redis-0.eb-redis-headless...` during startup, the Headless Service must enable `publishNotReadyAddresses: true`. Otherwise, the DNS records may not be published before the Pods become Ready, causing Redis replication or Sentinel monitoring to fail during bootstrap.

### 3.4 集群内访问方式
*In-Cluster Access Method*

项目内部微服务统一通过 `Sentinel service + master name` 访问 Redis。  
Project internal microservices consistently access Redis through `Sentinel service + master name`.

固定约定如下：  
The fixed convention is:

- Sentinel service host: `eb-redis-sentinel.easy-bank-dev.svc.cluster.local`
- Sentinel service port: `26379`
- Sentinel master name: `ebmaster`

这意味着后续在 Spring Boot 中，Redis 客户端应优先采用 Sentinel 配置，而不是把某个 Pod 地址写死为主节点地址。  
This means that later in Spring Boot, the Redis client should prefer Sentinel configuration rather than hardcoding a specific Pod address as the master address.

典型配置形态可参考：  
A typical configuration shape can be:

```yaml
spring:
  data:
    redis:
      password: ${REDIS_PASSWORD}
      sentinel:
        master: ebmaster
        nodes: eb-redis-sentinel.easy-bank-dev.svc.cluster.local:26379
```

如果后续某些运维脚本或排查动作需要直接访问具体 Redis Pod，也可以使用 Headless Service 下的稳定地址，例如：  
If some future operational scripts or troubleshooting actions need to access a specific Redis Pod directly, the stable addresses under the Headless Service can also be used, for example:

- `eb-redis-0.eb-redis-headless.easy-bank-dev.svc.cluster.local:6379`
- `eb-redis-1.eb-redis-headless.easy-bank-dev.svc.cluster.local:6379`
- `eb-redis-2.eb-redis-headless.easy-bank-dev.svc.cluster.local:6379`

但这些地址不应作为业务服务默认连接入口。  
But these addresses should not be used as the default connection entry points for business services.

### 3.5 容器外访问方式
*Access Method from Outside the Containers*

开发环境容器外访问 Redis 的标准方案固定为 `kubectl port-forward`。  
The standard solution for accessing Redis from outside the containers in development is fixed as `kubectl port-forward`.

这样选择的原因是：  
The reasons for this decision are:

- 在 `Windows 11 + WSL2 + Docker Desktop + minikube` 组合下，`port-forward` 的路径最稳定。  
  Under `Windows 11 + WSL2 + Docker Desktop + minikube`, the `port-forward` path is the most stable.
- 不需要额外开放 `NodePort`。  
  It does not require exposing an additional `NodePort`.
- 更适合作为开发环境的标准方案。  
  It is more suitable as the standard solution for the development environment.

开发环境对外访问应提供两种方式：  
The development environment should provide two external access methods:

#### 方式 A：转发 Sentinel 服务
*Method A: Forward the Sentinel Service*

这种方式的定位应调整为“Sentinel 状态查询与调试入口”，而不是宿主机 GUI 的标准 Redis 连接入口。  
This method should be positioned as a "Sentinel status inspection and troubleshooting entry point", not as the standard Redis connection entry point for host-side GUI tools.

建议的本机固定地址如下：  
The recommended fixed local address is:

- Host: `127.0.0.1`
- Port: `26379`

如果本地 GUI 工具或客户端明确使用 Sentinel 模式连接 Redis，可以参考下面这组参数；但在 `Windows 11 + WSL2 + minikube` 的宿主机环境中，这种方式通常并不能直接用于 GUI 数据访问。  
If a local GUI tool or client explicitly connects to Redis in Sentinel mode, it can refer to the following parameters; however, under a host environment such as `Windows 11 + WSL2 + minikube`, this method usually cannot be used directly for GUI data access.

| 参数项<br>Field | 应填写的值<br>Value to Fill |
| --- | --- |
| Host | `127.0.0.1` |
| Port | `26379` |
| Password | 留空。当前 Sentinel 本身不单独启用访问密码。<br>Leave blank. Sentinel itself does not currently enable a separate access password. |
| Redis Node Password | 执行 `01-create-secret.sh` 时使用的 `REDIS_PASSWORD`。默认值：`eb_redis_dev_123456`。<br>The `REDIS_PASSWORD` used when running `01-create-secret.sh`. Default: `eb_redis_dev_123456`. |
| Master Group Name | 仅当客户端明确使用 Sentinel 模式并要求填写该字段时，填写 `ebmaster`。<br>Fill in `ebmaster` only when the client is explicitly using Sentinel mode and requires this field. |

这里要特别区分“连接模式”和“两类密码”：  
Here it is especially important to distinguish both the connection mode and the two password types:

- 如果你连的是 `127.0.0.1:26379`，并且客户端启用了 Sentinel 模式，那么它连接的是 Sentinel 服务发现入口。此时有些客户端要求填写 `Master Group Name=ebmaster`，有些客户端会自动处理或根本不要求填写，按客户端实际行为为准。  
  If you connect to `127.0.0.1:26379` and the client is using Sentinel mode, it is connecting to the Sentinel service-discovery entry point. Some clients require `Master Group Name=ebmaster`, while others handle it automatically or do not ask for it at all. Follow the actual client behavior.
- 如果你连的是 `127.0.0.1:16379`，那么这是直连当前 master，不是 Sentinel 模式，`Master Group Name` 必须留空。  
  If you connect to `127.0.0.1:16379`, that is a direct connection to the current master, not Sentinel mode, so `Master Group Name` must be left blank.
- 当前 Sentinel 会返回 Kubernetes 集群内部地址，例如 `eb-redis-1.eb-redis-headless.easy-bank-dev.svc.cluster.local`。这些地址在集群内部可以解析，但宿主机上的 GUI 客户端通常不能解析，因此会报 `getaddrinfo ENOTFOUND`。  
  The current Sentinel returns Kubernetes internal addresses such as `eb-redis-1.eb-redis-headless.easy-bank-dev.svc.cluster.local`. These addresses are resolvable inside the cluster, but host-side GUI clients usually cannot resolve them, so they fail with `getaddrinfo ENOTFOUND`.
- 因此，宿主机侧访问 Redis 数据的标准方式应改为“方式 B：转发当前 master 的 6379”。方式 A 更适合执行 `SENTINEL masters`、`SENTINEL get-master-addr-by-name` 之类的查询或排查。  
  Therefore, the standard host-side method for accessing Redis data should be changed to "Method B: Forward the current master's 6379". Method A is more suitable for queries or troubleshooting such as `SENTINEL masters` or `SENTINEL get-master-addr-by-name`.

- `Password` 指的是连接 Sentinel 自身所需的密码。当前开发环境没有为 Sentinel 单独配置认证，所以这一项留空。  
  `Password` means the password required to connect to Sentinel itself. In the current development environment, Sentinel is not configured with separate authentication, so this field stays blank.
- `Redis Node Password` 指的是最终连接到 Redis master/replica 时使用的 Redis 密码。当前固定来源是 `REDIS_PASSWORD`。  
  `Redis Node Password` means the Redis password used when the client finally connects to the Redis master/replica nodes. In the current setup, it comes from `REDIS_PASSWORD`.

如果你在步骤 1 里自定义了 Redis 密码，例如：  
If you customized the Redis password in Step 1, for example:

```bash
export REDIS_PASSWORD='change_me_redis'
./env/dev/02_redis/minikube/01-create-secret.sh
```

那么这里的 `Redis Node Password` 也必须改成同一个值，而不再使用默认值 `eb_redis_dev_123456`。  
Then the `Redis Node Password` here must also be changed to that same value, instead of using the default `eb_redis_dev_123456`.

#### 方式 B：转发当前 master 的 6379
*Method B: Forward the Current Master on 6379*

为了兼容不支持 Sentinel 的本地客户端，可以额外提供一种“先通过 Sentinel 查询当前 master，再把当前 master 的 `6379` 转发到本机”的方式。  
To support local clients that do not understand Sentinel, an additional method can be provided: first query the current master through Sentinel, and then forward that master’s `6379` to the local machine.

建议的本机固定地址如下：  
The recommended fixed local address is:

- Host: `127.0.0.1`
- Port: `16379`

如果本地客户端不支持 Sentinel，而是直接连接当前 master，那么推荐按下面这组参数填写：  
If the local client does not support Sentinel and connects directly to the current master instead, use the following parameters:

| 参数项<br>Field | 应填写的值<br>Value to Fill |
| --- | --- |
| Host | `127.0.0.1` |
| Port | `16379` |
| Password | 执行 `01-create-secret.sh` 时使用的 `REDIS_PASSWORD`。默认值：`eb_redis_dev_123456`。<br>The `REDIS_PASSWORD` used when running `01-create-secret.sh`. Default: `eb_redis_dev_123456`. |
| Master Group Name | 不需要填写。直连当前 master 时不使用 Sentinel 组名。<br>Not needed. A Sentinel group name is not used when connecting directly to the current master. |

其中，宿主机侧访问 Redis 数据的标准方式应是方式 B；方式 A 主要用于 Sentinel 状态查询与排查。  
For host-side Redis data access, Method B should be the standard method; Method A is mainly for Sentinel status inspection and troubleshooting.

### 3.6 数据持久化设计
*Persistence Design*

开发环境 Redis 必须开启持久化。  
Persistence must be enabled for the Redis development environment.

当前设计采用以下策略：  
The current design adopts the following strategy:

- 每个 Redis Pod 单独挂载一个 PVC。  
  Each Redis Pod mounts its own PVC.
- Redis 数据目录统一使用 `/data`。  
  The Redis data directory consistently uses `/data`.
- 同时启用 `AOF` 和基础 `RDB` 快照。  
  Both `AOF` and baseline `RDB` snapshots are enabled.
- AOF 策略使用 `appendfsync everysec`。  
  The AOF policy uses `appendfsync everysec`.

这样设计的原因是：  
The reasons for this design are:

- 当前开发环境不仅缓存临时数据，还承担幂等键、锁和状态记录，因此不能把 Redis 设计成“可随时全丢”的纯内存缓存。  
  The current development environment not only caches temporary data, but also carries idempotency keys, locks, and state records, so Redis cannot be designed as a pure in-memory cache where data loss is always acceptable.
- `appendfsync everysec` 在开发环境下能在性能与持久化之间取得相对均衡。  
  `appendfsync everysec` offers a reasonable balance between performance and persistence for development.

当前建议每个 Redis 实例的 PVC 初始申请值为 `5Gi`。  
The current recommendation is to request `5Gi` of PVC storage for each Redis instance initially.

### 3.7 低资源高性能配置原则
*Low-Resource High-Performance Configuration Principles*

开发环境中的 Redis 既要节省资源，又不能因为缓存淘汰把幂等键、锁和状态记录错误丢失，因此当前正式策略是“限制资源上限 + 保留持久化 + 禁止自动淘汰”。  
The Redis development environment must save resources, but it also must not lose idempotency keys, locks, or state records because of automatic eviction. Therefore, the formal current strategy is “limit resources, keep persistence, and disable automatic eviction.”

当前建议的关键配置项如下：  
The current recommended key configuration items are:

| 配置项<br>Setting | 建议值<br>Recommended Value | 说明<br>Description |
| --- | --- | --- |
| `appendonly` | `yes` | 开启 AOF 持久化。<br>Enables AOF persistence. |
| `appendfsync` | `everysec` | 每秒刷盘一次，在开发环境下兼顾性能和可靠性。<br>Flushes once per second, balancing performance and reliability in development. |
| `aof-use-rdb-preamble` | `yes` | 加快 AOF 重写后的加载速度。<br>Speeds up loading after AOF rewrite. |
| `save` | `900 1`、`300 10`、`60 10000` | 保留基础 RDB 快照规则。<br>Keeps baseline RDB snapshot rules. |
| `maxmemory` | `256mb` | 控制单实例内存上限，适应低资源开发环境。<br>Caps per-instance memory for a low-resource development environment. |
| `maxmemory-policy` | `noeviction` | 禁止自动淘汰，避免幂等键、锁、状态记录被误删。<br>Disables automatic eviction so idempotency keys, locks, and state records are not removed unexpectedly. |
| `repl-diskless-sync` | `yes` | 主从全量同步时尽量减少磁盘中转。<br>Reduces disk staging during full replication sync. |
| `repl-diskless-sync-delay` | `1` | 缩短开发环境的同步等待时间。<br>Keeps sync delay short in development. |
| `tcp-keepalive` | `60` | 提升连接稳定性。<br>Improves connection stability. |
| `timeout` | `0` | 不主动断开空闲连接。<br>Does not proactively close idle connections. |

这里必须特别说明 `maxmemory-policy` 的选择逻辑：  
The choice of `maxmemory-policy` must be explained explicitly:

- 如果 Redis 只承担纯缓存，`allkeys-lru` 这类策略可能更适合。  
  If Redis only carried pure cache data, strategies such as `allkeys-lru` might be more suitable.
- 但当前项目已经明确 Redis 同时承载幂等键、锁和短期状态记录，这类数据不适合被自动淘汰。  
  But the current project has clearly decided that Redis also carries idempotency keys, locks, and short-lived state records, and those data types should not be evicted automatically.

因此，开发环境正式选择 `maxmemory-policy noeviction`。  
Therefore, the development environment formally chooses `maxmemory-policy noeviction`.

这也意味着：如果 Redis 内存达到上限，新的写入请求可能失败，应用层必须在后续实现里正确处理这类错误。  
This also means that if Redis reaches its memory limit, new write requests may fail, and the application layer must handle such errors correctly later in implementation.

### 3.8 Sentinel 配置原则
*Sentinel Configuration Principles*

当前建议的关键 Sentinel 配置如下：  
The current recommended key Sentinel settings are:

| 配置项<br>Setting | 建议值<br>Recommended Value | 说明<br>Description |
| --- | --- | --- |
| `sentinel monitor` | `ebmaster ... 6379 2` | 监控逻辑主节点 `ebmaster`，仲裁数使用 `2`。<br>Monitors the logical master `ebmaster` with a quorum of `2`. |
| `sentinel down-after-milliseconds` | `10000` | 主节点连续不可达 10 秒后判定为主观下线。<br>Marks the master subjectively down after 10 seconds of continuous unreachability. |
| `sentinel failover-timeout` | `60000` | 故障转移超时时间设为 60 秒。<br>Sets failover timeout to 60 seconds. |
| `sentinel parallel-syncs` | `1` | 故障切换后一次只让一个 replica 做并行同步。<br>Allows only one replica to resynchronize in parallel after failover. |

当前 Sentinel 的仲裁值明确采用 `2`，而不是 `1`。  
The Sentinel quorum is explicitly set to `2`, not `1`.

原因是：当前共有 `3` 个 Sentinel 进程，采用 `2` 更符合“至少多数同意才判定主节点故障”的思路，也更适合模拟真实环境的最小仲裁机制。  
The reason is that there are `3` Sentinel processes in total, and using `2` better matches the idea that at least a majority should agree before the master is treated as failed, which is also more suitable for simulating the minimum realistic quorum mechanism.

### 3.9 配置文件与挂载方式
*Configuration Files and Mount Strategy*

当前开发环境 Redis 已采用 `ConfigMap + Secret + StatefulSet` 的组合，不把关键配置硬编码进 Kubernetes `args`。  
The current Redis development environment already uses a combination of `ConfigMap + Secret + StatefulSet`, and it does not hardcode critical settings into Kubernetes `args`.

当前实现采用以下方式：  
The current implementation uses the following approach:

- Redis 和 Sentinel 的基础配置模板放入 `ConfigMap`。  
  Redis and Sentinel baseline configuration templates are stored in a `ConfigMap`.
- Redis 密码放入 `Secret`。  
  The Redis password is stored in a `Secret`.
- `StatefulSet` 先运行一个 `initContainer`，由它把模板渲染成实际运行用的配置文件。  
  The `StatefulSet` runs an `initContainer` first, and that container renders the templates into the actual runtime configuration files.

当前特别需要注意的是：Sentinel 运行过程中会重写自己的配置文件，因此它不能直接从只读 `ConfigMap` 挂载目录中运行。  
One especially important point is that Sentinel rewrites its own configuration file during runtime, so it cannot run directly from the read-only `ConfigMap` mount directory.

因此当前实现采用的路径是：  
Therefore, the current implementation uses the following path:

- `ConfigMap` 以只读方式挂载到 `/opt/redis/config-src/`。  
  The `ConfigMap` is mounted read-only at `/opt/redis/config-src/`.
- `initContainer` 读取模板文件并渲染出最终配置。  
  The `initContainer` reads the template files and renders the final configuration.
- Redis 和 Sentinel 的实际配置文件写入可写的数据目录。  
  The actual Redis and Sentinel configuration files are written into writable data storage.
- `redis` 容器直接以 `/data/conf/redis.conf` 启动。  
  The `redis` container starts directly with `/data/conf/redis.conf`.
- Sentinel 使用 `/data/sentinel/sentinel.conf`，这样它重写配置后仍能在 Pod 重启后保留状态。  
  Sentinel uses `/data/sentinel/sentinel.conf`, so its rewritten configuration can survive Pod restarts.

Redis 数据目录统一挂载到：  
The Redis data directory is mounted consistently to:

```text
/data
```

### 3.10 目录与脚本清单
*Directory and Script Inventory*

当前 Redis 开发环境相关文件统一放在：  
The current Redis development-environment files are all placed under:

```text
env/dev/02_redis/minikube/
```

当前文件结构如下：  
The current file structure is:

- `env/dev/02_redis/minikube/00-env.sh`  
  Redis 开发环境统一变量。  
  Shared variables for the Redis development environment.
- `env/dev/02_redis/minikube/01-create-secret.sh`  
  创建 Redis 密码等敏感信息。  
  Creates Redis passwords and other sensitive values.
- `env/dev/02_redis/minikube/02-deploy-redis.sh`  
  部署 Redis StatefulSet、Service、ConfigMap、PVC。  
  Deploys the Redis StatefulSet, Service, ConfigMap, and PVC.
- `env/dev/02_redis/minikube/03-port-forward-sentinel.sh`  
  打开本机到 Sentinel 的访问端口。  
  Opens a local access port to Sentinel.
- `env/dev/02_redis/minikube/04-port-forward-master.sh`  
  打开本机到当前 master 的访问端口。  
  Opens a local access port to the current master.
- `env/dev/02_redis/minikube/05-check-redis-status.sh`  
  检查 Redis 和 Sentinel 当前状态。  
  Checks the current Redis and Sentinel status.
- `env/dev/02_redis/minikube/06-query-sentinel.sh`  
  直接查询 Sentinel 的主节点、副本、Sentinel 节点和仲裁状态。  
  Queries Sentinel directly for master, replicas, Sentinel nodes, and quorum status.
- `env/dev/02_redis/minikube/k8s/`  
  存放 Redis 开发环境相关 Kubernetes 清单。  
  Stores Kubernetes manifests for the Redis development environment.
- `env/dev/02_redis/minikube/k8s/namespace.yaml`  
  Redis 开发环境 namespace 清单。  
  Redis development namespace manifest.
- `env/dev/02_redis/minikube/k8s/redis-configmap.yaml`  
  Redis 与 Sentinel 的基础配置模板，以及 `initContainer` 使用的渲染脚本。  
  Redis and Sentinel baseline configuration templates, plus the render script used by the `initContainer`.
- `env/dev/02_redis/minikube/k8s/redis-headless-service.yaml`  
  Redis Headless Service。  
  Redis Headless Service.
- `env/dev/02_redis/minikube/k8s/redis-sentinel-service.yaml`  
  Sentinel ClusterIP Service。  
  Sentinel ClusterIP Service.
- `env/dev/02_redis/minikube/k8s/redis-statefulset.yaml`  
  Redis StatefulSet 清单。  
  Redis StatefulSet manifest.

`env/dev/02_redis/minikube/00-env.sh` 与 MySQL 环境脚本的约定一致，不是单独执行的步骤脚本，而是供其它 Redis 脚本内部通过 `source` 自动加载的变量文件。  
`env/dev/02_redis/minikube/00-env.sh` follows the same convention as the MySQL environment scripts: it is not a standalone execution step, but a variable file automatically loaded via `source` by the other Redis scripts.

### 3.11 搭建步骤
*Setup Steps*

#### 步骤 1：创建 Redis Secret
*Step 1: Create the Redis Secret*

如果接受默认开发环境密码，可以直接执行：  
If the default development password is acceptable, run:

```bash
./env/dev/02_redis/minikube/01-create-secret.sh
```

如果希望自定义 Redis 密码，可以先导出环境变量，再执行：  
If a custom Redis password is preferred, export the environment variable first and then run:

```bash
export REDIS_PASSWORD='change_me_redis'
./env/dev/02_redis/minikube/01-create-secret.sh
```

#### 步骤 2：部署 Redis
*Step 2: Deploy Redis*

```bash
./env/dev/02_redis/minikube/02-deploy-redis.sh
```

该脚本会创建或更新 namespace、`ConfigMap`、Headless Service、Sentinel Service 和 StatefulSet，并等待 `eb-redis` 进入 Ready。  
This script creates or updates the namespace, `ConfigMap`, Headless Service, Sentinel Service, and StatefulSet, and then waits for `eb-redis` to become Ready.

如果你后续修改了 `redis-configmap.yaml` 中的模板配置或渲染逻辑，再执行这一步即可；脚本会在 StatefulSet 已存在时主动重启它，让 `initContainer` 重新生成配置并生效。  
If you later modify the template configuration or render logic in `redis-configmap.yaml`, simply run this step again; if the StatefulSet already exists, the script actively restarts it so the `initContainer` regenerates the configuration and the changes take effect.

#### 步骤 3：打开本机到 Sentinel 的访问端口
*Step 3: Open the Local Access Port to Sentinel*

在单独终端中执行下面脚本，并保持该终端不要退出：  
Run the following script in a separate terminal and keep that terminal open:

```bash
./env/dev/02_redis/minikube/03-port-forward-sentinel.sh
```

执行成功后，本机可以通过下面地址访问 Sentinel 服务发现入口，用于查询当前主节点和检查 Sentinel 状态：  
After it succeeds, the local machine can access the Sentinel service-discovery entry point through the following address, for querying the current master and checking Sentinel status:

- Host: `127.0.0.1`
- Port: `26379`
- Master name: 仅在客户端明确启用 Sentinel 模式且要求填写该字段时，使用 `ebmaster`
  Master name: use `ebmaster` only when the client is explicitly in Sentinel mode and requires that field
- Sentinel password: 留空  
  Sentinel password: leave blank
- Redis node password: `REDIS_PASSWORD`，默认 `eb_redis_dev_123456`  
  Redis node password: `REDIS_PASSWORD`, default `eb_redis_dev_123456`

需要特别说明：当前 Sentinel 返回的是 Kubernetes 集群内部地址，例如 `*.svc.cluster.local`。宿主机上的 GUI 客户端通常无法解析这些地址，因此这里不应作为本地 GUI 的标准 Redis 数据连接入口。  
An important note: the current Sentinel returns Kubernetes internal addresses such as `*.svc.cluster.local`. Host-side GUI clients usually cannot resolve these addresses, so this should not be used as the standard Redis data connection entry point for local GUI tools.

如果客户端实际上是“普通 Redis 连接”，或者你是在宿主机上用 GUI 工具连 Redis 数据，那么不要连这里，而应改用步骤 5 的 `127.0.0.1:16379`，并把 `Master Group Name` 留空。  
If the client is actually making a normal Redis connection, or if you are using a GUI tool on the host to connect to Redis data, do not use this entry point. Use Step 5 with `127.0.0.1:16379` instead, and leave `Master Group Name` blank.

#### 步骤 4：查询 Sentinel 状态
*Step 4: Query Sentinel Status*

如果你只是想确认当前 master、replica、Sentinel 节点或仲裁状态，优先执行下面这个脚本，而不是让本机 GUI 直接连 `26379`：  
If you only want to confirm the current master, replicas, Sentinel nodes, or quorum status, use the following script first rather than letting a host-side GUI connect directly to `26379`:

```bash
./env/dev/02_redis/minikube/06-query-sentinel.sh
```

这个脚本直接通过 `kubectl exec` 进入一个 Sentinel 容器执行查询，不依赖本机 `port-forward`，因此更适合作为开发环境标准排查入口。  
This script directly enters a Sentinel container through `kubectl exec` to run the query, so it does not depend on a local `port-forward` and is therefore more suitable as the standard troubleshooting entry point in development.

默认会输出以下内容：  
By default, it prints the following information:

- `SENTINEL masters`
- `SENTINEL get-master-addr-by-name ebmaster`
- `SENTINEL replicas ebmaster`
- `SENTINEL sentinels ebmaster`
- `SENTINEL ckquorum ebmaster`

如果只想查看单项，也可以这样执行：  
If you only want to view a single item, you can also run:

```bash
./env/dev/02_redis/minikube/06-query-sentinel.sh masters
./env/dev/02_redis/minikube/06-query-sentinel.sh master-addr
./env/dev/02_redis/minikube/06-query-sentinel.sh replicas
./env/dev/02_redis/minikube/06-query-sentinel.sh sentinels
./env/dev/02_redis/minikube/06-query-sentinel.sh quorum
```

#### 步骤 5：打开本机到当前 master 的访问端口
*Step 5: Open the Local Access Port to the Current Master*

如果本地客户端不支持 Sentinel，或者你是在宿主机上使用 GUI / CLI 直接访问 Redis 数据，应执行：  
If the local client does not support Sentinel, or if you are using a host-side GUI / CLI to access Redis data directly, run:

```bash
./env/dev/02_redis/minikube/04-port-forward-master.sh
```

该脚本会先通过 Sentinel 查询当前 master，再把当前 master 的 `6379` 转发到本机。  
This script first queries Sentinel for the current master, and then forwards that master’s `6379` port to the local machine.

执行成功后，本机可以通过下面地址访问当前 master。这是宿主机侧标准连接方式：  
After it succeeds, the local machine can access the current master through the following address. This is the standard host-side connection method:

- Host: `127.0.0.1`
- Port: `16379`
- Password: `REDIS_PASSWORD`，默认 `eb_redis_dev_123456`  
  Password: `REDIS_PASSWORD`, default `eb_redis_dev_123456`
- Master Group Name: 留空  
  Master Group Name: leave blank

这里需要特别说明：步骤 3 和步骤 5 都是临时 `port-forward`，不是永久暴露端口。因此只要运行脚本的终端退出、`minikube` 停止重启，或 Redis Pod 发生切换，都需要重新执行对应脚本。步骤 4 的 Sentinel 查询脚本不属于 `port-forward`。  
An important clarification here: Steps 3 and 5 use temporary `port-forward`, not permanently exposed ports. So whenever the terminal exits, `minikube` stops and starts again, or the Redis Pods switch, the corresponding script must be run again. The Sentinel query script in Step 4 is not a `port-forward`.

### 3.12 常用检查命令
*Common Inspection Commands*

推荐优先使用：  
It is recommended to use:

```bash
./env/dev/02_redis/minikube/05-check-redis-status.sh
./env/dev/02_redis/minikube/06-query-sentinel.sh
```

如果需要单独排查，也可以使用下面这些常用命令：  
If you need to troubleshoot specific pieces, you can also use the following common commands:

```bash
kubectl -n easy-bank-dev get pods -l app=eb-redis -o wide
kubectl -n easy-bank-dev get svc eb-redis-headless
kubectl -n easy-bank-dev get svc eb-redis-sentinel
kubectl -n easy-bank-dev get pvc
kubectl -n easy-bank-dev logs eb-redis-0 -c redis
kubectl -n easy-bank-dev logs eb-redis-0 -c sentinel
```

`05-check-redis-status.sh` 的定位是做一轮汇总检查，它会显示当前 StatefulSet、Service、PVC、各 Pod 的 Redis 角色，以及 Sentinel 识别到的当前 master。  
The role of `05-check-redis-status.sh` is to perform a summary inspection. It shows the current StatefulSet, Services, PVCs, the Redis role of each Pod, and the current master recognized by Sentinel.

`06-query-sentinel.sh` 的定位是做 Sentinel 侧的细项查询，例如当前 master 地址、replica 列表、Sentinel 列表和仲裁状态。  
The role of `06-query-sentinel.sh` is to perform detailed Sentinel-side queries, such as the current master address, replica list, Sentinel list, and quorum status.

当前开发环境下推荐按下面顺序理解和使用这些脚本：  
Under the current development environment, it is recommended to understand and use these scripts in the following order:

- `05-check-redis-status.sh`：先做整体健康检查。  
  `05-check-redis-status.sh`: perform an overall health check first.
- `06-query-sentinel.sh`：再看 Sentinel 视角下的主从与仲裁信息。  
  `06-query-sentinel.sh`: then inspect master/replica and quorum information from Sentinel's point of view.
- `04-port-forward-master.sh`：最后给宿主机 GUI / CLI 打开标准数据访问入口。  
  `04-port-forward-master.sh`: finally open the standard host-side data access entry point for GUI / CLI tools.

### 3.13 常见问题与处理建议
*Common Problems and Handling Suggestions*

#### 问题 1：`Client On Error: Error: getaddrinfo ENOTFOUND eb-redis-*.svc.cluster.local`
*Problem 1: `Client On Error: Error: getaddrinfo ENOTFOUND eb-redis-*.svc.cluster.local`*

这个错误通常出现在宿主机 GUI 工具直连 Sentinel 时。  
This error usually appears when a host-side GUI tool connects directly to Sentinel.

根因是：Sentinel 返回了 Kubernetes 集群内部地址，例如 `eb-redis-1.eb-redis-headless.easy-bank-dev.svc.cluster.local`，而这些地址只能在集群内部解析，宿主机不能直接解析。  
The root cause is that Sentinel returns Kubernetes internal addresses such as `eb-redis-1.eb-redis-headless.easy-bank-dev.svc.cluster.local`, and these addresses can only be resolved inside the cluster, not directly by the host machine.

正确处理方式是：  
The correct handling method is:

- 如果你要查询 Sentinel 状态，执行 `./env/dev/02_redis/minikube/06-query-sentinel.sh`。  
  If you want to query Sentinel status, run `./env/dev/02_redis/minikube/06-query-sentinel.sh`.
- 如果你要在宿主机 GUI / CLI 中访问 Redis 数据，执行 `./env/dev/02_redis/minikube/04-port-forward-master.sh`，然后连接 `127.0.0.1:16379`。  
  If you want to access Redis data from a host-side GUI / CLI, run `./env/dev/02_redis/minikube/04-port-forward-master.sh` and then connect to `127.0.0.1:16379`.
- 不要把 `127.0.0.1:26379` 作为宿主机 GUI 的标准 Redis 数据入口。  
  Do not use `127.0.0.1:26379` as the standard Redis data entry point for a host-side GUI.

## 4. 测试环境
*Testing Environment*

待后续讨论。  
To be discussed later.

## 5. 生产环境
*Production Environment*

待后续讨论。  
To be discussed later.

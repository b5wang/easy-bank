# MySQL 环境搭建
*MySQL Environment Setup*

## 1. 文档目标
*Document Goal*

这份文档用于定义 `easy-bank` 项目的 MySQL 环境搭建方式。当前阶段重点是开发环境，也就是在已经完成 [05-base-environment-setup.md](05-base-environment-setup.md) 的前提下，把 MySQL 部署到 `minikube` 内，并满足本地客户端访问、集群内固定地址访问、数据持久化和脚本化初始化这些要求。  
This document defines the MySQL environment setup for the `easy-bank` project. At the current stage, the focus is the development environment, meaning that after [05-base-environment-setup.md](05-base-environment-setup.md) is completed, MySQL is deployed inside `minikube` and satisfies local client access, fixed in-cluster access, data persistence, and scripted initialization.

## 2. 环境分层
*Environment Layers*

### 2.1 开发环境
*Development Environment*

开发环境中的 MySQL 运行在 `minikube` 内部，提供本机和集群内两种访问方式。  
In the development environment, MySQL runs inside `minikube` and provides both local and in-cluster access methods.

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

### 3.1 前置条件
*Prerequisites*

开始 MySQL 搭建前，应先完成 [05-base-environment-setup.md](05-base-environment-setup.md) 中的开发环境基础配置，并至少确认以下条件已经成立：  
Before starting the MySQL setup, the development base environment from [05-base-environment-setup.md](05-base-environment-setup.md) should already be completed, and at least the following conditions should hold:

1. `Windows 11 + WSL2 + Ubuntu 22.04 + Docker Desktop` 已准备完成。  
   `Windows 11 + WSL2 + Ubuntu 22.04 + Docker Desktop` is ready.
2. `kubectl` 和 `minikube` 已经安装。  
   `kubectl` and `minikube` are already installed.
3. `minikube` profile `easy-bank-dev` 已启动。  
   The `easy-bank-dev` `minikube` profile has been started.
4. 当前 `kubectl` context 指向 `easy-bank-dev`。  
   The current `kubectl` context points to `easy-bank-dev`.

### 3.2 目标结构与固定约束
*Target Layout and Fixed Constraints*

开发环境中的 MySQL 固定采用以下结构：  
The development MySQL setup uses the following fixed structure:

- MySQL 运行在 `minikube` 内，而不是宿主机本地进程。  
  MySQL runs inside `minikube`, not as a direct host process.
- Kubernetes namespace 固定为 `easy-bank-dev`。  
  The Kubernetes namespace is fixed as `easy-bank-dev`.
- MySQL Deployment / Service 名称固定为 `eb-mysql`。  
  The MySQL Deployment / Service name is fixed as `eb-mysql`.
- 集群内固定访问地址为 `eb-mysql.easy-bank-dev.svc.cluster.local:3306`。  
  The fixed in-cluster address is `eb-mysql.easy-bank-dev.svc.cluster.local:3306`.
- 本机固定访问地址为 `127.0.0.1:13306`，通过 `kubectl port-forward` 提供。  
  The fixed local access address is `127.0.0.1:13306`, provided through `kubectl port-forward`.
- 数据通过 PVC `eb-mysql-data` 持久化。  
  Data is persisted through the PVC `eb-mysql-data`.
- 开发环境数据库默认字符集和排序规则由建库脚本统一设置。  
  The default charset and collation of development databases are set uniformly by the database-creation scripts.

### 3.3 目录与脚本清单
*Directory and Script Inventory*

MySQL 开发环境相关文件统一放在 `env/dev/01_mysql/minikube/` 下。  
The MySQL development-environment files are all placed under `env/dev/01_mysql/minikube/`.

- `env/dev/01_mysql/minikube/00-env.sh`  
  MySQL 相关统一变量定义。  
  Shared MySQL-related variable definitions.
- `env/dev/01_mysql/minikube/01-create-secret.sh`  
  创建开发环境 MySQL Secret。  
  Creates the development MySQL Secret.
- `env/dev/01_mysql/minikube/02-deploy-mysql.sh`  
  部署 namespace、PVC、Deployment 和 Service。  
  Deploys the namespace, PVC, Deployment, and Service.
- `env/dev/01_mysql/minikube/03-port-forward.sh`  
  把本机 `13306` 转发到集群内 `3306`。  
  Forwards local port `13306` to in-cluster port `3306`.
- `env/dev/01_mysql/minikube/04-init-databases.sh`  
  初始化 8 个业务数据库和首版建表脚本。  
  Initializes the 8 business databases and first-version schema scripts.
- `env/dev/01_mysql/minikube/k8s/namespace.yaml`  
  开发环境 namespace 清单。  
  Development namespace manifest.
- `env/dev/01_mysql/minikube/k8s/mysql-pvc.yaml`  
  MySQL 数据持久化 PVC。  
  MySQL data-persistence PVC.
- `env/dev/01_mysql/minikube/k8s/mysql-deployment.yaml`  
  MySQL Deployment 清单。  
  MySQL Deployment manifest.
- `env/dev/01_mysql/minikube/k8s/mysql-service.yaml`  
  MySQL Service 清单。  
  MySQL Service manifest.

### 3.4 搭建步骤
*Setup Steps*

#### 步骤 1：创建 MySQL Secret
*Step 1: Create the MySQL Secret*

如果接受默认开发环境账号密码，可以直接执行：  
If the default development credentials are acceptable, run:

```bash
./env/dev/01_mysql/minikube/01-create-secret.sh
```

如果希望自定义开发环境账号密码，可以先导出环境变量，再执行：  
If custom development credentials are preferred, export environment variables first and then run:

```bash
export MYSQL_ROOT_PASSWORD='change_me_root'
export MYSQL_APP_USER='eb_app'
export MYSQL_APP_PASSWORD='change_me_app'

./env/dev/01_mysql/minikube/01-create-secret.sh
```

#### 步骤 2：部署 MySQL
*Step 2: Deploy MySQL*

```bash
./env/dev/01_mysql/minikube/02-deploy-mysql.sh
```

该脚本会创建 namespace、PVC、Deployment 和 Service，并等待 MySQL Pod 进入 Ready。  
This script creates the namespace, PVC, Deployment, and Service, then waits for the MySQL Pod to become Ready.

#### 步骤 3：打开本地访问端口
*Step 3: Open the local access port*

在单独终端中执行下面脚本，并保持该终端不要退出：  
Run the following script in a separate terminal and keep that terminal open:

```bash
./env/dev/01_mysql/minikube/03-port-forward.sh
```

执行成功后，本地客户端可以连接到：  
After it succeeds, local clients can connect to:

- Host: `127.0.0.1`
- Port: `13306`

#### 步骤 4：初始化数据库
*Step 4: Initialize the databases*

```bash
./env/dev/01_mysql/minikube/04-init-databases.sh
```

该脚本会：  
This script will:

- 执行 8 个服务的 `create_database.sql`。  
  Execute `create_database.sql` for the 8 services.
- 创建开发环境应用账号，默认是 `eb_app`。  
  Create the development application account, which defaults to `eb_app`.
- 给该账号授予 8 个业务库的权限。  
  Grant that account privileges on the 8 business databases.
- 对每个业务库执行对应的 `V1__init.sql`。  
  Execute the corresponding `V1__init.sql` for each business database.

#### 步骤 5：验证连接
*Step 5: Verify the connection*

在 `03-port-forward.sh` 保持运行的前提下，本地开发工具可以直接连接：  
With `03-port-forward.sh` still running, local development tools can connect directly:

- Host: `127.0.0.1`
- Port: `13306`
- Username: 执行 `01-create-secret.sh` 时使用的 `MYSQL_APP_USER`，默认值是 `eb_app`  
  Username: the `MYSQL_APP_USER` used when `01-create-secret.sh` was executed, with `eb_app` as the default
- Password: 执行 `01-create-secret.sh` 时使用的 `MYSQL_APP_PASSWORD`  
  Password: the `MYSQL_APP_PASSWORD` used when `01-create-secret.sh` was executed

命令行验证示例：  
Command-line verification example:

```bash
mysql -h 127.0.0.1 -P 13306 -u eb_app -p
```

如果你在第 1 步里使用了自定义 `MYSQL_APP_USER`，请把上面命令中的 `eb_app` 替换成实际用户名。  
If you used a custom `MYSQL_APP_USER` in Step 1, replace `eb_app` in the command above with the actual username.

### 3.5 固定访问地址与数据库名
*Fixed Access Addresses and Database Names*

容器内微服务统一使用下面的固定地址和端口访问 MySQL：  
Microservices inside the cluster should use the following fixed address and port to access MySQL:

- Host: `eb-mysql.easy-bank-dev.svc.cluster.local`
- Port: `3306`

如果微服务本身也部署在 `easy-bank-dev` namespace 中，也可以使用短地址：  
If the microservices themselves are also deployed in the `easy-bank-dev` namespace, the short address may also be used:

- Host: `eb-mysql`
- Port: `3306`

各服务数据库名约定如下：  
The database-name mapping for each service is as follows:

| 微服务<br>Microservice | 数据库名<br>Database Name |
| --- | --- |
| `eb-service-auth` | `eb_auth` |
| `eb-service-account` | `eb_account` |
| `eb-service-transfer` | `eb_transfer` |
| `eb-service-channel` | `eb_channel` |
| `eb-service-risk` | `eb_risk` |
| `eb-service-notification` | `eb_notification` |
| `eb-service-audit` | `eb_audit` |
| `eb-service-ops` | `eb_ops` |

典型 JDBC 地址示例：  
A typical JDBC URL example is:

```text
jdbc:mysql://eb-mysql.easy-bank-dev.svc.cluster.local:3306/eb_auth?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Singapore
```

### 3.6 数据持久化说明
*Data Persistence Notes*

开发环境中，MySQL 数据目录挂载到 PVC `eb-mysql-data`，因此以下情况不会直接清空数据：  
In the development environment, the MySQL data directory is mounted to the PVC `eb-mysql-data`, so the following cases do not immediately clear the data:

- MySQL Pod 重建。  
  MySQL Pod recreation.
- MySQL Deployment 重新发布。  
  MySQL Deployment redeployment.
- `minikube stop` 后再次 `minikube start`。  
  Running `minikube start` again after `minikube stop`.

但如果执行 `minikube delete --profile easy-bank-dev` 或手动删除 PVC，开发环境数据就会被清空。  
However, if `minikube delete --profile easy-bank-dev` is run or the PVC is deleted manually, the development data is cleared.

### 3.7 常用检查命令
*Common Inspection Commands*

```bash
kubectl -n easy-bank-dev get pods
kubectl -n easy-bank-dev get svc
kubectl -n easy-bank-dev get pvc
kubectl -n easy-bank-dev logs deployment/eb-mysql
```

## 4. 测试环境
*Testing Environment*

待后续讨论。  
To be discussed later.

## 5. 生产环境
*Production Environment*

待后续讨论。  
To be discussed later.

# MySQL 环境搭建
*MySQL Environment Setup*

## 1. 文档目标
*Document Goal*

这份文档用于规划 `easy-bank` 项目中 MySQL 在不同环境下的搭建方式，并先完整落地开发环境方案。当前阶段重点是：让开发人员在 `Windows 11 + WSL2 + Ubuntu 22.04 + Docker Desktop + minikube` 的组合下，按文档和脚本一步一步执行，最终得到一个运行在 `minikube` 内、可持久化、可从本机访问、也可被集群内微服务稳定访问的 MySQL 开发环境。  
This document defines how MySQL should be set up across environments in the `easy-bank` project and fully specifies the development-environment plan first. The current focus is to let developers, using `Windows 11 + WSL2 + Ubuntu 22.04 + Docker Desktop + minikube`, follow the document and scripts step by step and end up with a MySQL development environment that runs inside `minikube`, persists data, is accessible from the local machine, and is also stably reachable by microservices inside the cluster.

## 2. 环境分层
*Environment Layers*

### 2.1 开发环境
*Development Environment*

开发环境采用 `Windows 11 宿主机 + WSL2 Ubuntu 22.04 + Docker Desktop + minikube + Kubernetes 内单实例 MySQL` 的方案。  
The development environment uses a `Windows 11 host + WSL2 Ubuntu 22.04 + Docker Desktop + minikube + single-instance MySQL inside Kubernetes` approach.

### 2.2 测试环境
*Testing Environment*

本节后续讨论。  
This section will be discussed later.

### 2.3 生产环境
*Production Environment*

本节后续讨论。  
This section will be discussed later.

## 3. 开发环境方案
*Development Environment Plan*

### 3.1 目标平台与固定约束
*Target Platform and Fixed Constraints*

开发环境固定采用以下平台和约束：  
The development environment uses the following fixed platform and constraints:

- Windows 11 作为宿主机操作系统。  
  Windows 11 is the host operating system.
- WSL 版本使用 `WSL2`。  
  `WSL2` is used as the WSL version.
- Linux 发行版固定为 `Ubuntu 22.04 LTS`。  
  The Linux distribution is fixed as `Ubuntu 22.04 LTS`.
- Docker 引擎由 Windows 侧 `Docker Desktop` 提供，并通过 WSL Integration 暴露给 Ubuntu。  
  The Docker engine is provided by `Docker Desktop` on Windows and exposed to Ubuntu through WSL Integration.
- `minikube` 与 `kubectl` 安装在 WSL Ubuntu 内执行。  
  `minikube` and `kubectl` are installed and used inside WSL Ubuntu.
- MySQL 运行在 `minikube` 内部，而不是宿主机本地进程。  
  MySQL runs inside `minikube`, not as a direct host process.
- MySQL 数据目录必须通过 PVC 持久化。  
  The MySQL data directory must be persisted through a PVC.
- 集群内固定访问地址为 `eb-mysql.easy-bank-dev.svc.cluster.local:3306`。  
  The fixed in-cluster address is `eb-mysql.easy-bank-dev.svc.cluster.local:3306`.
- 本机固定访问地址为 `127.0.0.1:13306`，通过 `kubectl port-forward` 暴露。  
  The fixed local access address is `127.0.0.1:13306`, exposed through `kubectl port-forward`.
- `minikube` profile 固定为 `easy-bank-dev`，namespace 固定为 `easy-bank-dev`。  
  The `minikube` profile is fixed as `easy-bank-dev`, and the namespace is fixed as `easy-bank-dev`.

### 3.2 目录结构
*Directory Layout*

根目录下统一使用 `env/` 目录存放所有环境相关脚本和配置文件。当前开发环境相关内容拆成两个部分：  
The repository root uses a unified `env/` directory for all environment-related scripts and configuration files. The current development-environment content is split into two parts:

- `env/dev/00_minikube`  
  负责 Windows 11 + WSL2 + Ubuntu 22.04 + Docker Desktop + minikube 的安装、检查与启动。  
  Handles installation, verification, and startup for Windows 11 + WSL2 + Ubuntu 22.04 + Docker Desktop + minikube.
- `env/dev/01_mysql/minikube`  
  负责 MySQL 在 minikube 内的部署、端口暴露和数据库初始化。  
  Handles MySQL deployment inside minikube, port exposure, and database initialization.

#### 3.2.1 `env/dev/00_minikube`
*`env/dev/00_minikube`*

- `env/dev/00_minikube/windows/.wslconfig.example`  
  Windows 用户主目录 `.wslconfig` 的建议模板。  
  Suggested template for the `.wslconfig` file in the Windows user home directory.
- `env/dev/00_minikube/windows/10-install-wsl.ps1`  
  在 Windows 管理员 PowerShell 中执行，用于安装或补齐 `WSL2 + Ubuntu 22.04`。  
  Run in elevated Windows PowerShell to install or complete `WSL2 + Ubuntu 22.04`.
- `env/dev/00_minikube/windows/20-apply-wslconfig.ps1`  
  把 `.wslconfig.example` 复制到当前 Windows 用户目录。  
  Copies `.wslconfig.example` into the current Windows user profile.
- `env/dev/00_minikube/windows/30-install-docker-desktop.ps1`  
  使用已下载的 Docker Desktop 安装包执行安装。  
  Uses a previously downloaded Docker Desktop installer to perform installation.
- `env/dev/00_minikube/wsl/00-env.sh`  
  `minikube` 相关统一变量。  
  Shared `minikube` variables.
- `env/dev/00_minikube/wsl/01-verify-wsl-ubuntu.sh`  
  检查当前是否运行在 `WSL2 Ubuntu 22.04`，并检查 Docker Desktop 集成是否已经生效。  
  Verifies that the current shell is running in `WSL2 Ubuntu 22.04` and that Docker Desktop integration is active.
- `env/dev/00_minikube/wsl/02-install-kubectl.sh`  
  在 Ubuntu 中安装 `kubectl`。  
  Installs `kubectl` in Ubuntu.
- `env/dev/00_minikube/wsl/03-install-minikube.sh`  
  在 Ubuntu 中安装 `minikube`。  
  Installs `minikube` in Ubuntu.
- `env/dev/00_minikube/wsl/04-start-minikube.sh`  
  启动 `easy-bank-dev` profile，并启用开发环境需要的 addon。  
  Starts the `easy-bank-dev` profile and enables the add-ons required by the development environment.
- `env/dev/00_minikube/wsl/05-status.sh`  
  输出当前 Docker、kubectl、minikube 与集群状态。  
  Prints the current Docker, kubectl, minikube, and cluster status.

#### 3.2.2 `env/dev/01_mysql/minikube`
*`env/dev/01_mysql/minikube`*

- `env/dev/01_mysql/minikube/00-env.sh`  
  MySQL 部署所需的统一变量定义。  
  Shared variable definitions used by the MySQL deployment scripts.
- `env/dev/01_mysql/minikube/01-create-secret.sh`  
  创建开发环境 MySQL Secret。  
  Creates the development MySQL Secret.
- `env/dev/01_mysql/minikube/02-deploy-mysql.sh`  
  部署 namespace、PVC、MySQL Deployment 和 Service。  
  Deploys the namespace, PVC, MySQL Deployment, and Service.
- `env/dev/01_mysql/minikube/03-port-forward.sh`  
  把本机 `13306` 转发到 MySQL `3306`。  
  Forwards local port `13306` to MySQL port `3306`.
- `env/dev/01_mysql/minikube/04-init-databases.sh`  
  执行 8 个微服务的建库脚本和首版建表脚本。  
  Executes the database-creation scripts and first-version schema scripts for the 8 microservices.
- `env/dev/01_mysql/minikube/k8s/namespace.yaml`  
  开发环境 namespace。  
  Development namespace.
- `env/dev/01_mysql/minikube/k8s/mysql-pvc.yaml`  
  数据持久化 PVC。  
  Data persistence PVC.
- `env/dev/01_mysql/minikube/k8s/mysql-deployment.yaml`  
  MySQL 单实例 Deployment。  
  Single-instance MySQL Deployment.
- `env/dev/01_mysql/minikube/k8s/mysql-service.yaml`  
  集群内固定访问 Service。  
  Fixed in-cluster access Service.

### 3.3 前置资源建议
*Recommended Local Resources*

开发人员本机建议至少预留以下资源：  
The local machine should ideally reserve at least the following resources:

- `4 CPU`
- `8 GB Memory`
- `40 GB Disk`

如果机器资源太低，`Docker Desktop + WSL2 + minikube + MySQL` 会明显变慢，甚至导致启动失败。  
If machine resources are too limited, `Docker Desktop + WSL2 + minikube + MySQL` can become very slow or even fail to start.

### 3.4 Windows 侧安装与设置步骤
*Windows-Side Installation and Setup Steps*

以下步骤在 Windows 11 的 PowerShell 中执行。涉及系统功能安装的脚本应使用管理员权限打开 PowerShell。  
The following steps are performed in Windows 11 PowerShell. Scripts that install system features should be run in elevated PowerShell.

#### 步骤 1：应用 `.wslconfig`
*Step 1: Apply `.wslconfig`*

先执行：  
Run the following first:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\env\dev\00_minikube\windows\20-apply-wslconfig.ps1
```

该脚本会把模板文件复制到当前 Windows 用户目录下的 `%UserProfile%\.wslconfig`。  
This script copies the template file into `%UserProfile%\.wslconfig` for the current Windows user.

当前模板建议值如下：  
The current template recommends the following values:

- `memory=8GB`
- `processors=4`
- `swap=2GB`

如果 `.wslconfig` 之前已经存在，请先人工确认是否需要保留原配置。  
If `.wslconfig` already exists, confirm manually first whether the existing configuration should be preserved.

#### 步骤 2：安装或补齐 `WSL2 + Ubuntu 22.04`
*Step 2: Install or complete `WSL2 + Ubuntu 22.04`*

在管理员 PowerShell 中执行：  
Run the following in elevated PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\env\dev\00_minikube\windows\10-install-wsl.ps1
```

该脚本会尝试完成：  
This script attempts to complete the following:

- 安装或更新 WSL。  
  Install or update WSL.
- 将默认 WSL 版本设置为 2。  
  Set the default WSL version to 2.
- 安装 `Ubuntu-22.04` 发行版。  
  Install the `Ubuntu-22.04` distribution.
- 把 `Ubuntu-22.04` 设为默认发行版。  
  Set `Ubuntu-22.04` as the default distribution.

如果 Windows 提示需要重启，请先重启系统，再重新执行一次该脚本。  
If Windows indicates that a reboot is required, reboot the system first and then rerun the script once.

#### 步骤 3：安装 Docker Desktop
*Step 3: Install Docker Desktop*

先从 Docker 官网下载 Windows 安装包，再在管理员 PowerShell 中执行：  
First download the Windows installer from the Docker website, then run the following in elevated PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\env\dev\00_minikube\windows\30-install-docker-desktop.ps1 -InstallerPath "C:\Users\<YourUser>\Downloads\Docker Desktop Installer.exe"
```

安装完成后，首次打开 Docker Desktop 时请确认以下设置：  
After installation, when opening Docker Desktop for the first time, confirm the following settings:

1. `Use the WSL 2 based engine` 已启用。  
   `Use the WSL 2 based engine` is enabled.
2. `Resources > WSL Integration` 中 `Ubuntu-22.04` 已启用。  
   `Ubuntu-22.04` is enabled under `Resources > WSL Integration`.
3. 当前使用的是 Linux containers，而不是 Windows containers。  
   Linux containers are being used instead of Windows containers.

#### 步骤 4：关闭并重启 WSL
*Step 4: Shut down and restart WSL*

应用 `.wslconfig` 和 Docker Desktop 设置后，建议执行：  
After applying `.wslconfig` and Docker Desktop settings, it is recommended to run:

```powershell
wsl --shutdown
```

随后重新打开 `Ubuntu-22.04`。  
Then reopen `Ubuntu-22.04`.

### 3.5 WSL Ubuntu 侧安装与设置步骤
*WSL Ubuntu-Side Installation and Setup Steps*

以下步骤在 `Ubuntu 22.04` 的 shell 中执行。  
The following steps are run inside the `Ubuntu 22.04` shell.

#### 步骤 5：检查 WSL / Ubuntu / Docker 集成
*Step 5: Verify WSL / Ubuntu / Docker integration*

执行：  
Run:

```bash
./env/dev/00_minikube/wsl/01-verify-wsl-ubuntu.sh
```

该脚本会检查：  
This script checks:

- 当前 shell 是否运行在 WSL 环境中。  
  Whether the current shell is running in WSL.
- 当前发行版是否为 Ubuntu 22.04。  
  Whether the current distribution is Ubuntu 22.04.
- Docker CLI 是否可用。  
  Whether the Docker CLI is available.
- `docker info` 是否可以成功连到 Docker Desktop。  
  Whether `docker info` can connect successfully to Docker Desktop.

#### 步骤 6：安装 kubectl
*Step 6: Install kubectl*

执行：  
Run:

```bash
./env/dev/00_minikube/wsl/02-install-kubectl.sh
```

#### 步骤 7：安装 minikube
*Step 7: Install minikube*

执行：  
Run:

```bash
./env/dev/00_minikube/wsl/03-install-minikube.sh
```

#### 步骤 8：启动 minikube
*Step 8: Start minikube*

执行：  
Run:

```bash
./env/dev/00_minikube/wsl/04-start-minikube.sh
```

该脚本会完成以下动作：  
This script performs the following actions:

- 使用 Docker driver 启动 `easy-bank-dev` profile。  
  Starts the `easy-bank-dev` profile with the Docker driver.
- 启用 `storage-provisioner` 和 `default-storageclass`。  
  Enables `storage-provisioner` and `default-storageclass`.
- 切换当前 `kubectl` context 到 `easy-bank-dev`。  
  Switches the current `kubectl` context to `easy-bank-dev`.

#### 步骤 9：检查 minikube 状态
*Step 9: Check minikube status*

执行：  
Run:

```bash
./env/dev/00_minikube/wsl/05-status.sh
```

### 3.6 MySQL 部署步骤
*MySQL Deployment Steps*

在 `minikube` 已启动且 `kubectl` context 正常的前提下，继续执行以下步骤。  
Once `minikube` is running and the `kubectl` context is ready, continue with the following steps.

#### 步骤 10：创建 MySQL Secret
*Step 10: Create the MySQL Secret*

如果接受默认开发环境账号密码，可以直接执行：  
If the default development credentials are acceptable, run:

```bash
./env/dev/01_mysql/minikube/01-create-secret.sh
```

如果希望自定义开发环境账号密码，可以先导出环境变量再执行：  
If custom development credentials are preferred, export environment variables first and then run:

```bash
export MYSQL_ROOT_PASSWORD='change_me_root'
export MYSQL_APP_USER='eb_app'
export MYSQL_APP_PASSWORD='change_me_app'

./env/dev/01_mysql/minikube/01-create-secret.sh
```

#### 步骤 11：部署 MySQL
*Step 11: Deploy MySQL*

执行：  
Run:

```bash
./env/dev/01_mysql/minikube/02-deploy-mysql.sh
```

该脚本会创建 namespace、PVC、Deployment 和 Service，并等待 MySQL Pod Ready。  
This script creates the namespace, PVC, Deployment, and Service, then waits for the MySQL Pod to become Ready.

#### 步骤 12：打开本地访问端口
*Step 12: Open the local access port*

在单独终端中执行下面脚本，并保持该终端不要退出：  
Run the following script in a separate terminal and keep that terminal open:

```bash
./env/dev/01_mysql/minikube/03-port-forward.sh
```

执行成功后，本地客户端可以连接到：  
After it succeeds, local clients can connect to:

- Host: `127.0.0.1`
- Port: `13306`

#### 步骤 13：初始化数据库
*Step 13: Initialize the databases*

执行：  
Run:

```bash
./env/dev/01_mysql/minikube/04-init-databases.sh
```

该脚本会：  
This script will:

- 执行 8 个服务的 `create_database.sql`。  
  Execute `create_database.sql` for the 8 services.
- 创建开发环境应用账号，默认是 `eb_app`。  
  Create the development application account, which defaults to `eb_app`.
- 为该账号授予 8 个业务库权限。  
  Grant that account privileges on the 8 business databases.
- 对每个业务库执行对应的 `V1__init.sql`。  
  Execute the corresponding `V1__init.sql` for each business database.

#### 步骤 14：验证连接
*Step 14: Verify the connection*

在 `03-port-forward.sh` 保持运行的前提下，本地开发工具可以直接连接：  
With `03-port-forward.sh` still running, local development tools can connect directly:

- Host: `127.0.0.1`
- Port: `13306`
- Username: 执行 `01-create-secret.sh` 时使用的 `MYSQL_APP_USER`，默认值是 `eb_app`  
  Username: the `MYSQL_APP_USER` used when `01-create-secret.sh` was executed, with `eb_app` as the default
- Password: 执行 `01-create-secret.sh` 时使用的 `MYSQL_APP_PASSWORD`  
  Password: the `MYSQL_APP_PASSWORD` used when `01-create-secret.sh` was executed

如果使用命令行验证：  
If you want to verify it from the command line:

```bash
mysql -h 127.0.0.1 -P 13306 -u eb_app -p
```

如果你在第 10 步里使用了自定义 `MYSQL_APP_USER`，请把上面命令中的 `eb_app` 替换成实际用户名。  
If you used a custom `MYSQL_APP_USER` in Step 10, replace `eb_app` in the command above with the actual username.

### 3.7 固定访问地址与数据库名
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

### 3.8 数据持久化说明
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

### 3.9 常用检查命令
*Common Inspection Commands*

```bash
./env/dev/00_minikube/wsl/05-status.sh
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

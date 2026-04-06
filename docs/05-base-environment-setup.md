# 基础环境配置
*Base Environment Setup*

## 1. 文档目标
*Document Goal*

这份文档用于定义 `easy-bank` 项目的基础环境配置方式，也就是在真正部署数据库、中间件和微服务之前，开发、测试、生产三类环境各自应具备的底座环境。当前阶段只细化开发环境，测试环境和生产环境先保留章节骨架。  
This document defines the base environment setup for the `easy-bank` project, meaning the underlying environment that should exist before databases, middleware, and microservices are deployed. At the current stage, only the development environment is detailed, while the testing and production environments are left as placeholders.

## 2. 环境分层
*Environment Layers*

### 2.1 开发环境
*Development Environment*

开发环境固定采用 `Windows 11 + WSL2 + Ubuntu 22.04 LTS + Docker Desktop + minikube` 的组合。  
The development environment is fixed as `Windows 11 + WSL2 + Ubuntu 22.04 LTS + Docker Desktop + minikube`.

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

### 3.1 目标平台与固定约束
*Target Platform and Fixed Constraints*

开发环境固定采用以下平台与约束：  
The development environment uses the following fixed platform and constraints:

- Windows 11 作为宿主机操作系统。  
  Windows 11 is the host operating system.
- WSL 版本固定为 `WSL2`。  
  The WSL version is fixed as `WSL2`.
- Linux 发行版固定为 `Ubuntu 22.04 LTS`。  
  The Linux distribution is fixed as `Ubuntu 22.04 LTS`.
- Docker 引擎由 Windows 侧 `Docker Desktop` 提供，通过 WSL Integration 暴露给 Ubuntu。  
  The Docker engine is provided by `Docker Desktop` on Windows and exposed to Ubuntu through WSL Integration.
- `kubectl` 和 `minikube` 安装在 WSL Ubuntu 内执行。  
  `kubectl` and `minikube` are installed and used inside WSL Ubuntu.
- `minikube` profile 固定为 `easy-bank-dev`。  
  The `minikube` profile is fixed as `easy-bank-dev`.
- Kubernetes namespace 默认使用 `easy-bank-dev`。  
  The default Kubernetes namespace is `easy-bank-dev`.

### 3.2 目录与脚本清单
*Directory and Script Inventory*

根目录下统一使用 `env/` 目录存放环境相关脚本和配置文件。基础环境配置当前放在 `env/dev/00_minikube/`。  
The repository root uses the `env/` directory for environment-related scripts and configuration files. The base environment setup currently lives under `env/dev/00_minikube/`.

- `env/dev/00_minikube/windows/.wslconfig.example`  
  Windows 用户主目录 `.wslconfig` 的建议模板。  
  Suggested template for the `.wslconfig` file in the Windows user home directory.
- `env/dev/00_minikube/windows/10-install-wsl.ps1`  
  安装或补齐 `WSL2 + Ubuntu 22.04`。  
  Installs or completes `WSL2 + Ubuntu 22.04`.
- `env/dev/00_minikube/windows/20-apply-wslconfig.ps1`  
  应用 `.wslconfig` 模板。  
  Applies the `.wslconfig` template.
- `env/dev/00_minikube/windows/30-install-docker-desktop.ps1`  
  使用已下载的安装包安装 Docker Desktop。  
  Installs Docker Desktop using a previously downloaded installer.
- `env/dev/00_minikube/wsl/00-env.sh`  
  `minikube` 相关统一变量。  
  Shared `minikube` variables.
- `env/dev/00_minikube/wsl/01-verify-wsl-ubuntu.sh`  
  检查当前是否为 `WSL2 Ubuntu 22.04`，并检查 Docker Desktop 集成是否正常。  
  Verifies that the current shell is `WSL2 Ubuntu 22.04` and that Docker Desktop integration is working.
- `env/dev/00_minikube/wsl/02-install-kubectl.sh`  
  在 Ubuntu 中安装 `kubectl`。  
  Installs `kubectl` in Ubuntu.
- `env/dev/00_minikube/wsl/03-install-minikube.sh`  
  在 Ubuntu 中安装 `minikube`。  
  Installs `minikube` in Ubuntu.
- `env/dev/00_minikube/wsl/04-start-minikube.sh`  
  启动 `easy-bank-dev` profile。  
  Starts the `easy-bank-dev` profile.
- `env/dev/00_minikube/wsl/05-check-minikube-status.sh`  
  检查当前 Docker、kubectl、minikube 和 Kubernetes 状态。  
  Checks the current Docker, kubectl, minikube, and Kubernetes status.

`env/dev/00_minikube/wsl/00-env.sh` 不是给开发人员单独执行的“步骤脚本”，而是供 `02-install-kubectl.sh`、`03-install-minikube.sh`、`04-start-minikube.sh`、`05-check-minikube-status.sh` 这类脚本内部通过 `source` 自动加载的变量文件。因此文档没有把它列为单独执行步骤。  
`env/dev/00_minikube/wsl/00-env.sh` is not a standalone “step script” for developers to run directly. It is a variable file automatically loaded internally via `source` by scripts such as `02-install-kubectl.sh`, `03-install-minikube.sh`, `04-start-minikube.sh`, and `05-check-minikube-status.sh`. That is why the document does not list it as a separate execution step.

如果后续确实需要改默认变量，例如 `MINIKUBE_PROFILE`、`MINIKUBE_CPUS`、`MINIKUBE_MEMORY`，有两种方式：  
If you later need to change default variables such as `MINIKUBE_PROFILE`, `MINIKUBE_CPUS`, or `MINIKUBE_MEMORY`, there are two ways:

- 直接编辑 `env/dev/00_minikube/wsl/00-env.sh`。  
  Edit `env/dev/00_minikube/wsl/00-env.sh` directly.
- 在运行具体脚本前先导出环境变量，例如：  
  Export environment variables before running a concrete script, for example:

```bash
export MINIKUBE_CPUS=16
export MINIKUBE_MEMORY=16384
./env/dev/00_minikube/wsl/04-start-minikube.sh
```

不建议直接执行 `./env/dev/00_minikube/wsl/00-env.sh`，因为它本身只定义变量，不执行实际安装或启动动作；而且即使你单独执行，它也不会把变量保留到当前 shell 会话里。  
It is not recommended to run `./env/dev/00_minikube/wsl/00-env.sh` directly, because it only defines variables and does not perform any real installation or startup action; and even if you run it directly, it will not keep those variables in your current shell session.

### 3.3 本机资源建议
*Local Resource Recommendation*

开发人员本机建议至少预留以下资源；当前 `env/dev/00_minikube/wsl/00-env.sh` 的默认值也按这组资源设置：  
The local machine should ideally reserve at least the following resources; the current defaults in `env/dev/00_minikube/wsl/00-env.sh` are aligned to this same resource set:

- `16 CPU`
- `16 GB Memory`
- `40 GB Disk`

如果机器资源低于这组默认值，建议先下调 `MINIKUBE_CPUS` 和 `MINIKUBE_MEMORY`，否则 `Docker Desktop + WSL2 + minikube` 可能启动缓慢，甚至失败。  
If machine resources are below these defaults, reduce `MINIKUBE_CPUS` and `MINIKUBE_MEMORY` first; otherwise `Docker Desktop + WSL2 + minikube` may start slowly or even fail.

### 3.4 Windows 侧安装与设置步骤
*Windows-Side Installation and Setup Steps*

以下步骤在 Windows 11 PowerShell 中执行。涉及系统能力安装的步骤，应使用你当前的 Windows 用户打开“以管理员身份运行”的 PowerShell，而不是切换到内置 `Administrator` 账户执行。  
The following steps are performed in Windows 11 PowerShell. For steps that install system capabilities, use your current Windows user to open PowerShell with “Run as administrator,” rather than switching to the built-in `Administrator` account.

#### 3.4.1 `.ps1` 文件是什么，应该如何运行
*What a `.ps1` File Is and How to Run It*

`.ps1` 是 `PowerShell Script` 文件，也就是给 Windows PowerShell 使用的脚本文件。它不是给 `cmd.exe` 用的，也不是给 `WSL bash` 用的。像 `env/dev/00_minikube/windows/10-install-wsl.ps1` 这类脚本，应该在 Windows 侧的 `PowerShell` 或 `Windows Terminal` 的 `PowerShell` 标签页里运行。  
`.ps1` is a `PowerShell Script` file, which means it is intended for Windows PowerShell. It is not meant for `cmd.exe`, and it is not meant for `WSL bash`. Scripts such as `env/dev/00_minikube/windows/10-install-wsl.ps1` should be run from Windows-side `PowerShell` or a `PowerShell` tab in `Windows Terminal`.

这里的“使用当前用户打开提升权限 PowerShell”需要单独说明：  
The phrase “use your current user to open elevated PowerShell” needs a separate clarification:

- “当前用户”指的是你平时登录 Windows 的那个账号。  
  “Current user” means the Windows account you normally use to sign in.
- “提升权限”指的是虽然还是这个账号，但把这次打开的 PowerShell 进程提升到管理员权限。  
  “Elevated” means that even though it is still the same account, the PowerShell process itself is raised to administrator privileges.
- 所以“当前用户打开提升权限 PowerShell”不等于“切换到内置 `Administrator` 账户”。  
  So “current user with elevated PowerShell” is not the same thing as “switch to the built-in `Administrator` account.”

可以简单理解成下面两种不同情况：  
You can understand it as the following two different cases:

- 普通打开 PowerShell：用户是你自己，但权限仍然是普通权限。  
  Open PowerShell normally: the user is still you, but the privileges remain normal user privileges.
- 以管理员身份运行 PowerShell：用户还是你自己，但这个 PowerShell 进程拿到了管理员权限。  
  Run PowerShell as administrator: the user is still you, but that PowerShell process receives administrator privileges.

如果你想判断当前 PowerShell 是否已经是“提升权限”状态，可以执行：  
If you want to check whether the current PowerShell is already elevated, run:

```powershell
([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
```

输出结果含义：  
The output means:

- `True`：当前 PowerShell 已提升权限。  
  `True`: the current PowerShell is elevated.
- `False`：当前只是普通打开。  
  `False`: the current PowerShell was opened normally without elevation.

推荐的运行方式如下：  
The recommended way to run it is:

1. 在 Windows 11 开始菜单中搜索 `PowerShell`。  
   Search for `PowerShell` in the Windows 11 Start menu.
2. 使用你当前的 Windows 用户，对 `Windows PowerShell` 或 `PowerShell` 点击右键，选择“以管理员身份运行”。不要切换到内置 `Administrator` 账户。  
   Using your current Windows user, right-click `Windows PowerShell` or `PowerShell` and choose “Run as administrator.” Do not switch to the built-in `Administrator` account.
3. 进入当前仓库目录，例如：  
   Change into the current repository directory, for example:

```powershell
cd D:\Projects\GitHub\b5wang\easy-bank
```

4. 临时放开当前 PowerShell 窗口对脚本执行的限制：  
   Temporarily allow script execution for the current PowerShell window:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

5. 使用相对路径执行 `.ps1` 脚本：  
   Run the `.ps1` script using a relative path:

```powershell
.\env\dev\00_minikube\windows\10-install-wsl.ps1
```

如果你当前不在仓库根目录，也可以用绝对路径执行：  
If you are not currently in the repository root, you can also run it with an absolute path:

```powershell
& "D:\Projects\GitHub\b5wang\easy-bank\env\dev\00_minikube\windows\10-install-wsl.ps1"
```

这里有几个容易出错的点：  
There are several easy failure points here:

- `.\` 表示“当前目录下的脚本”，如果你不在仓库根目录，PowerShell 会报找不到文件。  
  `.\` means “the script under the current directory,” so if you are not in the repository root, PowerShell will report that the file cannot be found.
- 如果没有先执行 `Set-ExecutionPolicy -Scope Process Bypass`，PowerShell 可能会阻止脚本执行。  
  If you do not run `Set-ExecutionPolicy -Scope Process Bypass` first, PowerShell may block the script.
- `10-install-wsl.ps1` 这种脚本涉及系统能力安装，所以必须用管理员 PowerShell 运行。  
  A script such as `10-install-wsl.ps1` touches system-level capabilities, so it must be run in elevated PowerShell.
- 如果使用 Windows 内置 `Administrator` 账户执行 `wsl --update` 一类命令，可能遇到更新失败；优先使用你当前的普通 Windows 用户，并在该用户下打开提升权限的 PowerShell。  
  If commands such as `wsl --update` are run under the built-in Windows `Administrator` account, updates may fail; prefer using your current regular Windows user and open elevated PowerShell under that user.
- 不要在 `WSL` 的 Ubuntu shell 里运行 `.ps1` 文件。  
  Do not run a `.ps1` file inside the Ubuntu shell in `WSL`.

本节里的 `10-install-wsl.ps1`、`20-apply-wslconfig.ps1` 和 `30-install-docker-desktop.ps1`，运行方式都是同一套：使用当前 Windows 用户打开“以管理员身份运行”的 PowerShell，切到仓库根目录后再执行。  
The `10-install-wsl.ps1`, `20-apply-wslconfig.ps1`, and `30-install-docker-desktop.ps1` files in this section all use the same execution pattern: use your current Windows user to open PowerShell with “Run as administrator,” then change into the repository root before running them.

#### 步骤 1：应用 `.wslconfig`
*Step 1: Apply `.wslconfig`*

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\env\dev\00_minikube\windows\20-apply-wslconfig.ps1
```

该脚本会把模板文件复制到 `%UserProfile%\.wslconfig`。  
This script copies the template file into `%UserProfile%\.wslconfig`.

当前模板建议值如下：  
The current template recommends the following values:

- `memory=8GB`
- `processors=4`
- `swap=2GB`

#### 步骤 2：安装或补齐 `WSL2 + Ubuntu 22.04`
*Step 2: Install or complete `WSL2 + Ubuntu 22.04`*

在你当前用户打开的“以管理员身份运行”的 PowerShell 中执行：  
Run the following in PowerShell opened with “Run as administrator” under your current user:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\env\dev\00_minikube\windows\10-install-wsl.ps1
```

如果你已经打开了当前用户下的管理员 PowerShell，但不确定当前目录是否正确，可以先执行：  
If you already opened elevated PowerShell under your current user but are unsure whether the current directory is correct, run this first:

```powershell
Get-Location
```

只有当输出目录是仓库根目录时，`.\env\dev\00_minikube\windows\10-install-wsl.ps1` 这种相对路径写法才会直接生效。  
The relative-path form `.\env\dev\00_minikube\windows\10-install-wsl.ps1` works directly only when the current directory is the repository root.

该脚本会尝试完成：  
This script attempts to complete the following:

- 安装或更新 WSL。  
  Install or update WSL.
- 将默认 WSL 版本设置为 2。  
  Set the default WSL version to 2.
- 安装 `Ubuntu-22.04`。  
  Install `Ubuntu-22.04`.
- 将 `Ubuntu-22.04` 设为默认发行版。  
  Set `Ubuntu-22.04` as the default distribution.

如果 Windows 提示需要重启，请先重启再重新执行该脚本。  
If Windows indicates that a reboot is required, reboot first and rerun the script.

#### 步骤 2.1：如果已经安装过 WSL2 和 Ubuntu，如何更新
*Step 2.1: How to update WSL2 and Ubuntu if they are already installed*

如果你的机器上已经装过 `WSL2` 和 `Ubuntu 22.04`，不需要重新安装，可以直接做“更新”而不是“重装”。  
If `WSL2` and `Ubuntu 22.04` are already installed on the machine, you do not need to reinstall them. You can update them directly instead.

先在当前用户打开的“以管理员身份运行”的 PowerShell 中更新 `WSL` 本身：  
First, update `WSL` itself in PowerShell opened with “Run as administrator” under your current user:

```powershell
wsl --status
wsl --update
wsl --shutdown
```

这一步的含义是：  
This step means:

- `wsl --update`：更新 WSL 平台组件和 WSL 2 内核。  
  `wsl --update`: updates the WSL platform components and the WSL 2 kernel.
- `wsl --shutdown`：让更新后的 WSL 重新加载生效。  
  `wsl --shutdown`: reloads WSL so the update takes effect.

如果要检查当前已经安装了哪些发行版，也可以执行：  
If you want to check which distributions are currently installed, you can also run:

```powershell
wsl -l -v
```

然后进入 `Ubuntu 22.04`，在 Ubuntu shell 中更新系统包：  
Then enter `Ubuntu 22.04` and update the system packages inside the Ubuntu shell:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt full-upgrade -y
sudo apt autoremove -y
```

如果你希望继续保持当前项目约定的 `Ubuntu 22.04`，这里不要执行 `do-release-upgrade`，否则可能会把发行版升级到新的大版本。  
If you want to keep the project’s agreed `Ubuntu 22.04`, do not run `do-release-upgrade` here, or the distribution may be upgraded to a new major version.

如果你发现 `wsl --update` 在内置 `Administrator` 账户下失败，而在当前用户下可以正常执行，应优先采用“当前用户 + 提升权限 PowerShell”的方式。  
If you find that `wsl --update` fails under the built-in `Administrator` account but works correctly under your current user, prefer the “current user + elevated PowerShell” approach.

#### 步骤 3：安装 Docker Desktop
*Step 3: Install Docker Desktop*

先从 Docker 官网下载 Windows 安装包，再在你当前用户打开的“以管理员身份运行”的 PowerShell 中执行：  
First download the Windows installer from the Docker website, then run the following in PowerShell opened with “Run as administrator” under your current user:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\env\dev\00_minikube\windows\30-install-docker-desktop.ps1 -InstallerPath "C:\Users\<YourUser>\Downloads\Docker Desktop Installer.exe"
```

安装完成后，首次打开 Docker Desktop 时需要确认：  
After installation, when opening Docker Desktop for the first time, confirm that:

1. `Use the WSL 2 based engine` 已启用。  
   `Use the WSL 2 based engine` is enabled.
2. `Resources > WSL Integration` 中 `Ubuntu-22.04` 已启用。  
   `Ubuntu-22.04` is enabled under `Resources > WSL Integration`.
3. 当前使用的是 Linux containers。  
   Linux containers are being used.

#### 步骤 4：关闭并重启 WSL
*Step 4: Shut down and restart WSL*

```powershell
wsl --shutdown
```

随后重新打开 `Ubuntu-22.04`。  
Then reopen `Ubuntu-22.04`.

### 3.5 WSL Ubuntu 侧安装与设置步骤
*WSL Ubuntu-Side Installation and Setup Steps*

以下步骤在 `Ubuntu 22.04` shell 中执行。  
The following steps are run inside the `Ubuntu 22.04` shell.

#### 步骤 5：检查 WSL / Ubuntu / Docker 集成
*Step 5: Verify WSL / Ubuntu / Docker integration*

```bash
./env/dev/00_minikube/wsl/01-verify-wsl-ubuntu.sh
```

如果你只是更新过 WSL 和 Ubuntu，没有重新安装，也建议先跑一次这个检查脚本，确认 Docker Desktop 到 WSL 的集成仍然正常。  
If you only updated WSL and Ubuntu rather than reinstalling them, it is still recommended to run this verification script once to confirm that Docker Desktop integration into WSL is still working correctly.

#### 步骤 6：安装 kubectl
*Step 6: Install kubectl*

```bash
./env/dev/00_minikube/wsl/02-install-kubectl.sh
```

#### 步骤 7：安装 minikube
*Step 7: Install minikube*

```bash
./env/dev/00_minikube/wsl/03-install-minikube.sh
```

#### 步骤 8：启动 minikube
*Step 8: Start minikube*

```bash
./env/dev/00_minikube/wsl/04-start-minikube.sh
```

该脚本会：  
This script will:

- 使用 Docker driver 启动 `easy-bank-dev` profile。  
  Start the `easy-bank-dev` profile with the Docker driver.
- 启用 `storage-provisioner`、`default-storageclass`、`dashboard` 和 `metrics-server`。  
  Enable `storage-provisioner`, `default-storageclass`, `dashboard`, and `metrics-server`.
- 切换当前 `kubectl` context 到 `easy-bank-dev`。  
  Switch the current `kubectl` context to `easy-bank-dev`.

如果后续需要打开 Dashboard，可以执行：  
If you later need to open the Dashboard, run:

```bash
minikube dashboard --profile=easy-bank-dev --url
```

该命令会输出一个本地访问 URL。使用 Dashboard 时，对应终端窗口应保持打开。  
This command prints a local access URL. Keep that terminal window open while using the Dashboard.

`04-start-minikube.sh` 运行完成后，脚本本身也会打印下面这组提示信息；开发人员看到后，直接复制命令执行即可：  
After `04-start-minikube.sh` finishes, the script itself also prints the following hint; developers can copy the command and run it directly:

```text
Dashboard hint:
Run: minikube dashboard --profile=easy-bank-dev --url
Keep that terminal open while using the dashboard URL.
```

建议的访问顺序如下：  
The recommended access flow is:

1. 先执行 `./env/dev/00_minikube/wsl/04-start-minikube.sh`。  
   First run `./env/dev/00_minikube/wsl/04-start-minikube.sh`.
2. 再执行 `minikube dashboard --profile=easy-bank-dev --url`。  
   Then run `minikube dashboard --profile=easy-bank-dev --url`.
3. 复制输出的本地 URL，到浏览器打开。  
   Copy the printed local URL and open it in a browser.
4. 保持这个终端窗口不要关闭，否则 Dashboard 访问会中断。  
   Keep that terminal window open; otherwise the Dashboard connection will stop.

#### 步骤 9：检查状态
*Step 9: Check status*

```bash
./env/dev/00_minikube/wsl/05-check-minikube-status.sh
```

### 3.6 开发环境日常启停与状态检查
*Daily Start, Stop, and Status Checks for Development*

完成以上步骤后，开发人员后续最常见的操作，就是停止 `minikube`、再次启动 `minikube`，以及检查当前运行状态。以下命令都在 `WSL Ubuntu` 中执行。  
After the above steps are completed, the most common follow-up operations are stopping `minikube`, starting `minikube` again, and checking the current runtime status. The following commands are all executed inside `WSL Ubuntu`.

#### 停止 minikube
*Stop minikube*

如果当天开发结束，想释放本机资源，可以执行：  
If development work is finished for the day and you want to release local machine resources, run:

```bash
minikube stop --profile=easy-bank-dev
```

这条命令会停止 `easy-bank-dev` 这个 profile 对应的本地 Kubernetes 集群，但不会删除这个 profile，也不会删除已经创建好的 Kubernetes 资源、PVC 或镜像缓存。  
This command stops the local Kubernetes cluster for the `easy-bank-dev` profile, but it does not delete the profile itself, nor does it delete Kubernetes resources, PVCs, or cached images that were already created.

#### 再次启动 minikube
*Start minikube again*

下次继续开发时，推荐仍然使用项目脚本：  
When continuing development later, it is still recommended to use the project script:

```bash
./env/dev/00_minikube/wsl/04-start-minikube.sh
```

这里需要特别说明：重新运行 `04-start-minikube.sh`，通常不会把之前已经搭好的 `minikube` 集群删除重建。它的主要作用，是对同一个 `easy-bank-dev` profile 再执行一次 `minikube start`，把之前已经存在但当前停止状态的集群重新启动起来。  
An important clarification here: running `04-start-minikube.sh` again will usually not delete and recreate the existing `minikube` cluster. Its main purpose is to run `minikube start` again for the same `easy-bank-dev` profile, bringing back a previously existing cluster that is currently stopped.

因此在日常场景下，可以把它理解成“重新启动之前已经设置好的 minikube 集群”。  
So in daily usage, it can be understood as “starting the previously configured minikube cluster again.”

同时也要注意更准确的技术边界：  
At the same time, the more precise technical boundary is:

- 它不是单纯执行一次 Docker 容器启动，而是对同一个 profile 再执行一次 `minikube start`。  
  It is not merely starting a Docker container once; it runs `minikube start` again against the same profile.
- 它不会默认清空之前的 Kubernetes 资源、PVC、已部署数据库或已启用 addon。  
  It does not clear previous Kubernetes resources, PVCs, deployed databases, or enabled addons by default.
- 如果你改动了脚本变量，例如 CPU、内存、磁盘大小或 driver，再次运行时这些配置可能会重新应用到这个 profile。  
  If you change script variables such as CPU, memory, disk size, or the driver, those settings may be applied again to this profile on the next run.

如果你只想做最小化启动动作，也可以直接执行：  
If you only want the smallest possible start action, you can also run:

```bash
minikube start --profile=easy-bank-dev
```

不过从项目一致性角度，优先推荐继续使用 `04-start-minikube.sh`。  
However, from the perspective of project consistency, continuing to use `04-start-minikube.sh` is preferred.

#### 常用状态检查命令
*Common Status Check Commands*

推荐优先使用项目脚本：  
It is recommended to use the project script first:

```bash
./env/dev/00_minikube/wsl/05-check-minikube-status.sh
```

如果需要单独排查，也可以使用下面这些常用命令：  
If you need to troubleshoot specific pieces, you can also use the following common commands:

```bash
minikube status --profile=easy-bank-dev
kubectl config current-context
kubectl get nodes
kubectl get ns
kubectl get pods -A
```

这些命令分别用于：  
These commands are used for:

- 检查 `easy-bank-dev` 这个 profile 当前是否已经启动。  
  Checking whether the `easy-bank-dev` profile is currently running.
- 检查当前 `kubectl` 是否指向正确的 context。  
  Checking whether `kubectl` is pointing to the correct context.
- 检查节点是否正常。  
  Checking whether the node is healthy.
- 检查 namespace 是否存在。  
  Checking whether the namespace exists.
- 检查所有 namespace 下的 Pod 是否正常启动。  
  Checking whether Pods across all namespaces are starting correctly.

### 3.7 与后续环境文档的关系
*Relation to Later Environment Documents*

`05-base-environment-setup.md` 只负责开发环境的基础底座。像 MySQL、Redis、Kafka 等具体基础设施部署，应在后续单独文档中继续展开。  
`05-base-environment-setup.md` is responsible only for the base development environment. Concrete infrastructure deployment such as MySQL, Redis, and Kafka should be expanded in later dedicated documents.

## 4. 测试环境
*Testing Environment*

待后续讨论。  
To be discussed later.

## 5. 生产环境
*Production Environment*

待后续讨论。  
To be discussed later.

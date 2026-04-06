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
- `env/dev/00_minikube/wsl/05-status.sh`  
  输出当前 Docker、kubectl、minikube 和 Kubernetes 状态。  
  Prints the current Docker, kubectl, minikube, and Kubernetes status.

### 3.3 本机资源建议
*Local Resource Recommendation*

开发人员本机建议至少预留以下资源：  
The local machine should ideally reserve at least the following resources:

- `4 CPU`
- `8 GB Memory`
- `40 GB Disk`

如果机器资源过低，`Docker Desktop + WSL2 + minikube` 的启动和运行会明显变慢，甚至失败。  
If machine resources are too limited, `Docker Desktop + WSL2 + minikube` can become significantly slower or even fail.

### 3.4 Windows 侧安装与设置步骤
*Windows-Side Installation and Setup Steps*

以下步骤在 Windows 11 PowerShell 中执行。涉及系统能力安装的步骤，应使用你当前的 Windows 用户打开“以管理员身份运行”的 PowerShell，而不是切换到内置 `Administrator` 账户执行。  
The following steps are performed in Windows 11 PowerShell. For steps that install system capabilities, use your current Windows user to open PowerShell with “Run as administrator,” rather than switching to the built-in `Administrator` account.

#### 3.4.1 `.ps1` 文件是什么，应该如何运行
*What a `.ps1` File Is and How to Run It*

`.ps1` 是 `PowerShell Script` 文件，也就是给 Windows PowerShell 使用的脚本文件。它不是给 `cmd.exe` 用的，也不是给 `WSL bash` 用的。像 `env/dev/00_minikube/windows/10-install-wsl.ps1` 这类脚本，应该在 Windows 侧的 `PowerShell` 或 `Windows Terminal` 的 `PowerShell` 标签页里运行。  
`.ps1` is a `PowerShell Script` file, which means it is intended for Windows PowerShell. It is not meant for `cmd.exe`, and it is not meant for `WSL bash`. Scripts such as `env/dev/00_minikube/windows/10-install-wsl.ps1` should be run from Windows-side `PowerShell` or a `PowerShell` tab in `Windows Terminal`.

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
- 启用 `storage-provisioner` 和 `default-storageclass`。  
  Enable `storage-provisioner` and `default-storageclass`.
- 切换当前 `kubectl` context 到 `easy-bank-dev`。  
  Switch the current `kubectl` context to `easy-bank-dev`.

#### 步骤 9：检查状态
*Step 9: Check status*

```bash
./env/dev/00_minikube/wsl/05-status.sh
```

### 3.6 与后续环境文档的关系
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

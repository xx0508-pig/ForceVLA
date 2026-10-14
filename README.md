# ForceVLA

面向视觉-语言-动作（VLA）研究的工程骨架。第一阶段以 **OpenPI / π0.5 + LIBERO** 为主线，支持：

- 本地 Ubuntu：编写代码、维护配置、提交 Git；
- GitHub：同步可复现的小文件；
- 4090 Ubuntu 云服务器：安装 OpenPI、下载数据/权重、训练与评估；
- 大文件隔离：数据集、模型权重、日志和视频不进入普通 Git 历史。

> 当前状态：工程脚手架已经创建，尚未下载 OpenPI、LIBERO 数据集或模型权重，也尚未启动训练。

## 工作流

```text
本地 Ubuntu                  GitHub                    4090 云服务器
ForceVLA/   -- git push -->  ForceVLA  -- git clone --> ForceVLA/
   |                                                        |
   +-- 代码、配置、脚本                                      +-- OpenPI 环境
   +-- 小型文档                                              +-- LIBERO 数据
                                                           +-- 权重/日志/输出
```

## 目录结构

```text
ForceVLA/
├── configs/
│   ├── experiments/        # 实验清单（项目元数据）
│   ├── openpi/             # 针对固定 OpenPI 版本的配置补丁
│   └── versions.env        # 上游仓库与提交号
├── data/
│   ├── raw/                # 原始数据（不提交）
│   ├── processed/          # 预处理数据（不提交）
│   ├── libero/             # LIBERO 数据（不提交）
│   └── cache/              # OpenPI/Hugging Face 缓存（不提交）
├── checkpoints/            # 训练权重（不提交）
├── docs/                   # 环境、阶段计划、GitHub 协作说明
├── logs/                   # 运行日志（不提交）
├── outputs/                # 评估视频、指标与导出结果（不提交）
├── scripts/                # 安装、检查、训练和评估入口
├── src/forcevla/           # 本项目后续集成代码
├── tests/                  # 不依赖 GPU 的工程结构测试
└── third_party/openpi/     # 脚本下载的上游 OpenPI（不提交）
```

## 本地首次使用

```bash
cd /home/deng-xuan/robotics/ForceVLA
cp .env.example .env
make validate
git status
```

本地开发机不必安装完整 GPU 训练环境。代码准备好后，按照 [GitHub 协作说明](docs/GITHUB_WORKFLOW.md) 创建远端仓库并推送。

## 云服务器快速开始

推荐镜像和硬件见 [云端环境说明](docs/CLOUD_SETUP.md)。连接云服务器并克隆本仓库后：

```bash
cd ForceVLA
cp .env.example .env
make doctor
make bootstrap
make smoke
```

然后依次执行：

```bash
make evaluate
make norm-stats
make train-smoke
```

确认 20-step LoRA 训练闭环和预训练模型评估均正常后，再运行正式训练：

```bash
make train
```

完整验收顺序和停止条件见 [第一阶段计划](docs/PHASE1.md)。

## 关键设计选择

1. **OpenPI 作为外部依赖**：下载到 `third_party/openpi/`，不复制其源码到本仓库。
2. **固定上游提交**：`configs/versions.env` 记录已核对的 OpenPI 提交，避免云端每次安装得到不同代码。
3. **由 OpenPI 的 `uv.lock` 管依赖**：顶层 `environment.yml` 只提供可选的基础工具环境，不重复维护 JAX/PyTorch 依赖。
4. **LIBERO 跟随 OpenPI 子模块**：避免再装一套互相冲突的 LIBERO 环境。
5. **4090 从 LoRA 小批量开始**：项目补丁新增 `pi05_libero_lora_4090`，默认 batch size 为 1、关闭 EMA；先通过短程测试，再按显存余量调大。

## 常用命令

```bash
make validate       # 检查工程结构和脚本语法
make doctor         # 检查 GPU、驱动、磁盘、uv、Docker
make bootstrap      # 下载固定版本 OpenPI 并安装依赖
make smoke          # OpenPI/JAX 最小训练检查
make norm-stats     # 计算 LIBERO 归一化统计量
make train-smoke    # 20-step π0.5 LoRA 测试
make train          # 正式训练（默认 30,000 steps）
make evaluate       # Docker 化 LIBERO 评估
```

## 上游依据

- [Physical Intelligence / openpi](https://github.com/Physical-Intelligence/openpi)
- [OpenPI LIBERO 示例](https://github.com/Physical-Intelligence/openpi/tree/main/examples/libero)
- [LIBERO 官方仓库](https://github.com/Lifelong-Robot-Learning/LIBERO)

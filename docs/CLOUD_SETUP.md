# 4090 云服务器环境

## 建议租用规格

| 项目 | 建议 |
|---|---|
| 系统 | Ubuntu 22.04 LTS x86_64 |
| GPU | NVIDIA RTX 4090 24 GB，独占显存优先 |
| NVIDIA 驱动 | 云平台当前稳定驱动，能够运行 CUDA 12 用户态库 |
| Python | 3.11 |
| CPU | 8 vCPU 或更多 |
| 内存 | 32 GB 起步，64 GB 更稳妥 |
| 磁盘 | 至少 200 GB 可用空间；数据和多份权重较多时增加数据盘 |
| 容器 | Docker + NVIDIA Container Toolkit（LIBERO 评估推荐） |

如果平台只能从预制镜像中选择，优先使用：

```text
Ubuntu 22.04 + CUDA 12.x + Python 3.11 + Miniconda（可选）
```

预装 PyTorch 的小版本不是决定因素，因为 OpenPI 使用自己的 `uv.lock` 创建隔离环境。截至本工程固定的 OpenPI 版本，其项目配置要求 Python 3.11 或更高，并固定 `jax[cuda12]`、PyTorch 2.7.1。OpenPI 官方也说明通常不需要在系统层另装 CUDA 用户态库；关键是 NVIDIA 驱动正常。

## 不建议的选择

- Windows 镜像；
- CUDA 13-only 镜像；
- Python 3.10 或更早版本；
- 系统盘很小、重启即清空且没有持久化数据盘的实例；
- 与其他租户共享且可用显存经常低于 23 GB 的 4090。

## 云端初始化

```bash
sudo apt-get update
sudo apt-get install -y git git-lfs curl build-essential docker.io
git lfs install
```

NVIDIA Container Toolkit 的安装方法随发行版和云平台变化，请优先使用供应商说明。完成后检查：

```bash
nvidia-smi
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

若镜像已带 Miniconda，可选用顶层工具环境：

```bash
conda env create -f environment.yml
conda activate forcevla-tools
```

也可以直接安装 `uv`，无需创建 Conda 环境：

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source "$HOME/.local/bin/env"
```

随后执行：

```bash
cp .env.example .env
./scripts/doctor.sh
./scripts/bootstrap_openpi.sh
```

## 存储布局

建议把数据盘挂载到稳定路径，再用软链接映射大目录。例如数据盘为 `/data/forcevla`：

```bash
mkdir -p /data/forcevla/{data,checkpoints,logs,outputs}
```

在任何移动或替换前，先确认目标目录为空。不要把缓存、数据集或权重提交到 GitHub。

## 网络和凭据

- Hugging Face token、Weights & Biases key 只保存在云端环境或 `.env`，不得提交。
- 策略服务默认端口 8000 不应直接暴露到公网；远程访问优先用 SSH tunnel。
- 长训练使用 `tmux`/`screen` 或云平台作业系统，避免 SSH 断开导致进程退出。

## 4090 显存策略

OpenPI 官方给出的 LoRA 估算超过 22.5 GB，因此 24 GB 4090 的余量很小。工程默认：

- JAX 后端；
- batch size 1；
- LoRA；
- EMA 关闭；
- `XLA_PYTHON_CLIENT_MEM_FRACTION=0.90`；
- 先运行 20 steps，再决定是否增加 batch size。

若仍然 OOM，先确认没有其他 GPU 进程，再保持 batch size 1，并检查实际空闲显存。不要直接切换到全量微调：官方估算全量微调需要超过 70 GB 显存。


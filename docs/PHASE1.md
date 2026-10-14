# 第一阶段：OpenPI / π0.5 + LIBERO

第一阶段目标不是立刻追求最终成功率，而是建立一条可重复、可诊断的完整链路。

## Gate 0：工程与机器检查

```bash
make validate
make doctor
```

通过标准：

- 工程结构测试通过；
- `nvidia-smi` 能看到 4090 和完整显存；
- `git`、`git-lfs`、`uv` 可用；
- 若准备 Docker 评估，`docker info` 与 NVIDIA 容器测试成功；
- 磁盘空间足够。

## Gate 1：安装固定版本 OpenPI

```bash
make bootstrap
```

该步骤会：

1. 下载 `configs/versions.env` 中固定的 OpenPI 提交及其子模块；
2. 使用 OpenPI 自带的 `uv.lock` 安装依赖；
3. 把项目的单卡 4090 LoRA 配置补丁应用到上游 checkout；
4. 把 OpenPI 的 `checkpoints/` 指向本项目的 `checkpoints/`。

通过标准：脚本末尾报告的 OpenPI commit 与 `OPENPI_REF` 完全一致。

## Gate 2：GPU/JAX 最小闭环

```bash
make smoke
```

脚本先输出 JAX/PyTorch 设备，再运行 OpenPI 自带的 `debug` 训练配置。通过标准：训练完成，日志中没有 CUDA、JAX、NaN 或 OOM 错误。

## Gate 3：预训练 π0.5-LIBERO 评估

```bash
LIBERO_TASK_SUITE=libero_10 make evaluate
```

默认使用 OpenPI 官方的 Docker 化 LIBERO 流程和 `gs://openpi-assets/checkpoints/pi05_libero`。第一次运行会下载镜像和权重，耗时取决于网络。

通过标准：

- policy server 启动；
- LIBERO client 能连接；
- 至少一个 episode 完整结束；
- 评估结果和视频可以写入运行目录。

若 EGL 报错，可临时尝试：

```bash
MUJOCO_GL=glx make evaluate
```

## Gate 4：训练数据与归一化统计

```bash
make norm-stats
```

项目配置使用 OpenPI 已转换的 `physical-intelligence/libero` 数据集。通过标准：配置对应的 norm stats 成功生成，且 `q01`、`q99`、`std` 没有明显异常的小尺度维度。

## Gate 5：单卡 LoRA 短程训练

```bash
make train-smoke
```

默认运行 20 steps、batch size 1、W&B offline。通过标准：

- 能进入 step 0 并完成全部 20 steps；
- loss、gradient norm 为有限值；
- 没有 OOM；
- checkpoint/log 目录可写。

20 steps 只证明链路连通，不代表模型收敛。

## Gate 6：正式训练

短程训练通过后：

```bash
WANDB_MODE=online FORCEVLA_EXPERIMENT=phase1_pi05_libero_lora_seed0 make train
```

默认目标为 30,000 steps。正式训练前记录：

- ForceVLA Git commit；
- OpenPI commit；
- 云实例型号、驱动、GPU 与显存；
- 数据集 revision/cache；
- config 名称、seed、batch size；
- norm stats；
- 启动命令与日志路径。

## 第一阶段交付物

- 可复现的环境检查结果；
- π0.5-LIBERO 预训练 checkpoint 的评估日志与视频；
- 20-step LoRA smoke checkpoint；
- 一次正式训练曲线与中间 checkpoint；
- 固定版本、配置和失败记录。


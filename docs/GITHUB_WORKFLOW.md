# GitHub 协作流程

## 本地创建远端

当前工程只初始化本地 Git，不替你创建 GitHub 仓库。先在 GitHub 创建一个空仓库，再执行：

```bash
cd /home/deng-xuan/robotics/ForceVLA
git remote add origin git@github.com:<your-account>/ForceVLA.git
git push -u origin main
```

若使用 HTTPS，把远端地址替换为 GitHub 提供的 HTTPS URL。

## 日常开发

本地 Ubuntu：

```bash
git switch -c feature/<short-name>
git add README.md configs scripts src tests docs
git commit -m "feat: describe the change"
git push -u origin feature/<short-name>
```

合并到 `main` 后，云端训练机只做快进更新：

```bash
git switch main
git pull --ff-only
```

训练正在运行时，不要在同一 checkout 中切换分支、重置或覆盖它正在读取的配置。更稳妥的方式是让每个长期实验使用固定 Git commit，代码更新用于下一次实验。

## 提交前检查

```bash
make validate
git status --short
git status --ignored --short
```

只应提交：

- 源码；
- 脚本；
- 配置；
- 文档；
- 小型测试资源。

禁止提交：

- `.env` 与任何 token/key；
- `data/` 中的数据；
- `checkpoints/`；
- `logs/`、`outputs/`、`wandb/`；
- `third_party/openpi/`；
- `.venv/` 或 Conda 环境目录。

如需共享大型权重，使用对象存储、Hugging Face Hub 或 GitHub Release，并在实验记录中保存校验值和下载位置。

## 上游版本升级

不要把 `OPENPI_REF` 从固定提交直接改成 `main`。升级流程应为：

1. 新建分支；
2. 更新 `configs/versions.env`；
3. 重新验证 `configs/openpi/*.patch`；
4. 重建 OpenPI 环境；
5. 依次跑完 `validate`、`doctor`、`smoke`、预训练评估和 20-step LoRA；
6. 记录兼容性变化后再合并。


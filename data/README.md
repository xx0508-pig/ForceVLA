# Data layout

- `raw/`: immutable source data.
- `processed/`: converted or filtered datasets.
- `libero/`: optional locally downloaded LIBERO demonstrations.
- `cache/openpi/`: OpenPI checkpoints/assets cache (`OPENPI_DATA_HOME`).
- `cache/huggingface/`: Hugging Face cache (`HF_HOME`).

All runtime contents are ignored by Git. Keep only this layout documentation and `.gitkeep` placeholders in the repository.


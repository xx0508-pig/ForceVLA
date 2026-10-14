# Configurations

- `versions.env` pins upstream repositories to reviewed commits.
- `experiments/phase1_pi05_libero.yaml` is a human-readable experiment manifest; OpenPI does not consume it directly.
- `openpi/pi05_libero_lora_4090.patch` adds the project-specific JAX LoRA config to the pinned OpenPI checkout.
- `docker/libero.outputs.yml` mounts the project output directory into the official LIBERO runtime container.

When changing the OpenPI revision, re-check and regenerate the patch before launching training. Do not force-apply the patch to an unreviewed upstream revision.

# Third-party source

`scripts/bootstrap_openpi.sh` installs the pinned OpenPI checkout at `third_party/openpi/`.

This directory is intentionally excluded from the ForceVLA Git repository. OpenPI already carries the LIBERO code required by its example as a pinned submodule, so a second editable LIBERO clone is not created here.


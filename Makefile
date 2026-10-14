SHELL := /usr/bin/env bash

.PHONY: validate doctor bootstrap smoke norm-stats train-smoke train evaluate

validate:
	./scripts/validate_project.sh

doctor:
	./scripts/doctor.sh

bootstrap:
	./scripts/bootstrap_openpi.sh

smoke:
	./scripts/smoke_test_openpi.sh

norm-stats:
	./scripts/compute_norm_stats.sh

train-smoke:
	./scripts/train_pi05_libero.sh smoke

train:
	./scripts/train_pi05_libero.sh full

evaluate:
	./scripts/evaluate_pi05_libero.sh


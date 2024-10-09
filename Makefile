.PHONY: build
build:
	python scripts/build_fastfile_xenon.py

.PHONY: format
format:
	uvx ruff format

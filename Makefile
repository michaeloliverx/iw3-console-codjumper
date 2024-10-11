.PHONY: build
build:
	python scripts/build_fastfiles.py

.PHONY: format
format:
	uvx ruff check --fix
	uvx ruff format

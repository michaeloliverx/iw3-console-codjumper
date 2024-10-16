.PHONY: build-fastfiles
build-fastfiles:
	python scripts/build_fastfiles.py --platforms ps3 xenon --minify-gsc

.PHONY: format
format:
	uvx ruff check --fix
	uvx ruff format

.PHONY: build-all
build-all:
	uv run scripts/build_fastfiles.py --systems ps3 xenon --minify-gsc

.PHONY: build-ps3
build-ps3:
	uv run scripts/build_fastfiles.py --systems ps3 --minify-gsc

.PHONY: build-xenon
build-xenon:
	uv run scripts/build_fastfiles.py --systems xenon --minify-gsc

.PHONY: build-plugin-xenon
build-plugin-xenon:
	"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" .\plugins\xenon\codjumper.sln

.PHONY: format
format:
	uvx ruff check --fix
	uvx ruff format

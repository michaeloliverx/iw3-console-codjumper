.PHONY: build-fastfiles
build-fastfiles:
	uv run scripts/build_fastfiles.py --platforms ps3 xenon --minify-gsc

.PHONY: build-fastfiles-enhanced
build-fastfiles-enhanced:
	uv run scripts/build_fastfiles.py --platforms xenon --minify-gsc --enhanced

.PHONY: build-plugin-xenon
build-plugin-xenon:
	"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" .\plugins\xenon\codjumper.sln

.PHONY: format
format:
	uvx ruff check --fix
	uvx ruff format

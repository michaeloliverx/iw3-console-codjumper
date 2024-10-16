# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "pcpp",
# ]
# ///
import argparse
import contextlib
import io
import logging
import re
import shutil
import subprocess
from dataclasses import dataclass
from enum import StrEnum
from pathlib import Path
from types import SimpleNamespace
from typing import Iterable

import pcpp
from fflib import ps3, xenon
from lib.minifier import minify_source

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

log = logging.getLogger(__name__)

MOD_DIR = "mod"

CLEAN_PS3_FF = "resources/cod4_tu4_ps3_patch_mp.ff"
CLEAN_XENON_FF = "resources/cod4_tu4_xbox_patch_mp.ff"

BUILD_DIR = "build"
XENON_BUILD_FF = f"{BUILD_DIR}/xenon/patch_mp.ff"
PS3_BUILD_FF = f"{BUILD_DIR}/ps3/patch_mp.ff"

RAW_FILES_ALLOWED = (".cfg", ".gsc")


class Platform(StrEnum):
    PS3 = "ps3"
    XENON = "xenon"


@dataclass
class ZoneFile:
    name: str
    maxsize: int
    raw_start: int
    raw_end: int
    raw: str


def get_zone_files(zone: bytes, file_extensions: Iterable[str]):
    zone_files: list[ZoneFile] = []

    file_ext_bytes = [ext.encode() + b"\0" for ext in file_extensions]

    offset = 0
    while True:
        found = False
        for file_ext in file_ext_bytes:
            end_index = zone.find(file_ext, offset)

            if end_index != -1:
                found = True
                start_index = end_index
                # keep looking backwards until we find 255 to find start index of name
                while start_index > 0 and zone[start_index] != 0xFF:
                    start_index -= 1

                name_start = start_index + 1
                filesize_start = name_start - 8
                filename = zone[name_start : end_index + len(file_ext) - 1].decode(
                    "utf-8"
                )
                filesize = int.from_bytes(
                    zone[filesize_start : filesize_start + 4], byteorder="big"
                )
                raw_start = name_start + len(filename) + 1
                raw_end = raw_start + filesize

                raw = zone[raw_start:raw_end].decode("utf-8")

                offset = end_index + len(file_ext)
                zone_files.append(
                    ZoneFile(
                        name=filename,
                        maxsize=filesize,
                        raw_start=raw_start,
                        raw_end=raw_end,
                        raw=raw,
                    )
                )
                break

        if not found:
            break

    return zone_files


def replace_zone_files(
    zone: bytes,
    mod_files: dict[str, Path],
    version: str,
    minify_gsc: bool,
    cj_enhanced: bool = True,
) -> bytes:
    zone_files = get_zone_files(zone, RAW_FILES_ALLOWED)
    zone_filename_to_file = {x.name: x for x in zone_files}

    for filename, path in mod_files.items():
        zone_file = zone_filename_to_file.get(filename)
        if not zone_file:
            log.info(f'Filename "{filename}" not found in zone, ignoring.')
            continue

        mod_file_contents = path.read_text()

        mod_file_contents = re.sub(
            r'level\.VERSION\s*=\s*"__VERSION__"',
            f'level.VERSION = "{version}"',
            mod_file_contents,
            count=1,
        )

        if filename.endswith(".gsc"):
            preprocessor = pcpp.Preprocessor()
            if cj_enhanced:
                preprocessor.define("CJ_ENHANCED 1")
            else:
                preprocessor.define("CJ_ENHANCED 0")

            preprocessor.line_directive = None  # Remove line directives

            # Ignore include not found errors
            def on_include_not_found(
                is_malformed, is_system_include, curdir, includepath
            ):
                raise pcpp.OutputDirective(pcpp.Action.IgnoreAndPassThrough)

            preprocessor.on_include_not_found = on_include_not_found
            preprocessor.parse(mod_file_contents)
            output = io.StringIO()
            preprocessor.write(output)
            preprocessed_output = output.getvalue()
            mod_file_contents = preprocessed_output

        if minify_gsc and filename.endswith(".gsc"):
            log.info(f"Minifying {filename}")
            size_before = len(mod_file_contents)
            mod_file_contents = minify_source(mod_file_contents, SimpleNamespace())
            size_after = len(mod_file_contents)
            saving = size_before - size_after
            log.info(f"Minified {filename}. {size_before=} {size_after=} {saving=}")

        mod_file_bytes = mod_file_contents.encode()

        mod_file_size = len(mod_file_bytes)
        if len(mod_file_contents) > zone_file.maxsize:
            raise Exception(
                f"Cannot overwrite file with bigger file size. {filename=} {zone_file.maxsize=}"
            )
        log.info(
            f"Injecting {filename} into zone. {mod_file_size=} {zone_file.maxsize=}"
        )

        # replace zone version with our version, fill leftover space with null bytes
        bytes_to_insert = mod_file_bytes + b"\x00" * (
            zone_file.maxsize - len(mod_file_bytes)
        )
        zone = zone[: zone_file.raw_start] + bytes_to_insert + zone[zone_file.raw_end :]

    return zone


def get_git_version() -> str:
    """Returns the version string for the current commit of the source code."""
    current_version = (
        subprocess.check_output(["git", "describe", "--tags", "--dirty", "--always"])
        .strip()
        .decode("utf-8")
    )
    with contextlib.suppress(subprocess.CalledProcessError):
        current_branch = (
            subprocess.check_output(
                ["git", "symbolic-ref", "--quiet", "--short", "HEAD"]
            )
            .strip()
            .decode("utf-8")
        )
        if current_version != "main":
            current_version += f"-{current_branch}"
    return current_version


def main() -> None:
    parser = argparse.ArgumentParser(description="Build CodJumper mod fastfiles")
    parser.add_argument(
        "--enhanced",
        action="store_true",
        help="Build the enhanced version of the mod.",
    )
    parser.add_argument(
        "--minify-gsc",
        action="store_true",
        help="Minifies the GSC scripts before packing.",
    )
    parser.add_argument(
        "--platforms",
        type=str,
        nargs="+",
        choices=["ps3", "xenon"],
        help="Platform(s) to build files for.",
        required=True,
    )
    args = parser.parse_args()

    log.info("Building fastfiles")

    log.info("Preparing build directory")
    shutil.rmtree(BUILD_DIR, ignore_errors=True)
    Path(BUILD_DIR).mkdir(parents=True, exist_ok=True)

    version = get_git_version()

    log.info(f"Version: {version}")

    # Gather all filenames in the mod directory
    mod_files: dict[str, Path] = {}
    for file in Path(MOD_DIR).rglob("*"):
        if file.is_file():
            relative_path = file.relative_to(MOD_DIR)
            mod_files[str(relative_path)] = file

    if Platform.PS3 in args.platforms:
        log.info("Generating PS3 fastfile")
        ps3_ff = Path(CLEAN_PS3_FF).read_bytes()
        ps3_zone = ps3.decompress_ff(ps3_ff)
        ps3_zone_modified = replace_zone_files(
            ps3_zone, mod_files, version, args.minify_gsc, args.enhanced
        )
        ps3_ff_recompressed = ps3.recompress_ff(ps3_zone_modified)
        log.debug(
            f"{len(ps3_ff_recompressed)=} {len(ps3_ff)=} {len(ps3_zone)=} {len(ps3_zone_modified)=} {len(ps3_ff_recompressed)=}"
        )
        Path(PS3_BUILD_FF).parent.mkdir(parents=True, exist_ok=True)
        Path(PS3_BUILD_FF).write_bytes(ps3_ff_recompressed)
        shutil.make_archive(
            f"{BUILD_DIR}/cj-iw3-ps3-{version}",
            "zip",
            root_dir=Path(PS3_BUILD_FF).parent,
            base_dir="patch_mp.ff",
        )

    if Platform.XENON in args.platforms:
        log.info("Generating Xbox 360 fastfile")
        xenon_ff = Path(CLEAN_XENON_FF).read_bytes()
        xenon_zone = xenon.decompress_ff(xenon_ff)
        xenon_zone_modified = replace_zone_files(
            xenon_zone, mod_files, version, args.minify_gsc, args.enhanced
        )
        xenon_ff_recompressed = xenon.recompress_ff(xenon_ff, xenon_zone_modified)
        log.debug(
            f"{len(xenon_ff_recompressed)=} {len(xenon_ff)=} {len(xenon_zone)=} {len(xenon_zone_modified)=} {len(xenon_ff_recompressed)=}"
        )
        if args.enhanced:
            output_dir = f"{BUILD_DIR}/xenon-enhanced"
            shutil.copytree("resources/xenon", output_dir)
            Path(f"{output_dir}/patch_mp.ff").write_bytes(xenon_ff_recompressed)
            input("Build the xenon plugin and copy xex to build/xenon-enhanced directory then press Enter to continue...")
            shutil.make_archive(
                f"{BUILD_DIR}/cj-enhanced-iw3-xenon-{version}",
                "zip",
                root_dir=output_dir
            )
        else:
            Path(XENON_BUILD_FF).parent.mkdir(parents=True, exist_ok=True)
            Path(XENON_BUILD_FF).write_bytes(xenon_ff_recompressed)
            shutil.make_archive(
                f"{BUILD_DIR}/cj-iw3-xenon-{version}",
                "zip",
                root_dir=Path(XENON_BUILD_FF).parent,
                base_dir="patch_mp.ff",
            )

    log.info("Success!")


if __name__ == "__main__":
    main()

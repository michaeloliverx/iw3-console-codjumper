from pathlib import Path
import zlib
import io
from dataclasses import dataclass
import re
import subprocess
from collections.abc import Iterable
import logging

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

log = logging.getLogger(__name__)

REPO_ROOT_DIR = Path(__file__).parent.parent
BUILD_DIR = REPO_ROOT_DIR / "build"
XBOX_PATCH_MP_FF = REPO_ROOT_DIR / "resources" / "cod4_tu4_xbox_patch_mp.ff"
MOD_DIR = REPO_ROOT_DIR / "mod"

BLOCK_SIZE = 0x200000
MAGIC = b"IWffs100"


def get_mod_filenames(directory: Path):
    items: dict[str, Path] = {}
    for file in Path(directory).rglob("*"):
        if file.is_file():
            relative_path = file.relative_to(directory)
            items[str(relative_path)] = file
    return items


def extract_zone_from_ff(ff: bytes):
    """
    Extract and decompress the zone from an IWff file.

    Args:
        ff: The raw bytes of the IWff file.

    Returns:
        Decompressed zone data as bytes.
    """
    start_offset = ff.find(MAGIC) + 16384

    ms = io.BytesIO(ff)
    ms.seek(start_offset)

    zone_data = bytearray()

    while True:
        block = ms.read(BLOCK_SIZE)
        if not block:
            break
        zone_data.extend(block)
        ms.seek(ms.tell() + 8192)

    return zlib.decompress(zone_data)


def inject_zone_into_ff(ff: bytes, uncompressed_zone: bytes):
    """
    Compress and inject the uncompressed zone data back into the IWff file.

    Args:
        ff: The raw bytes of the IWff file.
        uncompressed_zone: The uncompressed zone data to inject.

    Returns:
        Modified IWff file bytes with the compressed zone data.
    """
    start_offset = ff.find(MAGIC) + 16384
    block_size = BLOCK_SIZE

    # Compress the zone data using zlib
    compressed_zone_data = zlib.compress(uncompressed_zone, level=7)

    # Create a mutable bytearray from the IWff file bytes
    ms = io.BytesIO(ff)

    # Move to the correct position where the zone data should start
    ms.seek(start_offset)

    # Replace the old data with the new compressed zone data, following the block structure
    zone_data_offset = 0
    while zone_data_offset < len(compressed_zone_data):
        block = compressed_zone_data[zone_data_offset : zone_data_offset + block_size]
        # Write the compressed block back into the file
        ms.write(block)
        # Skip 8192 bytes, like in the original function
        ms.seek(ms.tell() + 8192)
        zone_data_offset += block_size

    return ms.getvalue()


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
                filesize = get_dword(zone, filesize_start)
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


def get_dword(data: bytes, offset: int) -> int:
    return int.from_bytes(data[offset : offset + 4], byteorder="big")


def get_version() -> str:
    """Returns the version string for the current commit of the source code."""
    current_version = (
        subprocess.check_output(["git", "describe", "--tags", "--dirty", "--always"])
        .strip()
        .decode("utf-8")
    )
    # git symbolic-ref --quiet --short HEAD
    current_branch = (
        subprocess.check_output(["git", "symbolic-ref", "--quiet", "--short", "HEAD"])
        .strip()
        .decode("utf-8")
    )
    if current_version != "main":
        current_version += f"-{current_branch}"
    return current_version


def main() -> None:
    log.info("Building fastfile for Xbox 360")

    version = get_version()

    log.info(f"Version: {version}")

    fastfile = Path(XBOX_PATCH_MP_FF).read_bytes()
    zone = extract_zone_from_ff(fastfile)
    zone_files = get_zone_files(zone, [".cfg", ".gsc"])
    zone_filename_to_file = {x.name: x for x in zone_files}

    mod_filenames = get_mod_filenames(MOD_DIR)
    for filename, path in mod_filenames.items():
        zone_file = zone_filename_to_file.get(filename)
        if not zone_file:
            log.info(f'Filename "{filename}" not found in zone, ignoring.')
            continue

        mod_file_contents = path.read_text()
        if len(mod_file_contents) > zone_file.maxsize:
            raise Exception(
                f"Cannot overwrite file with bigger file size. {filename=} {zone_file.maxsize=}"
            )

        mod_file_contents = re.sub(
            r'level\.VERSION\s*=\s*"__VERSION__"',
            f'level.VERSION = "{version}"',
            mod_file_contents,
        )

        mod_file_bytes = mod_file_contents.encode()

        # replace zone version with our version, fill leftover space with null bytes
        bytes_to_insert = mod_file_bytes + b"\x00" * (
            zone_file.maxsize - len(mod_file_bytes)
        )
        zone = zone[: zone_file.raw_start] + bytes_to_insert + zone[zone_file.raw_end :]

    built_fastfile = inject_zone_into_ff(fastfile, zone)

    BUILD_DIR.mkdir(exist_ok=True)
    (BUILD_DIR / "patch_mp.ff").write_bytes(built_fastfile)


if __name__ == "__main__":
    main()

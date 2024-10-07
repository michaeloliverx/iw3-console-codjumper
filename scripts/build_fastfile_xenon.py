from pathlib import Path
import zlib
import io
from dataclasses import dataclass
import re
import subprocess
from collections.abc import Iterable


REPO_ROOT_DIR = Path(__file__).parent.parent
BUILD_DIR = REPO_ROOT_DIR / "build"
XBOX_PATCH_MP_FF = REPO_ROOT_DIR / "resources" / "cod4_tu4_xbox_patch_mp.ff"
MOD_DIR = REPO_ROOT_DIR / "mod"


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
    start_offset = ff.find(b"IWffs100") + 16384
    block_size = 0x200000

    ms = io.BytesIO(ff)
    ms.seek(start_offset)

    zone_data = bytearray()

    while True:
        block = ms.read(block_size)
        if not block:
            break
        zone_data.extend(block)
        ms.seek(ms.tell() + 8192)

    return zlib.decompress(zone_data)


def inject_zone_into_ff(zone: bytes, ff: bytes):
    return ff


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
                # filesize is a dword - 4 bytes
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


def replace_version_with_commit(input: str) -> str:
    # Get the current git commit hash
    # TODO: get tag version or fallback to commit hash
    commit_hash = (
        subprocess.check_output(["git", "rev-parse", "HEAD"]).strip().decode("utf-8")
    )[:7]

    content_str = input

    updated_content_str = re.sub(
        r'level\.VERSION\s*=\s*"__VERSION__"',
        f'level.VERSION = "{commit_hash}"',
        content_str,
    )

    return updated_content_str


def main() -> None:
    fastfile = Path(XBOX_PATCH_MP_FF).read_bytes()
    zone = extract_zone_from_ff(fastfile)
    zone_files = get_zone_files(zone, [".cfg", ".gsc"])
    # for x in zone_files:
    #     print(x.name, x.maxsize, "\n", x.raw, "\n\n")

    zone_filename_to_file = {x.name: x for x in zone_files}

    mod_filenames = get_mod_filenames(MOD_DIR)
    # pprint(mod_filenames)

    for filename, path in mod_filenames.items():
        zone_file = zone_filename_to_file.get(filename)
        if not zone_file:
            print(f'Filename "{filename}" not found in zone, ignoring.')
            continue

        mod_file_contents = path.read_text()

        if len(mod_file_contents) > zone_file.maxsize:
            raise Exception(
                f"Cannot overwrite file with bigger file size. {filename=} {zone_file.maxsize=}"
            )

        mod_file_contents = replace_version_with_commit(mod_file_contents)
        mod_file_bytes = mod_file_contents.encode()

        # replace zone version with our version, fill leftover space with null bytes
        bytes_to_insert = mod_file_bytes + b"\x00" * (
            zone_file.maxsize - len(mod_file_bytes)
        )
        zone = zone[: zone_file.raw_start] + bytes_to_insert + zone[zone_file.raw_end :]

    built_fastfile = inject_zone_into_ff(zone, fastfile)

    (Path(BUILD_DIR) / "built.zone").write_bytes(zone)
    (Path(BUILD_DIR) / "patch_mp.ff").write_bytes(built_fastfile)


if __name__ == "__main__":
    main()

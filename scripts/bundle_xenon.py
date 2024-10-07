from pathlib import Path
import zlib
import io

xenon_patch = "resources/cod4_tu4_xbox_patch_mp.ff"

patch_data = Path(xenon_patch).read_bytes()


def process_ff(ff: bytes):
    start_offset = ff.find(b"IWffs100") + 16384
    block_size = 0x200000

    ms = io.BytesIO(ff)
    ms2 = io.BytesIO()

    ms.seek(start_offset)

    while True:
        block = ms.read(block_size)
        if not block:
            break

        ms2.write(block)

        ms.seek(ms.tell() + 8192)

    zone = zlib.decompress(ms2.getvalue())

    return zone


zone = process_ff(patch_data)


Path("inner.zone").write_bytes(zone)

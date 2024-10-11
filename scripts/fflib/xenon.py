import io
import zlib

CHUNK_SIZE = 0x200000
AUTH_DATA_SIZE = 0x2000
FF_HEADER = b"IWffu100\x00\x00\x00\x01"
COMPRESSED_ZONE_DATA_START = len(FF_HEADER) + 0x4000


def decompress_ff(ff: bytes):
    writer = io.BytesIO(ff)
    writer.seek(COMPRESSED_ZONE_DATA_START)

    zone_data = bytearray()

    while True:
        block = writer.read(CHUNK_SIZE)
        if not block:
            break
        zone_data.extend(block)
        writer.seek(writer.tell() + AUTH_DATA_SIZE)

    return zlib.decompress(zone_data)


def recompress_ff(ff: bytes, zone: bytes):
    writer = io.BytesIO(ff)
    writer.seek(COMPRESSED_ZONE_DATA_START)

    compressed_zone_data = zlib.compress(zone, level=7)

    zone_data_offset = 0
    while zone_data_offset < len(compressed_zone_data):
        block = compressed_zone_data[zone_data_offset : zone_data_offset + CHUNK_SIZE]
        writer.write(block)
        writer.seek(writer.tell() + AUTH_DATA_SIZE)
        zone_data_offset += CHUNK_SIZE

    return writer.getvalue()

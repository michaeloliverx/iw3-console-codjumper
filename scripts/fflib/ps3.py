import io
import zlib

ZLIB_HEADER = b"\x78\xda"
CHUNK_SIZE = 0x10000
FF_HEADER = b"IWffu100\x00\x00\x00\x01"


def decompress_ff(ff: bytes):
    reader = io.BytesIO(ff)
    writer = io.BytesIO()

    # Skip the header
    reader.seek(len(FF_HEADER))

    while True:
        compressed_data_size = int.from_bytes(reader.read(2), byteorder="big")
        if compressed_data_size == 1:  # End of the file
            break
        compressed_data = reader.read(compressed_data_size)
        decompressed_data = zlib.decompress(ZLIB_HEADER + compressed_data)
        writer.write(decompressed_data)
    return writer.getvalue()


def recompress_ff(zone: bytes):
    reader = io.BytesIO(zone)
    writer = io.BytesIO()

    writer.write(FF_HEADER)

    while True:
        chunk = reader.read(CHUNK_SIZE)
        if not chunk:
            break
        compressed_chunk = zlib.compress(chunk, level=7)[2:]
        compressed_length = len(compressed_chunk).to_bytes(2, byteorder="big")
        writer.write(compressed_length + compressed_chunk)

    writer.write(b"\x00\x01")  # End of the file

    return writer.getvalue()

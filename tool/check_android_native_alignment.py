"""Check PT_LOAD alignment of all 64-bit ELF libraries inside an APK or AAB.

APK ZIP alignment is a separate check: zipalign -c -P 16 4 app-release.apk.
"""
import json
import struct
import sys
import zipfile
from pathlib import Path


def inspect(path):
    libraries = []
    with zipfile.ZipFile(path) as archive:
        for item in archive.infolist():
            if not item.filename.endswith('.so'):
                continue
            data = archive.read(item)
            if data[:4] != b'\x7fELF':
                raise ValueError(f'Invalid ELF: {item.filename}')
            bits = data[4]
            endian = '<' if data[5] == 1 else '>'
            if bits != 2:
                libraries.append({'path': item.filename, 'bits': 32})
                continue
            phoff = struct.unpack_from(endian + 'Q', data, 32)[0]
            size, count = struct.unpack_from(endian + 'HH', data, 54)
            alignments = []
            for index in range(count):
                offset = phoff + index * size
                kind = struct.unpack_from(endian + 'I', data, offset)[0]
                if kind == 1:  # PT_LOAD
                    file_offset, address = struct.unpack_from(endian + 'QQ', data, offset + 8)
                    alignment = struct.unpack_from(endian + 'Q', data, offset + 48)[0]
                    if alignment < 16384 or (file_offset - address) % 16384:
                        raise ValueError(f'16 KB incompatible: {item.filename}')
                    alignments.append(alignment)
            if not alignments:
                raise ValueError(f'No loadable segments: {item.filename}')
            libraries.append({'path': item.filename, 'bits': 64, 'alignment': min(alignments)})
    if not any(item['bits'] == 64 for item in libraries):
        raise ValueError('No 64-bit native libraries found')
    return {'artifact': str(Path(path)), 'valid16KB': True, 'libraries': libraries}


if __name__ == '__main__':
    if len(sys.argv) != 2:
        raise SystemExit('Usage: python tool/check_android_native_alignment.py path/to/app.apk-or-aab')
    print(json.dumps(inspect(sys.argv[1]), indent=2))

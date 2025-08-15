#!/usr/bin/env python3
import argparse
import struct
import sys
import time

def main():
    parser = argparse.ArgumentParser(description='Convert Game Boy ROM to Palm OS PDB for Liberty.')
    parser.add_argument('--in', dest='input', required=True, help='input ROM file (.gb or .gbc)')
    parser.add_argument('--out', dest='output', required=True, help='output PDB file')
    parser.add_argument('--title', required=True, help='database title')
    args = parser.parse_args()

    try:
        with open(args.input, 'rb') as f:
            rom = f.read()
    except OSError as e:
        print(f"failed to read {args.input}: {e}", file=sys.stderr)
        return 1

    name = args.title.encode('ascii', 'replace')[:31]
    name += b'\x00' * (32 - len(name))

    now = int(time.time())
    header = struct.pack(
        '>32sHHLLLLLL4s4sLLH',
        name,
        0,          # attributes
        1,          # version
        now,        # creation date
        now,        # modification date
        0,          # last backup date
        0,          # modification number
        0,          # app info ID
        0,          # sort info ID
        b'ROMS',    # type
        b'LIBR',    # creator
        0,          # unique ID seed
        0,          # next record list ID
        1           # number of records
    )

    record_offset = len(header) + 8  # header + record list entry
    record_entry = struct.pack('>L', record_offset) + b'\x00\x00\x00\x00'

    try:
        with open(args.output, 'wb') as out:
            out.write(header)
            out.write(record_entry)
            out.write(rom)
    except OSError as e:
        print(f"failed to write {args.output}: {e}", file=sys.stderr)
        return 1

    print(args.output)
    return 0

if __name__ == '__main__':
    sys.exit(main())

